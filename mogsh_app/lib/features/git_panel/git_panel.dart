import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GitFileStatus {
  final String path;
  final String status; // M, A, D, ??
  bool staged;
  GitFileStatus({required this.path, required this.status, this.staged = false});
}

class GitPanelService {
  final String Function(String) _runInProot; // runs cmd in proot, returns stdout

  GitPanelService(this._runInProot);

  Future<List<GitFileStatus>> status() async {
    final out = _runInProot('git status --porcelain 2>/dev/null');
    return out.split('\n')
        .where((l) => l.length > 3)
        .map((l) => GitFileStatus(
          status: l.substring(0, 2).trim(),
          path: l.substring(3).trim(),
          staged: l[0] != ' ' && l[0] != '?',
        ))
        .toList();
  }

  Future<String> diff(String path) async =>
      _runInProot('git diff -- "$path" 2>/dev/null');

  Future<String> currentBranch() async =>
      _runInProot('git rev-parse --abbrev-ref HEAD 2>/dev/null').trim();

  Future<void> stage(String path) async =>
      _runInProot('git add -- "$path"');

  Future<void> unstage(String path) async =>
      _runInProot('git reset HEAD -- "$path"');

  Future<void> commit(String message) async =>
      _runInProot('git commit -m "${message.replaceAll('"', '\\"')}"');

  Future<void> push() async => _runInProot('git push');
}

class GitPanel extends StatefulWidget {
  final GitPanelService service;
  const GitPanel({super.key, required this.service});

  @override
  State<GitPanel> createState() => _GitPanelState();
}

class _GitPanelState extends State<GitPanel> {
  List<GitFileStatus> _files = [];
  String _branch = '';
  String? _diffContent;
  String? _diffPath;
  final _commitCtrl = TextEditingController();
  bool _pushing = false;

  @override
  void initState() { super.initState(); _refresh(); }

  Future<void> _refresh() async {
    final files = await widget.service.status();
    final branch = await widget.service.currentBranch();
    if (mounted) setState(() { _files = files; _branch = branch; });
  }

  Color _statusColor(String s) => switch (s) {
    'M' => AppColors.warning,
    'A' => AppColors.primary,
    'D' => AppColors.danger,
    _ => AppColors.textMuted,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Row(children: [
            const Icon(Icons.account_tree_outlined, color: AppColors.primary, size: 14),
            const SizedBox(width: 6),
            Text(_branch, style: const TextStyle(
                color: AppColors.primary, fontFamily: 'monospace', fontSize: 12)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.refresh, size: 14, color: AppColors.textMuted),
                onPressed: _refresh, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          ]),
        ),

        // File list
        Expanded(child: ListView.builder(
          itemCount: _files.length,
          itemBuilder: (_, i) {
            final f = _files[i];
            return ListTile(
              dense: true,
              onTap: () async {
                final diff = await widget.service.diff(f.path);
                setState(() { _diffContent = diff; _diffPath = f.path; });
              },
              leading: Text(f.status,
                  style: TextStyle(color: _statusColor(f.status), fontFamily: 'monospace', fontSize: 12)),
              title: Text(f.path, style: const TextStyle(
                  color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 11)),
              trailing: Checkbox(
                value: f.staged,
                activeColor: AppColors.primary,
                checkColor: AppColors.bg,
                onChanged: (v) async {
                  if (v == true) await widget.service.stage(f.path);
                  else await widget.service.unstage(f.path);
                  _refresh();
                },
              ),
            );
          },
        )),

        // Diff preview
        if (_diffContent != null)
          Container(
            height: 120,
            color: AppColors.bg,
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              child: Text(_diffContent!,
                  style: const TextStyle(color: AppColors.textSecondary,
                      fontFamily: 'monospace', fontSize: 10)),
            ),
          ),

        // Commit + push
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            TextField(
              controller: _commitCtrl,
              style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Commit message',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border2)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary)),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _btn('Commit', AppColors.primary, () async {
                if (_commitCtrl.text.isEmpty) return;
                await widget.service.commit(_commitCtrl.text);
                _commitCtrl.clear();
                _refresh();
              })),
              const SizedBox(width: 8),
              Expanded(child: _btn('Push', AppColors.secondary, () async {
                setState(() => _pushing = true);
                await widget.service.push();
                setState(() => _pushing = false);
              })),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _btn(String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.7)),
          borderRadius: BorderRadius.circular(3)),
      child: Center(child: Text(label,
          style: TextStyle(color: color, fontFamily: 'monospace', fontSize: 12))),
    ),
  );
}
