import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyService {
  static const String _geminiApiKeyKey = 'gemini_api_key';

  static ApiKeyService? _instance;
  static ApiKeyService get instance {
    _instance ??= ApiKeyService._();
    return _instance!;
  }

  ApiKeyService._();

  Future<void> saveGeminiApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKeyKey, apiKey);
  }

  Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiApiKeyKey);
  }

  Future<bool> hasGeminiApiKey() async {
    final apiKey = await getGeminiApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  Future<void> removeGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_geminiApiKeyKey);
  }
}
