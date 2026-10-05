/// One concrete, actionable step shown to the farmer — e.g. under
/// "What to do this week". Order starts at 1, not 0, since it's
/// displayed directly as a numeral (01, 02, 03...).
class ActionStep {
  final int order;
  final String title;
  final String description;

  const ActionStep({
    required this.order,
    required this.title,
    required this.description,
  });
}
