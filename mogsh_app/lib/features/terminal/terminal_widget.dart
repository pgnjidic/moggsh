import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef OnInputCallback  = void Function(String data);
typedef OnResizeCallback = void Function(int cols, int rows);
typedef OnReadyCallback  = void Function();

class TerminalWidget extends StatefulWidget {
  final OnInputCallback?  onInput;
  final OnResizeCallback? onResize;
  final OnReadyCallback?  onReady;

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

  // Output batching — flush every 16ms instead of one runJavaScript per chunk
  final StringBuffer _buf = StringBuffer();
  Timer? _flushTimer;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0A0A0F))
      ..addJavaScriptChannel('FlutterChannel', onMessageReceived: _onMessage)
      ..loadFlutterAsset('assets/terminal/index.html');
  }

  @override
  void dispose() {
    _flushTimer?.cancel();
    super.dispose();
  }

  void _onMessage(JavaScriptMessage message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message.message);
      switch (data['type'] as String?) {
        case 'ready':
          if (_ready) return; // guard against double-fire
          _ready = true;
          widget.onReady?.call();
        case 'input':
          widget.onInput?.call(data['data'] as String);
        case 'resize':
          widget.onResize?.call(data['cols'] as int, data['rows'] as int);
      }
    } catch (_) {}
  }

  /// Buffer data and flush in one JS call per frame (~16ms)
  void write(String data) {
    if (!_ready) return;
    _buf.write(data);
    _flushTimer ??= Timer(const Duration(milliseconds: 16), _flush);
  }

  void _flush() {
    _flushTimer = null;
    if (_buf.isEmpty) return;
    final chunk = _buf.toString();
    _buf.clear();
    // jsonEncode handles all special chars (\r \n \x1b quotes etc.) safely
    _controller.runJavaScript('termWrite(${jsonEncode(chunk)})');
  }

  void writeln(String data) => write('$data\r\n');

  void clear() {
    if (!_ready) return;
    _controller.runJavaScript('termClear()');
  }

  void setFontSize(int size) {
    if (!_ready) return;
    _controller.runJavaScript('termSetFontSize($size)');
  }

  void search(String query) {
    if (!_ready) return;
    _controller.runJavaScript('termSearch(${jsonEncode(query)})');
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _controller);
}
