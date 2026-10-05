import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env.dart';
import '../models/diagnosis_result.dart';
import '../services/crop_analysis_service.dart';
import '../services/plantnet_crop_analysis_service.dart';

/// Every screen in the scan flow renders exactly one of these states —
/// never a loose combination of booleans/flags. Use an exhaustive
/// `switch` wherever this is consumed so the compiler catches any
/// unhandled case.
sealed class ScanFlowState {
  const ScanFlowState();
}

class ScanIdle extends ScanFlowState {
  const ScanIdle();
}

class ScanAnalyzing extends ScanFlowState {
  final File image;
  const ScanAnalyzing(this.image);
}

class ScanSuccess extends ScanFlowState {
  final DiagnosisResult result;
  const ScanSuccess(this.result);
}

class ScanFailure extends ScanFlowState {
  final String message;
  final File? image; // kept so "retake" can go straight back to capture
  const ScanFailure(this.message, {this.image});
}

class ScanFlowNotifier extends StateNotifier<ScanFlowState> {
  final CropAnalysisService _service;

  ScanFlowNotifier(this._service) : super(const ScanIdle());

  /// Call this with the file from the camera once a photo is taken.
  Future<void> submit(File image) async {
    state = ScanAnalyzing(image);
    try {
      final result = await _service.analyze(image);
      state = ScanSuccess(result);
    } catch (e) {
      state = ScanFailure(e.toString().replaceFirst('Exception: ', ''), image: image);
    }
  }

  /// Re-run analysis on the same image (used by a "try again" that
  /// doesn't require retaking the photo). For a blurry-photo failure,
  /// prefer sending the user back to the capture screen instead.
  Future<void> retry() async {
    final current = state;
    if (current is ScanFailure && current.image != null) {
      await submit(current.image!);
    }
  }

  void reset() => state = const ScanIdle();
}

/// Swaps between the real Pl@ntNet service and the fake one — nothing
/// else in the app needs to change either way. Falls back to the fake
/// service (with a console warning) if no API key was provided via
/// --dart-define, so the app never silently fails to build/run.
final cropAnalysisServiceProvider = Provider<CropAnalysisService>((ref) {
  if (Env.hasPlantNetKey) {
    return RemoteCropAnalysisService(apiKey: Env.plantNetApiKey);
  }
  debugPrint(
    'Velora: no PLANTNET_API_KEY provided — falling back to '
    'FakeCropAnalysisService. Run with --dart-define=PLANTNET_API_KEY=... '
    'to use the real Pl@ntNet API.',
  );
  return FakeCropAnalysisService();
});

final scanFlowProvider = StateNotifierProvider<ScanFlowNotifier, ScanFlowState>((ref) {
  return ScanFlowNotifier(ref.watch(cropAnalysisServiceProvider));
});
