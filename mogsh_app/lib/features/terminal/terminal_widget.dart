import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Callback types
typedef OnInputCallback = void Function(String data);
typedef OnResizeCallback = void Function(int cols, int rows);
typedef OnReadyCallback = void Function();

class TerminalWidget extends StatefulWidget {
  final OnInputCallback? onInput;
  final OnResizeCallback? onResize;
  final OnReadyCallback? onReady;

  const TerminalWidget({
    super.key,
    this.onInput,
    this.onResize,
    this.onReady,
  });

  @override
  State<TerminalWidget> createState() => TerminalWidgetState();
}

class TerminalWidgetState extends State<TerminalWidget> {
  late final WebViewController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0A0A0F))
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: _onMessage,
      )
      ..loadFlutterAsset('assets/terminal/index.html');
  }

  void _onMessage(JavaScriptMessage message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message.message);
      final type = data['type'] as String?;
      switch (type) {
        case 'ready':
          _ready = true;
          widget.onReady?.call();
        case 'input':
          widget.onInput?.call(data['data'] as String);
        case 'resize':
          widget.onResize?.call(
            data['cols'] as int,
            data['rows'] as int,
          );
      }
    } catch (_) {}
  }

  /// Write raw data/ANSI sequences to the terminal
  void write(String data) {
    if (!_ready) return;
    final escaped = data
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\r', '\\r')
        .replaceAll('\n', '\\n');
    _controller.runJavaScript("termWrite('$escaped')");
  }

  /// Write a line with newline
  void writeln(String data) => write('$data\r\n');

  /// Clear the terminal
  void clear() {
    if (!_ready) return;
    _controller.runJavaScript('termClear()');
  }

  /// Set font size (11–18px)
  void setFontSize(int size) {
    if (!_ready) return;
    _controller.runJavaScript('termSetFontSize($size)');
  }

  /// Search terminal content
  void search(String query) {
    if (!_ready) return;
    final escaped = query.replaceAll("'", "\\'");
    _controller.runJavaScript("termSearch('$escaped')");
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
