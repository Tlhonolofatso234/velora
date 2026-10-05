import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/scan_flow_provider.dart';
import '../theme/colors.dart';
import '../theme/theme.dart';
import 'diagnosis_screen.dart';
import 'error_screen.dart';

class AnalyzingScreen extends ConsumerWidget {
  const AnalyzingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Navigate the moment the state machine resolves — this screen
    // doesn't run its own timer or fake progress, it just reflects
    // scanFlowProvider's current state.
    ref.listen<ScanFlowState>(scanFlowProvider, (previous, next) {
      if (next is ScanSuccess) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DiagnosisScreen()),
        );
      } else if (next is ScanFailure) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ScanErrorScreen()),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Reading your photo', style: VeloraTheme.body(size: 13)),
              const SizedBox(height: 4),
              Text('One moment', style: VeloraTheme.display(size: 24)),
              const SizedBox(height: 32),
              const Center(child: CircularProgressIndicator(color: VeloraColors.iron)),
              const SizedBox(height: 32),
              Text(
                'Comparing your photo against known field issues…',
                style: VeloraTheme.body(size: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
