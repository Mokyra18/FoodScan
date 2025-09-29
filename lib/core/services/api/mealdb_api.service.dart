import 'dart:convert';
import 'package:http/http.dart' as http;

class MealDbService {
  MealDbService._();
  static final instance = MealDbService._();

  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<Map<String, dynamic>?> searchByName(String name) async {
    final url = Uri.parse('$_baseUrl/search.php?s=$name');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final meals = data['meals'];
        if (meals is List && meals.isNotEmpty) {
          return meals.first as Map<String, dynamic>;
        }
      }
    } else {
      throw Exception(
        'Failed to load meal: ${response.statusCode} - ${response.body}',
      );
    }

    return null;
  }
}
