import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/scan_flow_provider.dart';
import '../theme/colors.dart';
import '../theme/theme.dart';
import '../widgets/velora_button.dart';
import 'capture_screen.dart';
import 'home_screen.dart';

class ScanErrorScreen extends ConsumerWidget {
  const ScanErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanFlowProvider);
    final message = state is ScanFailure ? state.message : 'Something went wrong.';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Scan', style: VeloraTheme.body(size: 13)),
              const SizedBox(height: 4),
              Text("Couldn't get a clear read", style: VeloraTheme.display(size: 20)),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: VeloraColors.ironTint),
                      child: const Icon(Icons.refresh, color: VeloraColors.iron, size: 32),
                    ),
                    const SizedBox(height: 18),
                    Text(message, textAlign: TextAlign.center, style: VeloraTheme.body(size: 13)),
                  ],
                ),
              ),
              const Spacer(),
              VeloraButton(
                label: 'Try again',
                variant: VeloraButtonVariant.secondary,
                expand: true,
                onPressed: () {
                  ref.read(scanFlowProvider.notifier).reset();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const CaptureScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 10),
              VeloraButton(
                label: 'Cancel',
                variant: VeloraButtonVariant.secondary,
                expand: true,
                onPressed: () {
                  ref.read(scanFlowProvider.notifier).reset();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
