import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velora/models/severity.dart';
import '../models/action_step.dart';
import '../models/diagnosis_result.dart';
import '../shapes/cut_corner_border.dart';
import '../state/scan_flow_provider.dart';
import '../theme/colors.dart';
import '../theme/theme.dart';
import '../widgets/severity_chip.dart';
import '../widgets/velora_button.dart';
import 'home_screen.dart';

class DiagnosisScreen extends ConsumerWidget {
  const DiagnosisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanFlowProvider);

    // DiagnosisScreen is only ever pushed from AnalyzingScreen after a
    // ScanSuccess, but guard anyway — cheap insurance against a stale
    // navigation stack after a hot restart.
    if (state is! ScanSuccess) {
      return const Scaffold(body: Center(child: Text('No diagnosis to show.')));
    }
    final DiagnosisResult result = state.result;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CutCornerContainer(
              height: 180,
              color: VeloraColors.surface,
              side: BorderSide(color: result.severity.color, width: 4),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SeverityChip(severity: result.severity),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(result.diagnosisName, style: VeloraTheme.display(size: 24)),
            if (result.latinName != null) ...[
              const SizedBox(height: 4),
              Text(result.latinName!, style: VeloraTheme.body(size: 12.5, weight: FontWeight.w500)),
            ],
            const SizedBox(height: 10),
            Text(result.confidenceLabel, style: VeloraTheme.label(size: 11.5, color: VeloraColors.inkSoft)),
            const SizedBox(height: 18),
            Text(result.reasoningSummary, style: VeloraTheme.body(size: 14)),
            const SizedBox(height: 24),
            Text('What to do this week', style: VeloraTheme.display(size: 17)),
            const SizedBox(height: 8),
            ...result.treatmentSteps.map((step) => _ActionStepTile(step: step)),
            if (result.preventionSteps.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('To prevent it next time', style: VeloraTheme.display(size: 17)),
              const SizedBox(height: 8),
              ...result.preventionSteps.map((step) => _ActionStepTile(step: step)),
            ],
            const SizedBox(height: 28),
            VeloraButton(
              label: 'Done',
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
    );
  }
}

class _ActionStepTile extends StatelessWidget {
  final ActionStep step;
  const _ActionStepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: VeloraColors.ironTint),
            child: Text('${step.order}', style: VeloraTheme.label(size: 11, color: VeloraColors.iron)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title, style: VeloraTheme.label(size: 13)),
                const SizedBox(height: 2),
                Text(step.description, style: VeloraTheme.body(size: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
