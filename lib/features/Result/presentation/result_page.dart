import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodsnap/core/services/api/mealdb_api.service.dart';
import 'package:foodsnap/core/services/gemini_service.dart';
import 'package:foodsnap/data/models/nutrition_data.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultPage extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> analysisResult;

  const ResultPage({
    super.key,
    required this.imagePath,
    required this.analysisResult,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  Nutrition? _nutrition;
  Map<String, dynamic>? _mealInfo;
  String? _foodDescription;

  bool _loadingNutrition = true;
  bool _loadingMealInfo = true;
  bool _loadingDescription = true;

  String? _nutritionError;
  String? _mealError;
  String? _descriptionError;

  bool _showRecipeDetails = false;

  @override
  void initState() {
    super.initState();
    _loadAdditionalInfo();
  }

  Future<void> _loadAdditionalInfo() async {
    final topResult =
        widget.analysisResult['topResult'] as Map<String, dynamic>;
    final foodName = topResult['label'] as String;

    await Future.wait([
      _loadNutritionInfo(foodName),
      _loadMealInfo(foodName),
      _loadFoodDescription(foodName),
    ]);
  }

  Future<void> _loadNutritionInfo(String foodName) async {
    if (!mounted) return;
    setState(() {
      _loadingNutrition = true;
      _nutritionError = null;
    });
    try {
      final nutritionData = await GeminiService.instance.getNutritionInfo(
        foodName,
      );
      if (mounted) {
        setState(() {
          _nutrition = Nutrition.fromJson(nutritionData);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _nutritionError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingNutrition = false);
    }
  }

  Future<void> _loadMealInfo(String foodName) async {
    if (!mounted) return;
    setState(() {
      _loadingMealInfo = true;
      _mealError = null;
    });
    try {
      final mealInfo = await MealDbService.instance.searchByName(foodName);
      if (mounted) {
        setState(() {
          _mealInfo = mealInfo;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _mealError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingMealInfo = false);
    }
  }

  Future<void> _loadFoodDescription(String foodName) async {
    if (!mounted) return;
    setState(() {
      _loadingDescription = true;
      _descriptionError = null;
    });
    try {
      final description =
          'This is a delicious $foodName dish that is popular in many cuisines around the world.';
      if (mounted) {
        setState(() {
          _foodDescription = description;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _descriptionError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingDescription = false);
    }
  }

  List<Map<String, String>> _parseIngredients(Map<String, dynamic> mealInfo) {
    final ingredients = <Map<String, String>>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = mealInfo['strIngredient$i'];
      final measure = mealInfo['strMeasure$i'];

      if (ingredient != null &&
          ingredient.toString().trim().isNotEmpty &&
          ingredient.toString() != "null") {
        ingredients.add({
          'ingredient': ingredient.toString().trim(),
          'measure': (measure?.toString().trim() ?? '').isEmpty
              ? 'To taste'
              : measure.toString().trim(),
        });
      }
    }
    return ingredients;
  }

  Future<void> _launchYouTubeUrl(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open YouTube video.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topResult =
        widget.analysisResult['topResult'] as Map<String, dynamic>;
    final allResults =
        widget.analysisResult['results'] as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Result')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageSection(),
            const SizedBox(height: 20),
            _buildDetectionResultsSection(topResult, allResults),
            const SizedBox(height: 20),
            _buildDescriptionSection(),
            const SizedBox(height: 20),
            _buildNutritionSection(),
            const SizedBox(height: 20),
            _buildMealInfoSection(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.home_outlined),
              label: const Text('Back to Home'),
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Image.file(
            File(widget.imagePath),
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Analyzed Image',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionResultsSection(
    Map<String, dynamic> topResult,
    List<Map<String, dynamic>> allResults,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detection Results',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topResult['label'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          'Confidence: ${(topResult['confidence'] * 100).toStringAsFixed(1)}%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.verified, color: colorScheme.primary),
                ],
              ),
            ),
            if (allResults.length > 1) ...[
              const SizedBox(height: 16),
              Text(
                'Other Possibilities:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...allResults
                  .skip(1)
                  .take(4)
                  .map(
                    (result) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              result['label'],
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '${(result['confidence'] * 100).toStringAsFixed(1)}%',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Skeletonizer(
      enabled: _loadingDescription,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (_descriptionError != null)
                Text(
                  'Unable to load description',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                )
              else
                Text(
                  _foodDescription ??
                      'This is a delicious food dish popular in many cuisines.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionSection() {
    return Skeletonizer(
      enabled: _loadingNutrition,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nutrition Info (per 100g)',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildNutritionContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionContent() {
    if (_nutritionError != null) {
      return Center(
        child: Text(
          'Unable to load nutrition info',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }
    if (_nutrition == null && !_loadingNutrition) {
      return const Center(child: Text('No nutrition information available.'));
    }

    final nutrition =
        _nutrition ??
        Nutrition(
          calories: 0,
          carbohydrate: 0,
          fat: 0,
          fiber: 0,
          protein: 0,
          sugar: 0,
        );

    final nutritionItems = [
      {'label': 'Calories', 'value': '${nutrition.calories}', 'unit': 'kcal'},
      {'label': 'Carbs', 'value': '${nutrition.carbohydrate}', 'unit': 'g'},
      {'label': 'Protein', 'value': '${nutrition.protein}', 'unit': 'g'},
      {'label': 'Fat', 'value': '${nutrition.fat}', 'unit': 'g'},
      {'label': 'Fiber', 'value': '${nutrition.fiber}', 'unit': 'g'},
      {'label': 'Sugar', 'value': '${nutrition.sugar}', 'unit': 'g'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: nutritionItems.length,
      itemBuilder: (context, index) {
        final item = nutritionItems[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['label']!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${item['value']} ${item['unit']}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealInfoSection() {
    return Skeletonizer(
      enabled: _loadingMealInfo,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildMealInfoContent(),
        ),
      ),
    );
  }

  Widget _buildMealInfoContent() {
    if (_mealError != null || _mealInfo == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recipe Information',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _mealError != null
                  ? 'Error loading recipe'
                  : 'No recipe information found',
            ),
          ),
        ],
      );
    }

    final ingredients = _parseIngredients(_mealInfo!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipe Information',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_mealInfo!['strMealThumb'] != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _mealInfo!['strMealThumb'],
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 16),
        Text(
          _mealInfo!['strMeal'] ?? 'Unknown Recipe',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          // MENGGUNAKAN WRAP UNTUK MENGHINDARI OVERFLOW
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            if (_mealInfo!['strCategory'] != null)
              Chip(label: Text(_mealInfo!['strCategory'])),
            if (_mealInfo!['strArea'] != null)
              Chip(label: Text(_mealInfo!['strArea'])),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                setState(() => _showRecipeDetails = !_showRecipeDetails),
            icon: Icon(
              _showRecipeDetails ? Icons.expand_less : Icons.expand_more,
            ),
            label: Text(
              _showRecipeDetails ? 'Hide Details' : 'Show Full Recipe',
            ),
          ),
        ),
        if (_showRecipeDetails) ...[
          const Divider(height: 32),
          if (ingredients.isNotEmpty) ...[
            Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...ingredients.map(
              (ing) => ListTile(
                dense: true,
                leading: const Icon(Icons.check_circle_outline, size: 18),
                title: Text(ing['ingredient']!),
                trailing: Text(ing['measure']!),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_mealInfo!['strInstructions'] != null) ...[
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _mealInfo!['strInstructions'],
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 16),
          ],
          if (_mealInfo!['strYoutube'] != null &&
              _mealInfo!['strYoutube'].toString().isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchYouTubeUrl(_mealInfo!['strYoutube']),
                icon: const Icon(Icons.play_circle_fill),
                label: const Text('Watch on YouTube'),
              ),
            ),
        ],
      ],
    );
  }
}
