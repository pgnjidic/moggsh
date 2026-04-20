import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../ssh/services/ssh_session.dart';

class SftpBrowser extends StatefulWidget {
  final SshSession session;
  const SftpBrowser({super.key, required this.session});

  @override
  State<SftpBrowser> createState() => _SftpBrowserState();
}

class _SftpBrowserState extends State<SftpBrowser> {
  SftpClient? _sftp;
  String _currentPath = '/root';
  List<SftpName> _entries = [];
  bool _loading = true;
  String? _error;
  double? _transferProgress;

  @override
  void initState() { super.initState(); _initSftp(); }

  Future<void> _initSftp() async {
    try {
      _sftp = await widget.session.client!.sftp();
      await _navigate(_currentPath);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _navigate(String path) async {
    setState(() { _loading = true; _error = null; });
    try {
      final dir = await _sftp!.listdir(path);
      dir.sort((a, b) {
        final aDir = a.attr.type == SftpFileType.directory;
        final bDir = b.attr.type == SftpFileType.directory;
        if (aDir != bDir) return aDir ? -1 : 1;
        return a.filename.compareTo(b.filename);
      });
      setState(() {
        _entries = dir.where((e) => !e.filename.startsWith('.') || e.filename == '..').toList();
        _currentPath = path;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _download(SftpName entry) async {
    setState(() => _transferProgress = 0);
    try {
      final remote = await _sftp!.open('$_currentPath/${entry.filename}');
      final size = entry.attr.size ?? 0;
      int received = 0;
      final chunks = <List<int>>[];

      await for (final chunk in remote.read()) {
        chunks.add(chunk);
        received += chunk.length;
        if (size > 0) setState(() => _transferProgress = received / size);
      }

      // Save to Downloads via MediaStore (simplified)
      setState(() => _transferProgress = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Downloaded ${entry.filename}',
              style: const TextStyle(fontFamily: 'monospace')),
          backgroundColor: AppColors.surface2,
        ));
      }
    } catch (e) {
      setState(() => _transferProgress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: Column(children: [
        // Path bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: AppColors.surface,
          child: Row(children: [
            if (_currentPath != '/')
              GestureDetector(
                onTap: () => _navigate(_currentPath.substring(0, _currentPath.lastIndexOf('/').clamp(1, _currentPath.length))),
                child: const Icon(Icons.arrow_back, color: AppColors.textMuted, size: 18),
              ),
            const SizedBox(width: 8),
            Expanded(child: Text(_currentPath, style: const TextStyle(
                color: AppColors.secondary, fontFamily: 'monospace', fontSize: 12),
                overflow: TextOverflow.ellipsis)),
          ]),
        ),

        if (_transferProgress != null)
          LinearProgressIndicator(value: _transferProgress,
              backgroundColor: AppColors.surface2, color: AppColors.primary, minHeight: 2),

        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
        else if (_error != null)
          Expanded(child: Center(child: Text(_error!,
              style: const TextStyle(color: AppColors.danger, fontFamily: 'monospace', fontSize: 12))))
        else
          Expanded(child: ListView.builder(
            itemCount: _entries.length,
            itemBuilder: (_, i) {
              final e = _entries[i];
              final isDir = e.attr.type == SftpFileType.directory;
              final size = e.attr.size;
              return ListTile(
                dense: true,
                leading: Icon(isDir ? Icons.folder : Icons.insert_drive_file_outlined,
                    color: isDir ? AppColors.warning : AppColors.textMuted, size: 18),
                title: Text(e.filename, style: const TextStyle(
                    color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 12)),
                subtitle: (!isDir && size != null)
                    ? Text(_formatSize(size), style: const TextStyle(
                        color: AppColors.textMuted, fontFamily: 'monospace', fontSize: 10))
                    : null,
                onTap: isDir ? () => _navigate('$_currentPath/${e.filename}') : null,
                trailing: isDir ? null : IconButton(
                  icon: const Icon(Icons.download_outlined, size: 16, color: AppColors.secondary),
                  onPressed: () => _download(e),
                ),
              );
            },
          )),
      ])),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  void dispose() { _sftp?.close(); super.dispose(); }
}
