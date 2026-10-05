import 'package:flutter/material.dart';
import '../shapes/cut_corner_border.dart';
import '../theme/colors.dart';
import '../theme/theme.dart';
import 'capture_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('VELORA', style: VeloraTheme.label(size: 13, weight: FontWeight.w800, color: VeloraColors.ink)),
              const SizedBox(height: 40),
              Text('Good morning', style: VeloraTheme.body(size: 13)),
              const SizedBox(height: 4),
              Text('What can I help with?', style: VeloraTheme.display(size: 26)),
              const Spacer(),
              CutCornerContainer(
                color: VeloraColors.ink,
                padding: const EdgeInsets.all(22),
                side: BorderSide.none,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Scan a crop',
                        style: VeloraTheme.display(size: 19, weight: FontWeight.w800).copyWith(color: VeloraColors.white)),
                    const SizedBox(height: 6),
                    Text('Diagnose an issue in under a minute',
                        style: VeloraTheme.body(size: 12.5, color: VeloraColors.white.withValues())),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CaptureScreen()),
                      ),
                      child: CutCornerContainer(
                        color: VeloraColors.white,
                        cut: 10,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text('Open camera →',
                            style: VeloraTheme.label(size: 12.5, weight: FontWeight.w700, color: VeloraColors.ink)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
