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
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _activeCameraIndex = 0;
  bool _taking = false;
  bool _switching = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Default to the back (environment-facing) camera explicitly —
    // `cameras.first` is not guaranteed to be the back camera on every
    // device/platform, which is what was showing the selfie camera.
    final backIndex = cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
    _cameras = cameras;
    _activeCameraIndex = backIndex != -1 ? backIndex : 0;

    // Temporary — check your debug console. If this prints 1, the switch
    // button is correctly hidden/disabled because there's genuinely only
    // one camera available (common on emulators). Remove once confirmed.
    debugPrint('Velora: found ${cameras.length} camera(s): '
        '${cameras.map((c) => c.lensDirection).join(', ')}');

    await _openCamera(_activeCameraIndex);
  }

  Future<void> _openCamera(int index) async {
    final previous = _controller;
    final controller = CameraController(_cameras[index], ResolutionPreset.high, enableAudio: false);
    await controller.initialize();
    await previous?.dispose();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _controller = controller;
      _activeCameraIndex = index;
    });
  }

  bool get _hasMultipleCameras => _cameras.length > 1;

  Future<void> _switchCamera() async {
    if (!_hasMultipleCameras || _switching) return;
    setState(() => _switching = true);
    final nextIndex = (_activeCameraIndex + 1) % _cameras.length;
    try {
      await _openCamera(nextIndex);
    } finally {
      if (mounted) setState(() => _switching = false);
    }
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
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 30), // keeps the shutter visually centred

                GestureDetector(
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

                // Always rendered now (greyed out + disabled when only one
                // camera exists) so a missing icon is never ambiguous —
                // if you don't see ANY circle here, it's a layout/build
                // issue, not a "no second camera" issue.
                GestureDetector(
                  onTap: _hasMultipleCameras ? _switchCamera : null,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: VeloraColors.white.withValues(),
                        width: 1.5,
                      ),
                    ),
                    child: _switching
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(strokeWidth: 2, color: VeloraColors.white),
                          )
                        : Icon(
                            Icons.cameraswitch_outlined,
                            color: VeloraColors.white.withValues(),
                            size: 16,
                          ),
                  ),
                ),
              ],
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
