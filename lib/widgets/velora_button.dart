import 'package:flutter/material.dart';
import '../shapes/cut_corner_border.dart';
import '../theme/colors.dart';
import '../theme/theme.dart';

enum VeloraButtonVariant { primary, secondary, danger }

/// One button widget for the whole app, varied by [variant] — not a
/// separate widget per colour. Keeps every button sharing the same
/// cut-corner shape and padding automatically.
class VeloraButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VeloraButtonVariant variant;
  final bool expand;

  const VeloraButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = VeloraButtonVariant.primary,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, side) = switch (variant) {
      VeloraButtonVariant.primary => (VeloraColors.ink, VeloraColors.white, BorderSide.none),
      VeloraButtonVariant.secondary => (
          Colors.transparent,
          VeloraColors.ink,
          const BorderSide(color: VeloraColors.ink, width: 1.5),
        ),
      VeloraButtonVariant.danger => (VeloraColors.ironDeep, VeloraColors.white, BorderSide.none),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: CutCornerBorder(cut: 10, side: side),
        child: Container(
          width: expand ? double.infinity : null,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: ShapeDecoration(color: bg, shape: CutCornerBorder(cut: 10, side: side)),
          child: Text(label, style: VeloraTheme.label(size: 14.5, weight: FontWeight.w700, color: fg)),
        ),
      ),
    );
  }
}
