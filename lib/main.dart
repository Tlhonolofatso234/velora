import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'theme/theme.dart';

void main() {
  runApp(const ProviderScope(child: VeloraApp()));
}

class VeloraApp extends StatelessWidget {
  const VeloraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velora',
      debugShowCheckedModeBanner: false,
      theme: VeloraTheme.light,
      home: const HomeScreen(),
    );
  }
}
