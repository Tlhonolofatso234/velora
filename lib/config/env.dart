/// Reads the Pl@ntNet API key at build/run time via --dart-define, so
/// it's never committed to source control as plain text.
///
/// Run with:
///   flutter run --dart-define=PLANTNET_API_KEY=your_key_here
///
/// Build/deploy (matches your existing peanut deploy command) with:
///   flutter build web --release --base-href=/velora/ --dart-define=PLANTNET_API_KEY=your_key_here
///
/// Reminder: on Flutter Web this key still ends up inside the compiled
/// JS bundle and is visible to anyone who opens dev tools — keeping
/// it out of git history is still worth doing, but it is not the same
/// as keeping it secret from site visitors. True secrecy on web
/// requires proxying requests through your own backend instead.
class Env {
  Env._();

  static const plantNetApiKey = String.fromEnvironment('PLANTNET_API_KEY');

  static bool get hasPlantNetKey => plantNetApiKey.isNotEmpty;
}
