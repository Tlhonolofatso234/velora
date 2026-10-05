import 'dart:io';
import 'dart:math';
import '../models/action_step.dart';
import '../models/diagnosis_result.dart';
import '../models/severity.dart';

/// Contract the rest of the app depends on. During idea-validation
/// and early UI work, this is backed by [FakeCropAnalysisService].
/// Once a real model/API exists, write a `RemoteCropAnalysisService`
/// implementing this same interface and swap it in one place (the
/// provider override) — nothing else in the app needs to change.
abstract class CropAnalysisService {
  Future<DiagnosisResult> analyze(File image);
}

/// Returns a plausible, hardcoded result after a short delay — just
/// enough to let every screen (loading, success, error paths) be
/// built and demoed before any backend exists.
class FakeCropAnalysisService implements CropAnalysisService {
  @override
  Future<DiagnosisResult> analyze(File image) async {
    await Future.delayed(const Duration(seconds: 2));

    // Occasionally simulate a failure so the error screen can be tested.
    if (Random().nextDouble() < 0.15) {
      throw Exception('Photo too blurry — could not identify the leaf clearly.');
    }

    return DiagnosisResult(
      cropName: 'Tomato',
      diagnosisName: 'Early Blight',
      latinName: 'Alternaria solani',
      severity: Severity.caution,
      confidence: 0.72,
      reasoningSummary:
          'Dark, concentric rings on the lower leaves point to early blight '
          'rather than nutrient stress. It spreads fastest in humid, still '
          'air, usually starting on older growth first.',
      image: image,
      scannedAt: DateTime.now(),
      treatmentSteps: const [
        ActionStep(
          order: 1,
          title: 'Remove affected leaves',
          description: "Cut back the worst-hit lower leaves and burn or bin them — don't compost.",
        ),
        ActionStep(
          order: 2,
          title: 'Apply a copper fungicide',
          description: "Spray in the early morning, before the day's heat. Repeat in 7 days.",
        ),
        ActionStep(
          order: 3,
          title: 'Water at the base',
          description: 'Wet leaves speed the spread. Switch to drip or hand-watering the soil.',
        ),
      ],
      preventionSteps: const [
        ActionStep(
          order: 1,
          title: 'Rotate crops next season',
          description: 'Avoid planting tomatoes or potatoes in the same spot for 2 years.',
        ),
        ActionStep(
          order: 2,
          title: 'Increase plant spacing',
          description: 'Better airflow reduces the humid conditions blight needs to spread.',
        ),
      ],
    );
  }
}
