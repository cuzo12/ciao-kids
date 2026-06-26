/// Build-time configuration for optional, externally-hosted services.
///
/// The Claude tutor is opt-in: it only activates when [claudeProxyUrl] points
/// at a deployed Cloudflare Worker (see `cloudflare/worker.js`). Until then the
/// app runs entirely on the safe, offline scripted tutor — so the feature can
/// ship "dark" and light up the moment the URL is filled in here (or supplied
/// via `--dart-define=CLAUDE_PROXY_URL=...`).
abstract final class AppConfig {
  /// URL of the Cloudflare Worker that proxies Claude. Empty = disabled.
  ///
  /// Set the `defaultValue` to your Worker URL after deploying it, e.g.
  /// `https://ciao-kids-tutor.<subdomain>.workers.dev`.
  static const String claudeProxyUrl = String.fromEnvironment(
    'CLAUDE_PROXY_URL',
    defaultValue: 'https://ciao-kids-tutor.bill-mancuso.workers.dev',
  );

  /// Whether the live Claude tutor is configured and should be offered.
  static bool get claudeEnabled => claudeProxyUrl.trim().isNotEmpty;
}
