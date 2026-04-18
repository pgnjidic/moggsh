import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'models/server_profile.dart';
import 'services/server_profile_service.dart';
import 'services/ssh_key_manager.dart';
import 'services/ssh_session.dart';
import 'widgets/tmux_picker.dart';
import '../terminal/tabs/tab_manager.dart';

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

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await _service.loadAll();
    if (mounted) setState(() => _profiles = p);
  }

  Future<void> _connect(ServerProfile profile) async {
    final session = SshSession(profile);
    await session.connect();
    if (session.state != SshConnectionState.connected) return;
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
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _SectionHeader(label: 'SSH SERVERS', color: AppColors.blue),
        ..._profiles.map((p) => _ServerTile(
          profile: p,
          onTap: () => _connect(p),
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
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServerTile({required this.profile, required this.onTap,
      required this.onEdit, required this.onDelete});

  Color get _dotColor {
    if (profile.lastConnected == null) return AppColors.textMuted;
    final age = DateTime.now().difference(profile.lastConnected!);
    if (age.inMinutes < 30) return AppColors.green;
    if (age.inHours < 24) return AppColors.blue;
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final dot = _dotColor;
    final isActive = dot == AppColors.green;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.green.withValues(alpha: 0.05)
              : AppColors.surface2.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppColors.green.withValues(alpha: 0.2)
                : AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.dns_outlined, color: AppColors.blue, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(profile.label, style: const TextStyle(color: AppColors.textPrimary,
                fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text('${profile.username}@${profile.host}',
                style: const TextStyle(color: AppColors.textMuted, fontFamily: 'monospace', fontSize: 10)),
          ])),
          // Status dot
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dot,
              boxShadow: isActive ? [BoxShadow(color: dot.withValues(alpha: 0.7), blurRadius: 6)] : null,
            ),
          ),
          const SizedBox(width: 8),
          // Actions
          GestureDetector(onTap: onEdit,
              child: const Padding(padding: EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined, color: AppColors.textMuted, size: 14))),
          GestureDetector(onTap: onDelete,
              child: const Padding(padding: EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline, color: AppColors.textMuted, size: 14))),
          const SizedBox(width: 2),
          const Icon(Icons.chevron_right, color: AppColors.teal, size: 16),
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
