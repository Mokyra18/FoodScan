class Nutrition {
  final int carbohydrate;
  final int protein;
  final int calories;
  final int fiber;
  final int fat;
  final int sugar;

  const Nutrition({
    required this.carbohydrate,
    required this.protein,
    required this.calories,
    required this.fiber,
    required this.fat,
    required this.sugar,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      carbohydrate: json['carbohydrate'] as int,
      protein: json['protein'] as int,
      calories: json['calories'] as int,
      fiber: json['fiber'] as int,
      fat: json['fat'] as int,
      sugar: json['sugar'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carbohydrate': carbohydrate,
      'protein': protein,
      'calories': calories,
      'fiber': fiber,
      'fat': fat,
      'sugar': sugar,
    };
  }
}
