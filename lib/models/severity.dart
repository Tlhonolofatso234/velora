import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// The one status every scan resolves to. Drives colour, icon and
/// copy everywhere a diagnosis is shown — never branch UI on a raw
/// string from the API, branch on this.
enum Severity { healthy, caution, issue,  }

extension SeverityX on Severity {
  String get label => switch (this) {
        Severity.healthy => 'Healthy',
        Severity.caution => 'Moderate severity',
        Severity.issue => 'Needs attention',
      };

  Color get color => switch (this) {
        Severity.healthy => VeloraColors.sage,
        Severity.caution => VeloraColors.gold,
        Severity.issue => VeloraColors.iron,
      };

  Color get tint => switch (this) {
        Severity.healthy => VeloraColors.sageTint,
        Severity.caution => VeloraColors.goldTint,
        Severity.issue => VeloraColors.ironTint,
      };

  IconData get icon => switch (this) {
        Severity.healthy => Icons.check_circle_outline,
        Severity.caution => Icons.error_outline,
        Severity.issue => Icons.warning_amber_rounded,
      };
}
