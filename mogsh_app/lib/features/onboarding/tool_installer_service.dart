import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

enum InstallState { idle, installing, installed, failed }

class CliTool {
  final String id;
  final String label;
  final String description;
  final String installCmd;   // runs inside proot
  final String versionCmd;
  final String? oauthUrl;    // if tool needs OAuth

  InstallState state;
  String? version;
  String? error;

  CliTool({
    required this.id,
    required this.label,
    required this.description,
    required this.installCmd,
    required this.versionCmd,
    this.oauthUrl,
    this.state = InstallState.idle,
  });
}

class ToolInstallerService {
  static const _storage = FlutterSecureStorage();

  final _tools = [
    CliTool(
      id: 'claude',
      label: 'Claude Code',
      description: 'AI coding agent by Anthropic',
      installCmd: 'npm install -g @anthropic-ai/claude-code',
      versionCmd: 'claude --version',
      oauthUrl: 'https://claude.ai/oauth/authorize?client_id=mogsh&redirect_uri=mogsh://oauth/claude',
    ),
    CliTool(
      id: 'gh',
      label: 'GitHub CLI',
      description: 'Create PRs, manage repos',
      installCmd: 'apk add --no-cache github-cli',
      versionCmd: 'gh --version',
      oauthUrl: 'https://github.com/login/oauth/authorize?client_id=Ov23liXyzPlaceholder&redirect_uri=mogsh://oauth/github&scope=repo',
    ),
    CliTool(
      id: 'lazygit',
      label: 'lazygit',
      description: 'TUI git client',
      installCmd: 'apk add --no-cache lazygit',
      versionCmd: 'lazygit --version',
    ),
    CliTool(
      id: 'neovim',
      label: 'Neovim',
      description: 'Terminal editor',
      installCmd: 'apk add --no-cache neovim',
      versionCmd: 'nvim --version',
    ),
  ];

  List<CliTool> get tools => List.unmodifiable(_tools);

  final _stateController = StreamController<List<CliTool>>.broadcast();
  Stream<List<CliTool>> get toolsStream => _stateController.stream;

  StreamSubscription<Uri>? _deepLinkSub;
  final _oauthCompleter = <String, Completer<String>>{};

  Future<void> init() async {
    // Restore installed state from storage
    for (final tool in _tools) {
      final saved = await _storage.read(key: 'tool_${tool.id}_version');
      if (saved != null) {
        tool.state = InstallState.installed;
        tool.version = saved;
      }
    }
    _emit();

    // Listen for OAuth deep links: mogsh://oauth/<tool_id>?token=...
    _deepLinkSub = AppLinks().uriLinkStream.listen((uri) {
      if (uri.scheme == 'mogsh' && uri.host == 'oauth') {
        final toolId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
        final token = uri.queryParameters['token'] ?? uri.fragment;
        _oauthCompleter[toolId]?.complete(token);
      }
    });
  }

  Future<void> install(CliTool tool) async {
    tool.state = InstallState.installing;
    tool.error = null;
    _emit();

    try {
      final appDir = await getApplicationSupportDirectory();
      final prootPath = '${appDir.path}/bin/proot';
      final rootfsPath = '${appDir.path}/rootfs';

      final result = await Process.run(prootPath, [
        '--rootfs=$rootfsPath', '-0', '-w', '/root',
        '--bind=/dev', '--bind=/proc',
        '/bin/sh', '-c', tool.installCmd,
      ]);

      if (result.exitCode != 0) throw Exception(result.stderr.toString().trim());

      final vResult = await Process.run(prootPath, [
        '--rootfs=$rootfsPath', '-0', '-w', '/root',
        '--bind=/dev', '--bind=/proc',
        '/bin/sh', '-c', tool.versionCmd,
      ]);

      tool.version = vResult.stdout.toString().split('\n').first.trim();
      tool.state = InstallState.installed;
      await _storage.write(key: 'tool_${tool.id}_version', value: tool.version);
    } catch (e) {
      tool.state = InstallState.failed;
      tool.error = e.toString();
    }

    _emit();
  }

  /// Open OAuth URL in browser, wait for deep link callback
  Future<String?> authenticate(CliTool tool) async {
    if (tool.oauthUrl == null) return null;

    final completer = Completer<String>();
    _oauthCompleter[tool.id] = completer;

    await launchUrl(Uri.parse(tool.oauthUrl!), mode: LaunchMode.externalApplication);

    try {
      final token = await completer.future.timeout(const Duration(minutes: 5));
      await _storage.write(key: 'oauth_${tool.id}', value: token);
      return token;
    } on TimeoutException {
      return null;
    } finally {
      _oauthCompleter.remove(tool.id);
    }
  }

  Future<String?> getToken(String toolId) =>
      _storage.read(key: 'oauth_$toolId');

  void _emit() => _stateController.add(_tools);

  void dispose() {
    _deepLinkSub?.cancel();
    _stateController.close();
  }
}
