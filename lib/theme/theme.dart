import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Velora's single typeface family (Archivo), used across a wide range
/// of weight and width — no second typeface, no serif. Hierarchy comes
/// from weight, size and colour alone.
class VeloraTheme {
  VeloraTheme._();

  static TextStyle display({double size = 28, FontWeight weight = FontWeight.w800}) =>
      GoogleFonts.archivo(fontSize: size, fontWeight: weight, color: VeloraColors.ink, height: 1.1);

  static TextStyle body({double size = 15, FontWeight weight = FontWeight.w400, Color? color}) =>
      GoogleFonts.archivo(fontSize: size, fontWeight: weight, color: color ?? VeloraColors.inkSoft, height: 1.5);

  static TextStyle label({double size = 13, FontWeight weight = FontWeight.w600, Color? color}) =>
      GoogleFonts.archivo(fontSize: size, fontWeight: weight, color: color ?? VeloraColors.ink);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: VeloraColors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: VeloraColors.iron,
        brightness: Brightness.light,
        primary: VeloraColors.ink,
        surface: VeloraColors.white,
      ),
      textTheme: GoogleFonts.archivoTextTheme().apply(
        bodyColor: VeloraColors.ink,
        displayColor: VeloraColors.ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: VeloraColors.white,
        elevation: 0,
        foregroundColor: VeloraColors.ink,
        titleTextStyle: display(size: 18, weight: FontWeight.w800),
      ),
      dividerColor: VeloraColors.line,
    );
  }
}
