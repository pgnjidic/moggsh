import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
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
      bottomNavigationBar: _BottomNav(
        current: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(children: [
            _NavItem(icon: Icons.terminal_rounded, label: 'Terminal', active: current == 0,
                activeColor: AppColors.teal, onTap: () => onTap(0)),
            _NavItem(icon: Icons.dns_rounded, label: 'Hosts', active: current == 1,
                activeColor: AppColors.blue, onTap: () => onTap(1)),
            _NavItem(icon: Icons.vpn_key_rounded, label: 'Keys', active: current == 2,
                activeColor: AppColors.amber, onTap: () => onTap(2)),
            _NavItem(icon: Icons.tune_rounded, label: 'Settings', active: current == 3,
                activeColor: AppColors.green, onTap: () => onTap(3)),
          ]),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.active,
      required this.activeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : AppColors.textMuted.withValues(alpha: 0.55);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 20,
              shadows: active ? [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 8)] : null),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(
            color: color, fontSize: 9.5, fontFamily: 'monospace',
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            letterSpacing: 0.3,
          )),
        ]),
      ),
    );
  }
}

// ── SSH Keys page ─────────────────────────────────────────────────────────

class _KeysPage extends StatefulWidget {
  const _KeysPage();

  @override
  State<_KeysPage> createState() => _KeysPageState();
}

class _KeysPageState extends State<_KeysPage> {
  List<SshKeyEntry> _keys = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final keys = await SshKeyManager.listAll();
    if (mounted) setState(() => _keys = keys);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(children: [
              const Text('Keys', style: TextStyle(color: AppColors.textPrimary,
                  fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
              const Spacer(),
              GestureDetector(
                onTap: _showImportSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.blue.withValues(alpha: 0.35)),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.add, color: AppColors.teal, size: 13),
                    SizedBox(width: 4),
                    Text('Import', style: TextStyle(color: AppColors.teal,
                        fontSize: 12, fontFamily: 'monospace')),
                  ]),
                ),
              ),
            ]),
          ),
          if (_keys.isEmpty)
            Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.vpn_key_outlined, color: AppColors.textMuted.withValues(alpha: 0.4), size: 48),
              const SizedBox(height: 16),
              const Text('No SSH keys yet',
                  style: TextStyle(color: AppColors.textMuted, fontFamily: 'monospace', fontSize: 13)),
              const SizedBox(height: 6),
              const Text('Import a PEM private key',
                  style: TextStyle(color: AppColors.textMuted, fontFamily: 'monospace', fontSize: 11)),
            ])))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                itemCount: _keys.length,
                itemBuilder: (_, i) {
                  final key = _keys[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface2.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.vpn_key_outlined, color: AppColors.amber, size: 15),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(key.label, style: const TextStyle(
                            color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 12,
                            fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(
                          key.publicKey.length > 36
                              ? '${key.publicKey.substring(0, 36)}…'
                              : key.publicKey,
                          style: const TextStyle(color: AppColors.textMuted,
                              fontFamily: 'monospace', fontSize: 9),
                        ),
                      ])),
                      GestureDetector(onTap: () => _showRenameDialog(key),
                          child: const Padding(padding: EdgeInsets.all(6),
                              child: Icon(Icons.edit_outlined, color: AppColors.textMuted, size: 15))),
                      GestureDetector(
                        onTap: () async { await SshKeyManager.delete(key.id); _load(); },
                        child: const Padding(padding: EdgeInsets.all(6),
                            child: Icon(Icons.delete_outline, color: AppColors.red, size: 15)),
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

  void _showRenameDialog(SshKeyEntry key) {
    final ctrl = TextEditingController(text: key.label);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Rename key',
            style: TextStyle(color: AppColors.green, fontFamily: 'monospace', fontSize: 14)),
        content: TextField(
          controller: ctrl, autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 13),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.green)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
          TextButton(
            onPressed: () async {
              final label = ctrl.text.trim();
              if (label.isNotEmpty) {
                await SshKeyManager.rename(key.id, label);
                if (mounted) { Navigator.pop(context); _load(); }
              }
            },
            child: const Text('Save', style: TextStyle(color: AppColors.green)),
          ),
        ],
      ),
    );
  }

  void _showImportSheet() {
    final pemCtrl   = TextEditingController();
    final labelCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16, top: 20, left: 16, right: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Import SSH Key',
              style: TextStyle(color: AppColors.green, fontSize: 15, fontFamily: 'monospace')),
          const SizedBox(height: 16),
          TextField(
            controller: labelCtrl,
            style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Label (e.g. my-laptop)',
              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.green)),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: pemCtrl, maxLines: 6,
            style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 11),
            decoration: const InputDecoration(
              hintText: '-----BEGIN OPENSSH PRIVATE KEY-----\n...',
              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 11),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.green)),
              contentPadding: EdgeInsets.all(10),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green, foregroundColor: AppColors.bg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () async {
                try {
                  await SshKeyManager.importPem(pemCtrl.text.trim(), labelCtrl.text.trim());
                  if (!mounted) return;
                  Navigator.pop(context);
                  _load();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error: $e', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                    backgroundColor: AppColors.red,
                  ));
                }
              },
              child: const Text('Import', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }
}
