import 'package:flutter/material.dart';

/// Velora design tokens — colour.
///
/// 60% neutral (white / ink) + 30% ink structure + 10% meaning colour.
/// Only Iron / Sage / Gold carry meaning (severity, status). Everything
/// else in the app should be built from ink, white and surface.
class VeloraColors {
  VeloraColors._();

  // Neutral base
  static const Color ink = Color(0xFF111110);
  static const Color inkSoft = Color(0xFF5B5B57);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF4F4F1);
  static const Color line = Color(0x21111110); // ~13% ink
  static const Color lineStrong = Color(0x4D111110); // ~30% ink

  // Meaning colour — full strength (text/icons/edges on top of tints)
  static const Color iron = Color(0xFFD2410E); // issue / alert / brand accent
  static const Color ironDeep = Color(0xFFA6330A);
  static const Color sage = Color(0xFF237A46); // healthy
  static const Color sageDeep = Color(0xFF175C34);
  static const Color gold = Color(0xFFE8A317); // caution
  static const Color goldDeep = Color(0xFFB87B0C);

  // Meaning colour — tints (fills behind full-strength content)
  static const Color ironTint = Color(0x1AD2410E); // 10%
  static const Color sageTint = Color(0x1A237A46); // 10%
  static const Color goldTint = Color(0x24E8A317); // 14%
}
