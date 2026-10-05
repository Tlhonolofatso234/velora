import 'package:flutter/material.dart';
import '../models/severity.dart';
import '../theme/theme.dart';

/// Tint fill + full-strength text — never a loud solid fill with white
/// text. Keeps the accent legible at small sizes and matches how
/// colour is used everywhere else in the system (fill = meaning's
/// background, never meaning's loudest expression).
class SeverityChip extends StatelessWidget {
  final Severity severity;

  const SeverityChip({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: severity.tint),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(severity.icon, size: 14, color: severity.color),
          const SizedBox(width: 6),
          Text(severity.label, style: VeloraTheme.label(size: 11.5, color: severity.color)),
        ],
      ),
    );
  }
}
