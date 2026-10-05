import 'package:flutter/material.dart';

/// Velora's one structural signature: a single angled cut on the
/// top-right corner, echoing the logomark's blade. Used on every
/// contained surface — cards, photo frames, buttons, badges — instead
/// of rounded corners.
///
/// Usage:
/// ```dart
/// Container(
///   decoration: ShapeDecoration(
///     color: VeloraColors.white,
///     shape: CutCornerBorder(cut: 18, side: BorderSide(color: VeloraColors.line)),
///   ),
///   child: ...,
/// )
/// ```
class CutCornerBorder extends ShapeBorder {
  final double cut;
  final BorderSide side;

  const CutCornerBorder({this.cut = 18, this.side = BorderSide.none});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final c = cut.clamp(0, rect.shortestSide / 2).toDouble();
    return Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right - c, rect.top)
      ..lineTo(rect.right, rect.top + c)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side == BorderSide.none) return;
    final path = getOuterPath(rect);
    canvas.drawPath(path, side.toPaint());
  }

  @override
  ShapeBorder scale(double t) => CutCornerBorder(cut: cut * t, side: side.scale(t));
}

/// Convenience wrapper so screens don't repeat ShapeDecoration boilerplate.
class CutCornerContainer extends StatelessWidget {
  final Widget? child;
  final Color color;
  final double cut;
  final BorderSide side;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;

  const CutCornerContainer({
    super.key,
    this.child,
    this.color = Colors.white,
    this.cut = 18,
    this.side = const BorderSide(color: Color(0x21111110)),
    this.padding,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: ShapeDecoration(
        color: color,
        shape: CutCornerBorder(cut: cut, side: side),
      ),
      child: child,
    );
  }
}
