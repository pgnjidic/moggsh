import 'package:flutter/material.dart';
import 'models/server_profile.dart';
import 'services/server_profile_service.dart';
import 'services/ssh_key_manager.dart';
import 'services/ssh_session.dart';
import 'widgets/tmux_picker.dart';
import '../terminal/tabs/tab_manager.dart';

class ServerListPage extends StatefulWidget {
  final TabManager tabManager;
  final VoidCallback onConnected;

  const ServerListPage({
    super.key,
    required this.tabManager,
    required this.onConnected,
  });

  @override
  State<ServerListPage> createState() => _ServerListPageState();
}

class _ServerListPageState extends State<ServerListPage> {
  final _service = ServerProfileService();
  List<ServerProfile> _profiles = [];

  static const _green = Color(0xFF00FF88);
  static const _bg    = Color(0xFF0A0A0F);
  static const _muted = Color(0xFF666688);

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
          onSelect: (s) {
            if (s != null) session.attachTmux(s);
            _openTab(session, profile);
          },
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

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12121A),
      builder: (_) => _AddServerSheet(onAdd: (p) async {
        await _service.add(
          label: p.label, host: p.host, username: p.username,
          port: p.port, password: p.password, keyId: p.keyId,
          startupScript: p.startupScript,
        );
        _load();
      }),
    );
  }

  void _showEditDialog(ServerProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12121A),
      builder: (_) => _AddServerSheet(
        initial: profile,
        onAdd: (updated) async {
          await _service.update(ServerProfile(
            id: profile.id,
            label: updated.label,
            host: updated.host,
            username: updated.username,
            port: updated.port,
            password: updated.password,
            keyId: updated.keyId,
            startupScript: updated.startupScript,
            lastConnected: profile.lastConnected,
          ));
          _load();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('servers',
                      style: TextStyle(
                          color: _green, fontSize: 18,
                          fontFamily: 'monospace', letterSpacing: 2)),
                  IconButton(
                    icon: const Icon(Icons.add, color: _green),
                    onPressed: _showAddDialog,
                  ),
                ],
              ),
            ),
            if (_profiles.isEmpty)
              Expanded(
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.dns_outlined, color: Color(0xFF333355), size: 48),
                    const SizedBox(height: 12),
                    const Text('No servers yet',
                        style: TextStyle(color: _muted, fontFamily: 'monospace')),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _showAddDialog,
                      child: const Text('+ Add server',
                          style: TextStyle(color: _green, fontFamily: 'monospace')),
                    ),
                  ]),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _profiles.length,
                  itemBuilder: (_, i) => _ServerTile(
                    profile: _profiles[i],
                    onTap: () => _connect(_profiles[i]),
                    onEdit: () => _showEditDialog(_profiles[i]),
                    onDelete: () async {
                      await _service.delete(_profiles[i].id);
                      _load();
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ServerTile extends StatelessWidget {
  final ServerProfile profile;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServerTile({
    required this.profile,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.dns_outlined, color: Color(0xFF00D4FF), size: 20),
      title: Text(profile.label,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13)),
      subtitle: Text('${profile.username}@${profile.host}:${profile.port}',
          style: const TextStyle(color: Color(0xFF666688), fontFamily: 'monospace', fontSize: 11)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (profile.lastConnected != null)
          Text(_timeAgo(profile.lastConnected!),
              style: const TextStyle(color: Color(0xFF444466), fontSize: 10, fontFamily: 'monospace')),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF444466)),
          onPressed: onEdit,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFF444466)),
          onPressed: onDelete,
        ),
      ]),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

class _AddServerSheet extends StatefulWidget {
  final ValueChanged<ServerProfile> onAdd;
  final ServerProfile? initial;
  const _AddServerSheet({required this.onAdd, this.initial});

  @override
  State<_AddServerSheet> createState() => _AddServerSheetState();
}

class _AddServerSheetState extends State<_AddServerSheet> {
  late final TextEditingController _host;
  late final TextEditingController _user;
  late final TextEditingController _port;
  late final TextEditingController _label;
  late final TextEditingController _pass;
  late final TextEditingController _script;

  List<SshKeyEntry> _keys = [];
  String? _selectedKeyId;

  static const _green  = Color(0xFF00FF88);
  static const _muted  = Color(0xFF666688);
  static const _border = Color(0xFF2A2A3E);

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
    SshKeyManager.listAll().then((keys) {
      if (mounted) setState(() => _keys = keys);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_isEdit ? 'Edit server' : 'Add server',
              style: const TextStyle(color: _green, fontFamily: 'monospace', fontSize: 16)),
          const SizedBox(height: 16),
          _field(_label, 'Label', 'My VPS'),
          _field(_host,  'Host',  '1.2.3.4'),
          Row(children: [
            Expanded(child: _field(_user, 'User', 'root')),
            const SizedBox(width: 8),
            SizedBox(width: 80, child: _field(_port, 'Port', '22', keyboard: TextInputType.number)),
          ]),
          _field(_pass, 'Password (optional)', '', obscure: true),
          const SizedBox(height: 4),
          // SSH key picker
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('SSH Key (optional)',
                  style: TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 6),
              if (_keys.isEmpty)
                const Text('No keys imported yet — go to Keys tab',
                    style: TextStyle(color: Color(0xFF444466), fontFamily: 'monospace', fontSize: 11))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _KeyChip(label: 'none', selected: _selectedKeyId == null,
                        onTap: () => setState(() => _selectedKeyId = null)),
                    ..._keys.map((k) => _KeyChip(
                      label: k.label,
                      selected: _selectedKeyId == k.id,
                      onTap: () => setState(() => _selectedKeyId = k.id),
                    )),
                  ],
                ),
            ]),
          ),
          const SizedBox(height: 10),
          _field(_script, 'Startup script (optional)', 'cd myproject'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF88),
                foregroundColor: const Color(0xFF0A0A0F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {
                if (_host.text.isEmpty || _user.text.isEmpty) return;
                widget.onAdd(ServerProfile(
                  id: '',
                  label: _label.text.isEmpty ? _host.text : _label.text,
                  host: _host.text.trim(),
                  username: _user.text.trim(),
                  port: int.tryParse(_port.text) ?? 22,
                  password: _pass.text.isEmpty ? null : _pass.text,
                  keyId: _selectedKeyId,
                  startupScript: _script.text.isEmpty ? null : _script.text,
                ));
                Navigator.pop(context);
              },
              child: Text(_isEdit ? 'Save' : 'Add server', style: const TextStyle(fontFamily: 'monospace')),
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
        controller: c,
        obscureText: obscure,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Color(0xFF666688), fontSize: 12),
          hintStyle: const TextStyle(color: Color(0xFF333355), fontSize: 12),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2A2A3E))),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF88))),
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00D4FF).withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: selected ? const Color(0xFF00D4FF) : const Color(0xFF2A2A3E),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? const Color(0xFF00D4FF) : const Color(0xFF666688),
              fontFamily: 'monospace',
              fontSize: 11,
            )),
      ),
    );
  }
}
