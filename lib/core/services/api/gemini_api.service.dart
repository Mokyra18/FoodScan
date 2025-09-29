import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyService {
  static const String _geminiApiKeyKey = 'gemini_api_key';

  static ApiKeyService? _instance;
  static ApiKeyService get instance {
    _instance ??= ApiKeyService._();
    return _instance!;
  }

  ApiKeyService._();

  /// Save Gemini API key to SharedPreferences
  Future<void> saveGeminiApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKeyKey, apiKey);
  }

  /// Get Gemini API key from SharedPreferences
  Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiApiKeyKey);
  }

  /// Check if Gemini API key exists
  Future<bool> hasGeminiApiKey() async {
    final apiKey = await getGeminiApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// Remove Gemini API key from SharedPreferences
  Future<void> removeGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_geminiApiKeyKey);
  }
}
