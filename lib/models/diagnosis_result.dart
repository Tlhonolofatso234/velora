import 'dart:io';
import 'action_step.dart';
import 'severity.dart';

/// Everything a diagnosis screen needs, in one object. For the MVP
/// this is built directly by [FakeCropAnalysisService]; once a real
/// API exists, add a `DiagnosisResult.fromJson` factory here rather
/// than changing anything that consumes this class.
class DiagnosisResult {
  final String cropName;
  final String diagnosisName;
  final String? latinName;
  final Severity severity;
  final double confidence; // 0.0–1.0
  final String reasoningSummary;
  final File image;
  final DateTime scannedAt;
  final List<ActionStep> treatmentSteps;
  final List<ActionStep> preventionSteps;

  const DiagnosisResult({
    required this.cropName,
    required this.diagnosisName,
    this.latinName,
    required this.severity,
    required this.confidence,
    required this.reasoningSummary,
    required this.image,
    required this.scannedAt,
    this.treatmentSteps = const [],
    this.preventionSteps = const [],
  });

  bool get isHealthy => severity == Severity.healthy;

  String get confidenceLabel {
    if (confidence >= 0.8) return 'Very confident';
    if (confidence >= 0.55) return 'Fairly confident';
    return 'Low confidence — consider rescanning';
  }
}
