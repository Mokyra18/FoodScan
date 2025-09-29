import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:foodsnap/core/services/api/gemini_api.service.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  GeminiService._();
  static final instance = GeminiService._();

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model = 'gemini-2.5-flash';

  static const String _staticApiKey = '';

  Future<String> get _apiKey async {
    // Try to get from SharedPreferences
    final apiKey = await ApiKeyService.instance.getGeminiApiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      return apiKey;
    }

    // Fallback to static key (not recommended for production)
    if (_staticApiKey.isNotEmpty) {
      return _staticApiKey;
    }

    throw Exception(
      'GEMINI_API_KEY not found. Please set it in the app settings.',
    );
  }

  Future<bool> get isEnabled async {
    try {
      await _apiKey;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getNutritionInfo(String foodName) async {
    try {
      final apiKey = await _apiKey; // This will throw if not available
      debugPrint('🔑 Using API Key: ${apiKey.substring(0, 10)}...');
      debugPrint('🍕 Getting nutrition for: $foodName');

      final requestUrl = '$_baseUrl/$_model:generateContent?key=$apiKey';
      debugPrint('📡 Request URL: $requestUrl');

      final requestData = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {
                'text':
                    'Provide nutrition information for the food "$foodName" in grams per 100 grams. Provide accurate and general data for this food. Return only valid JSON with calories, carbohydrate, fat, fiber, protein, sugar as integers.',
              },
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'responseSchema': {
            'type': 'object',
            'properties': {
              'calories': {'type': 'integer'},
              'carbohydrate': {'type': 'integer'},
              'fat': {'type': 'integer'},
              'fiber': {'type': 'integer'},
              'protein': {'type': 'integer'},
              'sugar': {'type': 'integer'},
            },
            'required': [
              'calories',
              'carbohydrate',
              'fat',
              'fiber',
              'protein',
              'sugar',
            ],
          },
        },
      };

      debugPrint('📤 Request Data: ${jsonEncode(requestData)}');

      final response = await http.post(
        Uri.parse(requestUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content'];
          if (content['parts'] != null && content['parts'].isNotEmpty) {
            final jsonText = content['parts'][0]['text'];
            final result = jsonDecode(jsonText) as Map<String, dynamic>;
            debugPrint('✅ Gemini API success: $result');
            return result;
          }
        }
      } else {
        debugPrint(
          '❌ Gemini API error: ${response.statusCode} - ${response.body}',
        );
      }

      // Return fallback data if API fails
      return _getFallbackNutrition(foodName);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return _getFallbackNutrition(foodName);
    }
  }

  Map<String, dynamic> _getFallbackNutrition(String foodName) {
    debugPrint('🔄 Using fallback nutrition for: $foodName');

    if (foodName.toLowerCase().contains('rice') ||
        foodName.toLowerCase().contains('nasi')) {
      return {
        'calories': 130,
        'carbohydrate': 28,
        'fat': 0,
        'fiber': 0,
        'protein': 3,
        'sugar': 0,
      };
    } else if (foodName.toLowerCase().contains('chicken') ||
        foodName.toLowerCase().contains('ayam')) {
      return {
        'calories': 165,
        'carbohydrate': 0,
        'fat': 3,
        'fiber': 0,
        'protein': 31,
        'sugar': 0,
      };
    } else {
      // Generic fallback
      return {
        'calories': 0,
        'carbohydrate': 0,
        'fat': 0,
        'fiber': 0,
        'protein': 0,
        'sugar': 0,
      };
    }
  }

  @Deprecated('Use getNutritionInfo instead')
  Future<Map<String, dynamic>> summarizeNutrition(String foodName) async {
    return getNutritionInfo(foodName);
  }
}
