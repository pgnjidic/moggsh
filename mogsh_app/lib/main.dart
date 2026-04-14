import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const ProviderScope(child: MogshApp()));
}

class MogshApp extends StatelessWidget {
  const MogshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mogsh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const Scaffold(
        backgroundColor: Color(0xFF0A0A0F),
        body: Center(
          child: Text(
            'mogsh',
            style: TextStyle(
              color: Color(0xFF00FF88),
              fontSize: 32,
              fontFamily: 'monospace',
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }
}
