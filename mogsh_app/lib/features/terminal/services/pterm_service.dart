import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// ignore: constant_identifier_names
const _platform = MethodChannel('app.mogsh.terminal/service');

/// proot + Alpine Linux environment manager.
/// Downloads and extracts Alpine rootfs + proot binary on first run,
/// then launches a PTY session inside the chroot.
class PtermService {
  static const _prootUrl =
      'https://github.com/termux/proot/releases/download/v5.3.0/proot-aarch64';
  static const _alpineUrl =
      'https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/aarch64/alpine-minirootfs-3.20.0-aarch64.tar.gz';

  Pty? _pty;
  final _outputController = StreamController<String>.broadcast();

  /// Raw terminal output stream
  Stream<String> get output => _outputController.stream;

  bool _running = false;
  bool get isRunning => _running;

  // Fires when PTY dies unexpectedly
  final _crashController = StreamController<void>.broadcast();
  Stream<void> get onCrash => _crashController.stream;

  /// Check if first-run setup is needed
  Future<bool> needsSetup() async {
    final dir = await _rootfsDir();
    final marker = File('${dir.path}/.setup_complete');
    return !marker.existsSync();
  }

  /// First-run setup: download proot + Alpine rootfs with progress callback.
  /// [onProgress] receives (label, 0.0–1.0)
  Future<void> setup({
    required void Function(String label, double progress) onProgress,
  }) async {
    final appDir = await getApplicationSupportDirectory();
    final rootfsDir = Directory('${appDir.path}/rootfs');
    final binDir = Directory('${appDir.path}/bin');
    rootfsDir.createSync(recursive: true);
    binDir.createSync(recursive: true);

    // 1. Download proot binary
    onProgress('Downloading proot...', 0.05);
    final prootFile = File('${binDir.path}/proot');
    if (!prootFile.existsSync()) {
      await _downloadFile(_prootUrl, prootFile, (p) {
        onProgress('Downloading proot...', 0.05 + p * 0.2);
      });
      await Process.run('chmod', ['+x', prootFile.path]);
    }

    // 2. Download Alpine rootfs
    onProgress('Downloading Alpine Linux...', 0.25);
    final tarFile = File('${appDir.path}/alpine.tar.gz');
    if (!tarFile.existsSync()) {
      await _downloadFile(_alpineUrl, tarFile, (p) {
        onProgress('Downloading Alpine Linux...', 0.25 + p * 0.45);
      });
    }

    // 3. Extract rootfs
    onProgress('Extracting filesystem...', 0.70);
    await _extractTarGz(tarFile, rootfsDir);
    tarFile.deleteSync();

    // 4. Mark setup complete
    File('${rootfsDir.path}/.setup_complete').writeAsStringSync('ok');
    onProgress('Done!', 1.0);
  }

  /// Start a proot shell session
  Future<void> start() async {
    if (_running) return;

    final appDir = await getApplicationSupportDirectory();
    final prootPath = '${appDir.path}/bin/proot';
    final rootfsPath = '${appDir.path}/rootfs';

    _pty = Pty.start(
      prootPath,
      arguments: [
        '--rootfs=$rootfsPath',
        '-0',                    // fake root
        '-w', '/root',           // working dir
        '--bind=/dev',
        '--bind=/proc',
        '--bind=/sys',
        '/bin/sh',               // Alpine uses sh by default; bash installable later
      ],
      environment: {
        'TERM': 'xterm-256color',
        'HOME': '/root',
        'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        'SHELL': '/bin/sh',
        'LANG': 'en_US.UTF-8',
      },
      columns: 80,
      rows: 24,
    );

    _running = true;

    // Start foreground service to keep session alive
    if (Platform.isAndroid) {
      _platform.invokeMethod('startForeground').catchError((_) {});
    }

    _pty!.output
        .cast<List<int>>()
        .transform(const Utf8Decoder(allowMalformed: true) as StreamTransformer<List<int>, String>)
        .listen(
          (data) => _outputController.add(data),
          onDone: () {
            _running = false;
            if (Platform.isAndroid) {
              _platform.invokeMethod('stopForeground').catchError((_) {});
            }
            _crashController.add(null);
          },
        );
  }

  /// Send Ctrl+C (ETX) to interrupt active process
  void sendCtrlC() => write('\x03');

  /// Restart the shell after crash
  Future<void> restart() => start();

  /// Send input to the PTY (keyboard data)
  void write(String data) {
    _pty?.write(const Utf8Encoder().convert(data));
  }

  /// Resize PTY
  void resize(int cols, int rows) {
    _pty?.resize(rows, cols);
  }

  /// Stop the session
  void stop() {
    _pty?.kill();
    _running = false;
  }

  void dispose() {
    stop();
    _outputController.close();
    _crashController.close();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Future<Directory> _rootfsDir() async {
    final appDir = await getApplicationSupportDirectory();
    return Directory('${appDir.path}/rootfs');
  }

  Future<void> _downloadFile(
    String url,
    File dest,
    void Function(double) onProgress,
  ) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);
      final total = response.contentLength ?? 0;
      int received = 0;
      final sink = dest.openWrite();
      await response.stream.listen((chunk) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress(received / total);
      }).asFuture();
      await sink.close();
    } finally {
      client.close();
    }
  }

  Future<void> _extractTarGz(File tarGz, Directory dest) async {
    // Use system tar for large archives (more efficient than pure-Dart)
    final result = await Process.run('tar', [
      'xzf', tarGz.path,
      '-C', dest.path,
      '--no-same-owner',
    ]);
    if (result.exitCode != 0) {
      throw Exception('tar extraction failed: ${result.stderr}');
    }
  }
}
