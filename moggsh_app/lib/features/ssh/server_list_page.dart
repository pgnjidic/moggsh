import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'models/server_profile.dart';
import 'services/server_profile_service.dart';
import 'services/ssh_key_manager.dart';
import 'services/ssh_session.dart';
import 'widgets/tmux_picker.dart';
import '../terminal/tabs/tab_manager.dart';
import '../terminal/tabs/terminal_tab.dart';

class ServerListPage extends StatefulWidget {
  final TabManager tabManager;
  final VoidCallback onConnected;

  const ServerListPage({super.key, required this.tabManager, required this.onConnected});

  @override
  State<ServerListPage> createState() => _ServerListPageState();
}

class _ServerListPageState extends State<ServerListPage> {
  final _service = ServerProfileService();
  List<ServerProfile> _profiles = [];
  String? _connectingId;

  @override
  void initState() {
    super.initState();
    _load();
    widget.tabManager.addListener(_onTabsChanged);
  }

  void _onTabsChanged() => setState(() {});

  @override
  void dispose() {
    widget.tabManager.removeListener(_onTabsChanged);
    super.dispose();
  }

  bool _isConnected(String profileId) => widget.tabManager.tabs.any(
    (t) => t.session.profile.id == profileId && t.sessionState == SessionState.active,
  );

  Future<void> _load() async {
    final p = await _service.loadAll();
    if (mounted) setState(() => _profiles = p);
  }

  Future<void> _connect(ServerProfile profile) async {
    setState(() => _connectingId = profile.id);
    try {
      final session = SshSession(profile);
      await session.connect();
      if (session.state != SshConnectionState.connected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              session.lastError ?? 'Connection failed',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            backgroundColor: AppColors.red,
          ));
        }
        return;
      }
      if (!mounted) return;

      final tmuxSessions = await session.listTmuxSessions();
      if (!mounted) return;

      if (tmuxSessions.isNotEmpty &&
          (profile.startupScript == null || profile.startupScript!.isEmpty)) {
        showModalBottomSheet(
          context: context,
          builder: (_) => TmuxPickerSheet(
            sessions: tmuxSessions,
            onSelect: (s) { if (s != null) session.attachTmux(s); _openTab(session, profile); },
          ),
        );
      } else {
        _openTab(session, profile);
      }

      profile.lastConnected = DateTime.now();
      await _service.update(profile);
    } finally {
      if (mounted) setState(() => _connectingId = null);
    }
  }

  void _openTab(SshSession session, ServerProfile profile) {
    widget.tabManager.addSshTab(session, profile.label);
    widget.onConnected();
  }

  void _showAddDialog() => _openSheet(null);
  void _showEditDialog(ServerProfile p) => _openSheet(p);

  void _openSheet(ServerProfile? initial) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _ServerSheet(
        initial: initial,
        onSave: (p) async {
          if (initial == null) {
            await _service.add(label: p.label, host: p.host, username: p.username,
                port: p.port, password: p.password, keyId: p.keyId, startupScript: p.startupScript);
          } else {
            await _service.update(ServerProfile(id: initial.id, label: p.label, host: p.host,
                username: p.username, port: p.port, password: p.password, keyId: p.keyId,
                startupScript: p.startupScript, lastConnected: initial.lastConnected));
          }
          _load();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          Expanded(child: _profiles.isEmpty ? _buildEmpty() : _buildList()),
        ]),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Row(children: [
      const Text('Hosts', style: TextStyle(color: AppColors.textPrimary, fontSize: 17,
          fontWeight: FontWeight.w600, letterSpacing: 0.3)),
      const Spacer(),
      GestureDetector(
        onTap: _showAddDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.green.withValues(alpha: 0.35)),
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add, color: AppColors.teal, size: 13),
            SizedBox(width: 4),
            Text('Add', style: TextStyle(color: AppColors.teal, fontSize: 12, fontFamily: 'monospace')),
          ]),
        ),
      ),
    ]),
  );

  Widget _buildEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.dns_outlined, color: AppColors.textMuted.withValues(alpha: 0.5), size: 48),
      const SizedBox(height: 12),
      const Text('No servers yet', style: TextStyle(color: AppColors.textMuted, fontFamily: 'monospace')),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _showAddDialog,
        child: const Text('+ Add server', style: TextStyle(color: AppColors.teal, fontFamily: 'monospace', fontSize: 13)),
      ),
    ]),
  );

  Widget _buildList() {
    final local = _profiles.where((p) =>
      p.host == 'localhost' || p.host == '127.0.0.1' || p.host == '0.0.0.0'
    ).toList();
    final remote = _profiles.where((p) => !local.contains(p)).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        if (local.isNotEmpty) ...[
          _SectionHeader(label: 'LOCAL', color: AppColors.amber),
          ...local.map((p) => _ServerTile(
            profile: p, isLocal: true, isConnected: _isConnected(p.id),
            isConnecting: _connectingId == p.id,
            onTap: () { if (_connectingId == null) _connect(p); },
            onEdit: () => _showEditDialog(p),
            onDelete: () async { await _service.delete(p.id); _load(); },
          )),
        ],
        _SectionHeader(label: 'SSH SERVERS', color: AppColors.blue),
        ...remote.map((p) => _ServerTile(
          profile: p, isLocal: false, isConnected: _isConnected(p.id),
          isConnecting: _connectingId == p.id,
          onTap: () { if (_connectingId == null) _connect(p); },
          onEdit: () => _showEditDialog(p),
          onDelete: () async { await _service.delete(p.id); _load(); },
        )),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
    child: Text(label, style: TextStyle(color: color, fontSize: 10,
        letterSpacing: 1.5, fontFamily: 'monospace',
        shadows: [Shadow(color: color.withValues(alpha: 0.4), blurRadius: 6)])),
  );
}

class _ServerTile extends StatelessWidget {
  final ServerProfile profile;
  final bool isLocal;
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServerTile({
    required this.profile,
    required this.isLocal,
    required this.isConnected,
    required this.isConnecting,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  (Color, bool) get _statusInfo {
    if (isConnecting) return (AppColors.amber, false);
    if (isConnected) return (AppColors.green, true);
    if (profile.lastConnected == null) return (AppColors.textMuted, false);
    final age = DateTime.now().difference(profile.lastConnected!);
    if (age.inHours < 24) return (AppColors.blue, false);
    return (AppColors.textMuted, false);
  }

  String get _statusSubtitle {
    if (isConnecting) return 'connecting…';
    if (isConnected) return 'connected';
    if (profile.lastConnected == null) return 'idle';
    final age = DateTime.now().difference(profile.lastConnected!);
    if (age.inHours < 24) return 'detached';
    if (age.inDays < 7) return 'idle · ${age.inDays}d';
    return 'offline';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete ${profile.label}?',
            style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 14)),
        content: const Text('This cannot be undone.',
            style: TextStyle(color: AppColors.textMuted, fontFamily: 'monospace', fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
          TextButton(
            onPressed: () { Navigator.pop(context); onDelete(); },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (dot, glow) = _statusInfo;
    final iconColor = isLocal ? AppColors.green : AppColors.blue;
    final iconBg = iconColor.withValues(alpha: 0.12);
    final borderHi = glow ? AppColors.green.withValues(alpha: 0.3) : AppColors.border.withValues(alpha: 0.4);
    final tileBg = glow
        ? AppColors.green.withValues(alpha: 0.05)
        : AppColors.surface2.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderHi),
          boxShadow: glow ? [
            BoxShadow(color: AppColors.green.withValues(alpha: 0.1), blurRadius: 12),
          ] : null,
        ),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: iconColor.withValues(alpha: 0.25)),
            ),
            child: Icon(
              isLocal ? Icons.phone_android_rounded : Icons.dns_outlined,
              color: iconColor, size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                child: Text(profile.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textPrimary,
                      fontFamily: 'monospace', fontSize: 12.5, fontWeight: FontWeight.w500)),
              ),
            ]),
            const SizedBox(height: 2),
            Row(children: [
              Container(
                width: 6, height: 6,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dot,
                  boxShadow: glow ? [BoxShadow(color: dot.withValues(alpha: 0.7), blurRadius: 5)] : null,
                ),
              ),
              Flexible(
                child: Text(
                  isLocal
                    ? _statusSubtitle
                    : '${profile.username}@${profile.host} · $_statusSubtitle',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: glow ? AppColors.green.withValues(alpha: 0.8) : AppColors.textMuted,
                    fontFamily: 'monospace', fontSize: 10,
                  ),
                ),
              ),
            ]),
          ])),
          if (isConnecting)
            SizedBox(
              width: 40, height: 40,
              child: Center(
                child: SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.amber.withValues(alpha: 0.8),
                  ),
                ),
              ),
            )
          else ...[
            GestureDetector(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 40, height: 40,
                child: Center(
                  child: Icon(Icons.edit_outlined,
                      color: AppColors.blue.withValues(alpha: 0.6), size: 16),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _confirmDelete(context),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 40, height: 40,
                child: Center(
                  child: Icon(Icons.delete_outline,
                      color: AppColors.red.withValues(alpha: 0.6), size: 16),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Server add/edit sheet ──────────────────────────────────────────────────

class _ServerSheet extends StatefulWidget {
  final ServerProfile? initial;
  final ValueChanged<ServerProfile> onSave;
  const _ServerSheet({this.initial, required this.onSave});

  @override
  State<_ServerSheet> createState() => _ServerSheetState();
}

class _ServerSheetState extends State<_ServerSheet> {
  late final TextEditingController _host, _user, _port, _label, _pass, _script;
  List<SshKeyEntry> _keys = [];
  String? _selectedKeyId;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _host   = TextEditingController(text: p?.host ?? '');
    _user   = TextEditingController(text: p?.username ?? 'root');
    _port   = TextEditingController(text: (p?.port ?? 22).toString());
    _label  = TextEditingController(text: p?.label ?? '');
    _pass   = TextEditingController(text: p?.password ?? '');
    _script = TextEditingController(text: p?.startupScript ?? '');
    _selectedKeyId = p?.keyId;
    SshKeyManager.listAll().then((k) { if (mounted) setState(() => _keys = k); });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_isEdit ? 'Edit server' : 'Add server',
              style: const TextStyle(color: AppColors.green, fontFamily: 'monospace', fontSize: 15)),
          const SizedBox(height: 16),
          _field(_label, 'Label', 'My VPS'),
          _field(_host,  'Host',  '1.2.3.4'),
          Row(children: [
            Expanded(child: _field(_user, 'User', 'root')),
            const SizedBox(width: 8),
            SizedBox(width: 72, child: _field(_port, 'Port', '22', keyboard: TextInputType.number)),
          ]),
          _field(_pass, 'Password (optional)', '', obscure: true),
          const SizedBox(height: 8),
          if (_keys.isNotEmpty) ...[
            const Text('SSH Key', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              _KeyChip(label: 'none', selected: _selectedKeyId == null,
                  onTap: () => setState(() => _selectedKeyId = null)),
              ..._keys.map((k) => _KeyChip(label: k.label, selected: _selectedKeyId == k.id,
                  onTap: () => setState(() => _selectedKeyId = k.id))),
            ]),
            const SizedBox(height: 10),
          ],
          _field(_script, 'Startup script (optional)', 'cd myproject'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green, foregroundColor: AppColors.bg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                if (_host.text.isEmpty) return;
                widget.onSave(ServerProfile(id: '',
                  label: _label.text.isEmpty ? _host.text : _label.text,
                  host: _host.text.trim(), username: _user.text.trim(),
                  port: int.tryParse(_port.text) ?? 22,
                  password: _pass.text.isEmpty ? null : _pass.text,
                  keyId: _selectedKeyId,
                  startupScript: _script.text.isEmpty ? null : _script.text,
                ));
                Navigator.pop(context);
              },
              child: Text(_isEdit ? 'Save' : 'Add server',
                  style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, String hint,
      {bool obscure = false, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c, obscureText: obscure, keyboardType: keyboard,
        style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 13),
        decoration: InputDecoration(
          labelText: label, hintText: hint,
          labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.green)),
        ),
      ),
    );
  }
}

class _KeyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _KeyChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? AppColors.blue.withValues(alpha: 0.15) : Colors.transparent,
        border: Border.all(color: selected ? AppColors.blue : AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(
        color: selected ? AppColors.blue : AppColors.textMuted,
        fontFamily: 'monospace', fontSize: 11,
      )),
    ),
  );
}
