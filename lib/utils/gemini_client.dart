import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiClient {
  GeminiClient({
    String? apiKey,
    String? model,
    String? baseUrl,
  }) {
    // Read env to keep configuration in one place when re-enabled.
    _readEnv('GEMINI_API_KEY', '');
    _readEnv('GEMINI_MODEL', 'gemini-1.5-flash');
    _readEnv('GEMINI_API_BASE',
        'https://generativelanguage.googleapis.com/v1beta');
  }

  bool get isConfigured => false;

  static String _readEnv(String key, String fallback) {
    String? fromDotenv;
    try {
      fromDotenv = dotenv.env[key];
    } catch (_) {
      fromDotenv = null;
    }
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }
    return String.fromEnvironment(key, defaultValue: fallback);
  }

  Future<String> generateChat({
    required List<Map<String, String>> messages,
    required String systemPrompt,
  }) async {
    throw Exception('Gemini is disabled');
  }
}
