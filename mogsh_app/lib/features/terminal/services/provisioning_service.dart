import 'dart:async';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

enum ProvisioningStatus { idle, running, done, error }

class ToolInstallResult {
  final String name;
  final bool success;
  final String? version;
  final String? error;
  const ToolInstallResult({required this.name, required this.success, this.version, this.error});
}

/// Runs `apk add` inside the proot Alpine environment to install dev toolchain.
/// Uses PtermService indirectly via shell script execution.
class ProvisioningService {
  static const _storage = FlutterSecureStorage();
  static const _doneKey = 'provisioning_done_v1';

  // Ordered install list — apk packages + version check commands
  static const _tools = [
    _Tool('git',     'git',             'git --version'),
    _Tool('Node.js', 'nodejs npm',      'node --version'),
    _Tool('Python',  'python3 py3-pip', 'python3 --version'),
    _Tool('curl',    'curl',            'curl --version'),
    _Tool('bash',    'bash',            'bash --version'),
  ];

  final _progressController = StreamController<ProvisioningEvent>.broadcast();
  Stream<ProvisioningEvent> get events => _progressController.stream;

  ProvisioningStatus _status = ProvisioningStatus.idle;
  ProvisioningStatus get status => _status;

  Future<bool> needsProvisioning() async {
    final done = await _storage.read(key: _doneKey);
    return done == null;
  }

  /// Run provisioning — executes apk add inside rootfs via Process.run
  Future<List<ToolInstallResult>> provision() async {
    _status = ProvisioningStatus.running;
    final appDir = await getApplicationSupportDirectory();
    final prootPath = '${appDir.path}/bin/proot';
    final rootfsPath = '${appDir.path}/rootfs';

    // Check connectivity first
    try {
      final result = await InternetAddress.lookup('dl-cdn.alpinelinux.org');
      if (result.isEmpty) throw const SocketException('No internet');
    } on SocketException {
      _status = ProvisioningStatus.error;
      _progressController.add(ProvisioningEvent.error('No internet connection'));
      return [];
    }

    final results = <ToolInstallResult>[];

    // Update apk index first
    _progressController.add(ProvisioningEvent.progress('Updating package index...', 0.05));
    await _prootRun(prootPath, rootfsPath, 'apk update');

    for (int i = 0; i < _tools.length; i++) {
      final tool = _tools[i];
      final progress = 0.1 + (i / _tools.length) * 0.75;
      _progressController.add(ProvisioningEvent.progress('Installing ${tool.name}...', progress));

      try {
        final install = await _prootRun(prootPath, rootfsPath, 'apk add --no-cache ${tool.packages}');
        if (install.exitCode != 0) throw Exception(install.stderr);

        final versionResult = await _prootRun(prootPath, rootfsPath, tool.versionCmd);
        final version = versionResult.stdout.toString().split('\n').first.trim();

        results.add(ToolInstallResult(name: tool.name, success: true, version: version));
        _progressController.add(ProvisioningEvent.toolDone(tool.name, version));
      } catch (e) {
        results.add(ToolInstallResult(name: tool.name, success: false, error: e.toString()));
        _progressController.add(ProvisioningEvent.toolError(tool.name, e.toString()));
      }
    }

    final allOk = results.every((r) => r.success);
    if (allOk) {
      await _storage.write(key: _doneKey, value: DateTime.now().toIso8601String());
      _status = ProvisioningStatus.done;
      _progressController.add(ProvisioningEvent.progress('Done!', 1.0));
    } else {
      _status = ProvisioningStatus.error;
    }

    return results;
  }

  Future<ProcessResult> _prootRun(String proot, String rootfs, String cmd) {
    return Process.run(proot, [
      '--rootfs=$rootfs', '-0', '-w', '/root',
      '--bind=/dev', '--bind=/proc',
      '/bin/sh', '-c', cmd,
    ]);
  }

  void dispose() => _progressController.close();
}

class _Tool {
  final String name;
  final String packages;
  final String versionCmd;
  const _Tool(this.name, this.packages, this.versionCmd);
}

class ProvisioningEvent {
  final String type;
  final String message;
  final double? progress;
  final String? toolName;
  final String? version;

  const ProvisioningEvent._({
    required this.type, required this.message,
    this.progress, this.toolName, this.version,
  });

  factory ProvisioningEvent.progress(String msg, double p) =>
      ProvisioningEvent._(type: 'progress', message: msg, progress: p);
  factory ProvisioningEvent.toolDone(String tool, String ver) =>
      ProvisioningEvent._(type: 'tool_done', message: tool, toolName: tool, version: ver);
  factory ProvisioningEvent.toolError(String tool, String err) =>
      ProvisioningEvent._(type: 'tool_error', message: err, toolName: tool);
  factory ProvisioningEvent.error(String msg) =>
      ProvisioningEvent._(type: 'error', message: msg);
}
