import 'env.dart' as raw;

/// App environment accessors.
///
/// NOTE: `env.dart` is not modified; this wrapper exposes the fields
/// in the requested shape (`Env.apiKey`, `Env.baseUrl`).
class Env {
  static const String apiKey = raw.secretKey;
  static const String baseUrl = raw.domaine;
}
