import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/scan_flow_provider.dart';
import '../theme/colors.dart';
import '../theme/theme.dart';
import 'analyzing_screen.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  CameraController? _controller;
  bool _taking = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    final controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
    await controller.initialize();
    if (!mounted) return;
    setState(() => _controller = controller);
  }

  Future<void> _takePhoto() async {
    final controller = _controller;
    if (controller == null || _taking) return;
    setState(() => _taking = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      // Fire the analysis off and move to the Analyzing screen immediately —
      // AnalyzingScreen itself just watches scanFlowProvider's state.
      ref.read(scanFlowProvider.notifier).submit(File(file.path));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AnalyzingScreen()),
      );
    } finally {
      if (mounted) setState(() => _taking = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null && controller.value.isInitialized)
            CameraPreview(controller)
          else
            const Center(child: CircularProgressIndicator(color: VeloraColors.white)),

          // Angled corner brackets instead of a full viewfinder frame.
          const _CornerBrackets(),

          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: Text(
              'Fill the frame with the affected leaf',
              textAlign: TextAlign.center,
              style: VeloraTheme.body(size: 12.5, weight: FontWeight.w500, color: VeloraColors.white),
            ),
          ),

          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: VeloraColors.white, width: 3),
                  ),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: VeloraColors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerBrackets extends StatelessWidget {
  const _CornerBrackets();

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: VeloraColors.white, width: 2.5);
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 56, 34, 150),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(border: Border(top: side, left: side)),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(border: Border(top: side, right: side)),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(border: Border(bottom: side, left: side)),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(border: Border(bottom: side, right: side)),
            ),
          ),
        ],
      ),
    );
  }
}
