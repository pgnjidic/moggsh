import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/settings/settings_page.dart';
import 'features/settings/settings_service.dart';
import 'features/ssh/server_list_page.dart';
import 'features/ssh/services/ssh_key_manager.dart';
import 'features/terminal/multi_tab_screen.dart';
import 'features/terminal/tabs/tab_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  late final TabManager _tabManager;

  @override
  void initState() {
    super.initState();
    _tabManager = TabManager();
  }

  @override
  void dispose() {
    _tabManager.dispose();
    super.dispose();
  }

  void switchToTerminal() => setState(() => _tab = 0);

  static const _bg      = Color(0xFF0A0A0F);
  static const _surface = Color(0xFF12121A);
  static const _green   = Color(0xFF00FF88);
  static const _cyan    = Color(0xFF00D4FF);
  static const _muted   = Color(0xFF444466);
  static const _border  = Color(0xFF1E1E2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: ChangeNotifierProvider.value(
        value: _tabManager,
        child: IndexedStack(
        index: _tab,
        children: [
          const MultiTabScreen(),
          ServerListPage(tabManager: _tabManager, onConnected: switchToTerminal),
          const _KeysPage(),
          ChangeNotifierProvider(
            create: (_) => SettingsService()..init(),
            child: Consumer<SettingsService>(
              builder: (_, svc, _) => SettingsPage(service: svc),
            ),
          ),
        ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: _surface,
          border: Border(top: BorderSide(color: _border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _NavItem(icon: Icons.terminal, label: 'Terminal', active: _tab == 0,
                    color: _green, onTap: () => setState(() => _tab = 0)),
                _NavItem(icon: Icons.dns_outlined, label: 'Hosts', active: _tab == 1,
                    color: _cyan, onTap: () => setState(() => _tab = 1)),
                _NavItem(icon: Icons.vpn_key_outlined, label: 'Keys', active: _tab == 2,
                    color: _cyan, onTap: () => setState(() => _tab = 2)),
                _NavItem(icon: Icons.tune, label: 'Settings', active: _tab == 3,
                    color: _muted, onTap: () => setState(() => _tab = 3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon, required this.label, required this.active,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = active ? color : const Color(0xFF444466);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: c, fontSize: 10, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}

// ─── SSH Keys page ──────────────────────────────────────────────────────────

class _KeysPage extends StatefulWidget {
  const _KeysPage();

  @override
  State<_KeysPage> createState() => _KeysPageState();
}

class _KeysPageState extends State<_KeysPage> {
  List<SshKeyEntry> _keys = [];

  static const _bg     = Color(0xFF0A0A0F);
  static const _green  = Color(0xFF00FF88);
  static const _cyan   = Color(0xFF00D4FF);
  static const _muted  = Color(0xFF666688);
  static const _surface= Color(0xFF12121A);
  static const _border = Color(0xFF1E1E2E);
  static const _red    = Color(0xFFFF5555);

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final keys = await SshKeyManager.listAll();
    if (mounted) setState(() => _keys = keys);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(children: [
              const Text('SSH Keys',
                  style: TextStyle(color: _green, fontSize: 18,
                      fontFamily: 'monospace', letterSpacing: 1)),
              const Spacer(),
              GestureDetector(
                onTap: _showImportSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: _cyan),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.add, color: _cyan, size: 14),
                    SizedBox(width: 4),
                    Text('Import', style: TextStyle(color: _cyan,
                        fontSize: 12, fontFamily: 'monospace')),
                  ]),
                ),
              ),
            ]),
          ),

          if (_keys.isEmpty)
            Expanded(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.vpn_key_outlined, color: _muted, size: 48),
                  const SizedBox(height: 16),
                  const Text('No SSH keys yet',
                      style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 14)),
                  const SizedBox(height: 8),
                  const Text('Import a PEM private key to connect\nto servers without a password',
                      style: TextStyle(color: Color(0xFF444466), fontSize: 12, height: 1.6),
                      textAlign: TextAlign.center),
                ]),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _keys.length,
                itemBuilder: (_, i) {
                  final key = _keys[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _border),
                    ),
                    child: Row(children: [
                      const Icon(Icons.vpn_key, color: _cyan, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(key.label, style: const TextStyle(
                              color: Colors.white, fontFamily: 'monospace', fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            key.publicKey.length > 40
                                ? '${key.publicKey.substring(0, 40)}…'
                                : key.publicKey,
                            style: const TextStyle(color: _muted,
                                fontFamily: 'monospace', fontSize: 10),
                          ),
                        ],
                      )),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: _red, size: 18),
                        onPressed: () async {
                          await SshKeyManager.delete(key.id);
                          _load();
                        },
                      ),
                    ]),
                  );
                },
              ),
            ),
        ]),
      ),
    );
  }

  void _showImportSheet() {
    final pemCtrl = TextEditingController();
    final labelCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 20, left: 16, right: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Import SSH Key',
              style: TextStyle(color: _green, fontSize: 16, fontFamily: 'monospace')),
          const SizedBox(height: 16),
          TextField(
            controller: labelCtrl,
            style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Label (e.g. my-laptop)',
              hintStyle: TextStyle(color: _muted, fontSize: 13),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: _border)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _green)),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: pemCtrl,
            maxLines: 6,
            style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 11),
            decoration: const InputDecoration(
              hintText: '-----BEGIN OPENSSH PRIVATE KEY-----\n...',
              hintStyle: TextStyle(color: _muted, fontSize: 11),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: _border)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _green)),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: _bg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () async {
                try {
                  await SshKeyManager.importPem(
                      pemCtrl.text.trim(), labelCtrl.text.trim());
                  if (!mounted) return;
                  Navigator.pop(context);
                  _load();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error: $e',
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                    backgroundColor: _red,
                  ));
                }
              },
              child: const Text('Import', style: TextStyle(fontFamily: 'monospace')),
            ),
          ),
        ]),
      ),
    );
  }
}
