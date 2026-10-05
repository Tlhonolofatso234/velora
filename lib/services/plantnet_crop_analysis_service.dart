import 'dart:io';
import 'package:dio/dio.dart';
import '../models/action_step.dart';
import '../models/diagnosis_result.dart';
import '../models/severity.dart';
import 'crop_analysis_service.dart';
import 'disease_advice.dart';

/// Real implementation of [CropAnalysisService], backed by the
/// Pl@ntNet API (https://my.plantnet.org).
///
/// IMPORTANT — what Pl@ntNet actually does and doesn't do:
/// - It identifies plant SPECIES (`/v2/identify`) and matches images
///   against a reference list of known diseases/pests
///   (`/v2/diseases/identify`). It does NOT tell you a plant is
///   "healthy" — it just returns its best disease-list match, even
///   if that match is a poor one. Low-confidence results are treated
///   here as "no confident issue found" rather than a real diagnosis.
/// - It provides NO treatment or prevention advice. That's handled
///   locally in [DiseaseAdvice] as a stopgap — replace/expand that
///   with a real advisory source (agronomist-reviewed content, or a
///   second AI call) before relying on it for real guidance.
/// - Two API calls are made per scan (species + disease), so this
///   uses 2 credits against your Pl@ntNet quota per photo analysed.
class RemoteCropAnalysisService implements CropAnalysisService {
  final Dio _dio;
  final String apiKey;

  static const _base = 'https://my-api.plantnet.org/v2';

  /// Below this disease-match score, we don't trust the result enough
  /// to present it as a diagnosis — tune this against real test
  /// photos once you have some. Pl@ntNet gives no "healthy" signal,
  /// so this threshold is standing in for one.
  static const _lowConfidenceThreshold = 0.20;
  static const _issueThreshold = 0.55;

  RemoteCropAnalysisService({required this.apiKey, Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<DiagnosisResult> analyze(File image) async {
    // Run both calls in parallel — they're independent and each takes
    // a couple of seconds, no reason to make the farmer wait for both
    // sequentially.
    final results = await Future.wait([
      _identifySpecies(image),
      _identifyDisease(image),
    ]);
    final species = results[0] as _SpeciesMatch?;
    final disease = results[1] as _DiseaseMatch?;

    return _buildResult(image: image, species: species, disease: disease);
  }

  Future<_SpeciesMatch?> _identifySpecies(File image) async {
    try {
      final form = FormData.fromMap({
        'organs': 'leaf',
        'images': await MultipartFile.fromFile(image.path, filename: 'leaf.jpg'),
      });
      final res = await _dio.post(
        '$_base/identify/all',
        queryParameters: {'api-key': apiKey, 'lang': 'en', 'nb-results': 1},
        data: form,
      );
      final list = (res.data['results'] as List?) ?? [];
      if (list.isEmpty) return null;
      final top = list.first as Map<String, dynamic>;
      final speciesData = top['species'] as Map<String, dynamic>;
      final commonNames = (speciesData['commonNames'] as List?)?.cast<String>() ?? [];
      return _SpeciesMatch(
        commonName: commonNames.isNotEmpty
            ? commonNames.first
            : speciesData['scientificNameWithoutAuthor'] as String? ?? 'Unknown crop',
        scientificName: speciesData['scientificNameWithoutAuthor'] as String?,
        score: (top['score'] as num).toDouble(),
      );
    } catch (e) {
      // Species ID is a nice-to-have on the result screen, not
      // essential — a failure here shouldn't fail the whole scan.
      return null;
    }
  }

  Future<_DiseaseMatch?> _identifyDisease(File image) async {
    final form = FormData.fromMap({
      'organs': 'leaf',
      'images': await MultipartFile.fromFile(image.path, filename: 'leaf.jpg'),
    });
    final res = await _dio.post(
      '$_base/diseases/identify',
      queryParameters: {'api-key': apiKey, 'nb-results': 3},
      data: form,
    );
    final list = (res.data['results'] as List?) ?? [];
    if (list.isEmpty) return null;
    final top = list.first as Map<String, dynamic>;
    return _DiseaseMatch(
      eppoCode: top['name'] as String,
      description: (top['description'] as String?) ?? top['name'] as String,
      score: (top['score'] as num).toDouble(),
    );
  }

  DiagnosisResult _buildResult({
    required File image,
    required _SpeciesMatch? species,
    required _DiseaseMatch? disease,
  }) {
    final hasConfidentIssue = disease != null && disease.score >= _lowConfidenceThreshold;
    final severity = !hasConfidentIssue
        ? Severity.healthy
        : (disease.score >= _issueThreshold ? Severity.issue : Severity.caution);

    final diagnosisName = hasConfidentIssue ? _titleCase(disease.description) : 'No confident issue found';

    final reasoning = hasConfidentIssue
        ? "Matched against Pl@ntNet's disease reference set with "
            "${(disease.score * 100).toStringAsFixed(0)}% confidence. "
            "Always confirm visually before treating — this is a reference "
            "match, not a lab diagnosis."
        : "Pl@ntNet didn't find a confident match against its known disease "
            "list. This can mean the crop is healthy, or that the photo "
            "needs to be clearer — closer to the leaf, better light, less "
            "background clutter.";

    final advice = hasConfidentIssue
        ? DiseaseAdvice.forCode(disease.eppoCode)
        : const (treatment: <ActionStep>[], prevention: <ActionStep>[]);

    return DiagnosisResult(
      cropName: species?.commonName ?? 'Unidentified crop',
      diagnosisName: diagnosisName,
      latinName: species?.scientificName,
      severity: severity,
      confidence: hasConfidentIssue ? disease.score : (species?.score ?? 0),
      reasoningSummary: reasoning,
      image: image,
      scannedAt: DateTime.now(),
      treatmentSteps: advice.treatment,
      preventionSteps: advice.prevention,
    );
  }

  String _titleCase(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _SpeciesMatch {
  final String commonName;
  final String? scientificName;
  final double score;
  _SpeciesMatch({required this.commonName, this.scientificName, required this.score});
}

class _DiseaseMatch {
  final String eppoCode;
  final String description;
  final double score;
  _DiseaseMatch({required this.eppoCode, required this.description, required this.score});
}
