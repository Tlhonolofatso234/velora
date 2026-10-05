import '../models/action_step.dart';

/// Pl@ntNet identifies a disease/pest — it does not provide treatment
/// or prevention advice at all. This lookup is a deliberately small
/// stopgap so the "What should I do?" step in the flow isn't empty
/// while the real diagnosis pipeline is being tested.
///
/// Before relying on this for real farmers: replace or expand it with
/// agronomist-reviewed content (ideally localised to your region's
/// common crops), or chain a second call to a text model — e.g. send
/// `diagnosisName` + `cropName` to an LLM and ask it to generate
/// treatment/prevention steps, then cache the result locally so you're
/// not re-generating the same advice on every scan of the same issue.
class DiseaseAdvice {
  DiseaseAdvice._();

  static ({List<ActionStep> treatment, List<ActionStep> prevention}) forCode(String eppoCode) {
    return _lookup[eppoCode] ?? _genericFallback;
  }

  static final _genericFallback = (
    treatment: const [
      ActionStep(
        order: 1,
        title: 'Isolate affected plants where possible',
        description: 'Reduce contact with healthy plants until you know more about spread risk.',
      ),
      ActionStep(
        order: 2,
        title: 'Monitor daily for the next week',
        description: 'Note whether it spreads to nearby plants or stays contained — this matters for diagnosis.',
      ),
      ActionStep(
        order: 3,
        title: 'Consult a local agricultural extension officer',
        description: 'Pl@ntNet gave a reference match, not a confirmed diagnosis — a local expert can confirm it.',
      ),
    ],
    prevention: const [
      ActionStep(
        order: 1,
        title: 'Improve airflow between plants',
        description: 'Many fungal and bacterial issues spread faster in still, humid conditions.',
      ),
      ActionStep(
        order: 2,
        title: 'Water at the base, not the leaves',
        description: 'Wet foliage is one of the most common ways disease spreads between plants.',
      ),
    ],
  );

  // A handful of real examples to demonstrate the pattern — expand this
  // as you learn which EPPO codes actually come back for your users'
  // most common crops. Codes come from Pl@ntNet's /v2/diseases list.
  static final Map<String, ({List<ActionStep> treatment, List<ActionStep> prevention})> _lookup = {
    // Example: powdery mildew family
    '1PUCCG': (
      treatment: const [
        ActionStep(
          order: 1,
          title: 'Remove heavily infected leaves',
          description: "Cut back the worst-affected leaves and bin them — don't compost.",
        ),
        ActionStep(
          order: 2,
          title: 'Apply a sulphur or potassium bicarbonate spray',
          description: 'Apply in the early morning or evening, not in direct midday sun.',
        ),
      ],
      prevention: const [
        ActionStep(
          order: 1,
          title: 'Increase plant spacing',
          description: 'Better airflow reduces the humid, still conditions mildew needs to spread.',
        ),
      ],
    ),
  };
}
