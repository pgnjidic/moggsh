import 'package:flutter/material.dart';
import 'models/server_profile.dart';
import 'services/server_profile_service.dart';
import 'services/ssh_session.dart';
import 'widgets/tmux_picker.dart';

class ServerListPage extends StatefulWidget {
  const ServerListPage({super.key});

  @override
  State<ServerListPage> createState() => _ServerListPageState();
}

class _ServerListPageState extends State<ServerListPage> {
  final _service = ServerProfileService();
  List<ServerProfile> _profiles = [];

  static const _green  = Color(0xFF00FF88);
  static const _bg     = Color(0xFF0A0A0F);
  static const _muted  = Color(0xFF666688);

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await _service.loadAll();
    if (mounted) setState(() => _profiles = p);
  }

  Future<void> _connect(ServerProfile profile) async {
    final session = SshSession(profile);
    await session.connect();

    // Check tmux sessions
    if (session.state == SshConnectionState.connected) {
      final tmuxSessions = await session.listTmuxSessions();

      if (!mounted) return;
      if (tmuxSessions.isNotEmpty && (profile.startupScript == null || profile.startupScript!.isEmpty)) {
        showModalBottomSheet(
          context: context,
          builder: (_) => TmuxPickerSheet(
            sessions: tmuxSessions,
            onSelect: (s) {
              if (s != null) session.attachTmux(s);
              _openTerminal(session, profile);
            },
          ),
        );
      } else {
        _openTerminal(session, profile);
      }

      // Update last connected
      profile.lastConnected = DateTime.now();
      await _service.update(profile);
    }
  }

  void _openTerminal(SshSession session, ServerProfile profile) {
    // Push SSH tab into TabManager — for now Navigator placeholder
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _SshTerminalPage(session: session, title: profile.label),
    ));
  }

  void _showAddDialog() {
    showModalBottomSheet(context: context, isScrollControlled: true,
        backgroundColor: const Color(0xFF12121A),
        builder: (_) => _AddServerSheet(onAdd: (p) async {
          await _service.add(
            label: p.label, host: p.host, username: p.username,
            port: p.port, password: p.password, keyId: p.keyId,
            startupScript: p.startupScript,
          );
          _load();
        }));
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
                      style: TextStyle(color: _green, fontSize: 18, fontFamily: 'monospace', letterSpacing: 2)),
                  IconButton(
                    icon: const Icon(Icons.add, color: _green),
                    onPressed: _showAddDialog,
                  ),
                ],
              ),
            ),
            if (_profiles.isEmpty)
              Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.dns_outlined, color: Color(0xFF333355), size: 48),
                const SizedBox(height: 12),
                const Text('No servers yet', style: TextStyle(color: _muted, fontFamily: 'monospace')),
                const SizedBox(height: 8),
                TextButton(onPressed: _showAddDialog,
                    child: const Text('+ Add server', style: TextStyle(color: _green, fontFamily: 'monospace'))),
              ])))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _profiles.length,
                  itemBuilder: (_, i) => _ServerTile(
                    profile: _profiles[i],
                    onTap: () => _connect(_profiles[i]),
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
  final VoidCallback onDelete;

  const _ServerTile({required this.profile, required this.onTap, required this.onDelete});

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
  const _AddServerSheet({required this.onAdd});

  @override
  State<_AddServerSheet> createState() => _AddServerSheetState();
}

class _AddServerSheetState extends State<_AddServerSheet> {
  final _host = TextEditingController();
  final _user = TextEditingController(text: 'root');
  final _port = TextEditingController(text: '22');
  final _label = TextEditingController();
  final _pass = TextEditingController();
  final _script = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Add server',
              style: TextStyle(color: Color(0xFF00FF88), fontFamily: 'monospace', fontSize: 16)),
          const SizedBox(height: 16),
          _field(_label, 'Label', 'My VPS'),
          _field(_host, 'Host', '1.2.3.4'),
          Row(children: [
            Expanded(child: _field(_user, 'User', 'root')),
            const SizedBox(width: 8),
            SizedBox(width: 80, child: _field(_port, 'Port', '22', keyboard: TextInputType.number)),
          ]),
          _field(_pass, 'Password (optional)', '', obscure: true),
          _field(_script, 'Startup script (optional)', 'cd myproject'),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF88),
                foregroundColor: const Color(0xFF0A0A0F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            onPressed: () {
              if (_host.text.isEmpty || _user.text.isEmpty) return;
              widget.onAdd(ServerProfile(
                id: '', label: _label.text.isEmpty ? _host.text : _label.text,
                host: _host.text.trim(), username: _user.text.trim(),
                port: int.tryParse(_port.text) ?? 22,
                password: _pass.text.isEmpty ? null : _pass.text,
                startupScript: _script.text.isEmpty ? null : _script.text,
              ));
              Navigator.pop(context);
            },
            child: const Text('Add server', style: TextStyle(fontFamily: 'monospace')),
          )),
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

// Minimal SSH terminal page — reuses TerminalWidget
class _SshTerminalPage extends StatefulWidget {
  final SshSession session;
  final String title;
  const _SshTerminalPage({required this.session, required this.title});

  @override
  State<_SshTerminalPage> createState() => _SshTerminalPageState();
}

class _SshTerminalPageState extends State<_SshTerminalPage> {

  @override
  void dispose() { widget.session.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0A0A0F),
    appBar: AppBar(
      backgroundColor: const Color(0xFF0A0A0F),
      title: Text(widget.title,
          style: const TextStyle(color: Color(0xFF00FF88), fontFamily: 'monospace', fontSize: 13)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF666688)),
        onPressed: () { widget.session.disconnect(); Navigator.pop(context); },
      ),
    ),
    body: const Center(child: Text('Terminal here', style: TextStyle(color: Color(0xFF444466)))),
  );
}
