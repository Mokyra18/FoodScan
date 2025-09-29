import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodsnap/core/services/api/mealdb_api.service.dart';
import 'package:foodsnap/core/services/gemini_service.dart';
import 'package:foodsnap/data/models/nutrition_data.dart';
import 'package:foodsnap/shared/widget/custom_button.dart';
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

  bool _loadingNutrition = false;
  bool _loadingMealInfo = false;
  bool _loadingDescription = false;

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

    // Load all information in parallel
    await Future.wait([
      _loadNutritionInfo(foodName),
      _loadMealInfo(foodName),
      _loadFoodDescription(foodName),
    ]);
  }

  Future<void> _loadNutritionInfo(String foodName) async {
    setState(() {
      _loadingNutrition = true;
      _nutritionError = null;
    });

    try {
      final nutritionData = await GeminiService.instance.getNutritionInfo(
        foodName,
      );
      final nutrition = Nutrition.fromJson(nutritionData);
      setState(() {
        _nutrition = nutrition;
        _loadingNutrition = false;
      });
    } catch (e) {
      setState(() {
        _nutritionError = e.toString();
        _loadingNutrition = false;
      });
    }
  }

  Future<void> _loadMealInfo(String foodName) async {
    setState(() {
      _loadingMealInfo = true;
      _mealError = null;
    });

    try {
      final mealInfo = await MealDbService.instance.searchByName(foodName);
      setState(() {
        _mealInfo = mealInfo;
        _loadingMealInfo = false;
      });
    } catch (e) {
      setState(() {
        _mealError = e.toString();
        _loadingMealInfo = false;
      });
    }
  }

  Future<void> _loadFoodDescription(String foodName) async {
    setState(() {
      _loadingDescription = true;
      _descriptionError = null;
    });

    try {
      // For now, provide a simple description based on food name
      // You can implement a Gemini API call for this later
      final description =
          'This is a delicious $foodName dish that is popular in many cuisines around the world.';
      setState(() {
        _foodDescription = description;
        _loadingDescription = false;
      });
    } catch (e) {
      setState(() {
        _descriptionError = e.toString();
        _loadingDescription = false;
      });
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
    try {
      final Uri uri = Uri.parse(url);

      // Try to launch with different modes
      bool launched = false;

      // First try: Launch with external application (YouTube app)
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Failed to launch with external app: $e');
      }

      // Second try: Launch with platform default (browser)
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e) {
          debugPrint('Failed to launch with platform default: $e');
        }
      }

      // Third try: Launch in web view mode as fallback
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
        } catch (e) {
          debugPrint('Failed to launch with in-app web view: $e');
        }
      }

      if (!launched) {
        // Show user-friendly message if all methods fail
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Could not open YouTube video. Trying alternative method...',
              ),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Copy URL',
                onPressed: () => _copyUrlToClipboard(url),
                textColor: Colors.white,
              ),
            ),
          );
        }
        // Try alternative method
        await _launchUrlAlternative(url);
      }
    } catch (e) {
      debugPrint('Could not launch YouTube URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Could not open YouTube video. URL copied to clipboard.',
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
              textColor: Colors.white,
            ),
          ),
        );
      }
      // Copy URL to clipboard as last resort
      await _copyUrlToClipboard(url);
    }
  }

  // Alternative method using platform channel
  Future<void> _launchUrlAlternative(String url) async {
    try {
      const platform = MethodChannel('flutter/platform');
      final Map<String, dynamic> arguments = {'url': url};
      await platform.invokeMethod('launchUrl', arguments);
    } catch (e) {
      debugPrint('Alternative launch method failed: $e');
      // Copy URL to clipboard as last resort
      await _copyUrlToClipboard(url);
    }
  }

  // Copy URL to clipboard as last resort
  Future<void> _copyUrlToClipboard(String url) async {
    try {
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'YouTube URL copied to clipboard. Please open it manually.',
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
              textColor: Colors.white,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to copy URL to clipboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final topResult =
        widget.analysisResult['topResult'] as Map<String, dynamic>;
    final allResults =
        widget.analysisResult['results'] as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Recognition Result'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image and basic info
              _buildImageSection(),
              const SizedBox(height: 20),

              // Detection results
              _buildDetectionResultsSection(topResult, allResults),
              const SizedBox(height: 20),

              // Food description
              _buildDescriptionSection(),
              const SizedBox(height: 20),

              // Nutrition info
              _buildNutritionSection(),
              const SizedBox(height: 20),

              // MealDB info
              _buildMealInfoSection(),
              const SizedBox(height: 20),

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(widget.imagePath),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Analyzed Image',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionResultsSection(
    Map<String, dynamic> topResult,
    List<Map<String, dynamic>> allResults,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Detection Results',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Top result
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topResult['label'],
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Confidence: ${(topResult['confidence'] * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.verified,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),

            // Other results
            if (allResults.length > 1) ...[
              const SizedBox(height: 12),
              Text(
                'Other Possibilities:',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
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
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '${(result['confidence'] * 100).toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodySmall,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Description',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Skeletonizer(
              enabled: _loadingDescription,
              effect: const ShimmerEffect(
                baseColor: Colors.grey,
                highlightColor: Colors.white,
                duration: Duration(seconds: 1),
              ),
              child: _loadingDescription
                  ? _buildSkeletonDescription()
                  : _descriptionError != null
                  ? Text(
                      'Unable to load description',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  : _foodDescription != null
                  ? Text(
                      _foodDescription!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 16, width: double.infinity, color: Colors.grey[300]),
        const SizedBox(height: 4),
        Container(height: 16, width: double.infinity, color: Colors.grey[300]),
        const SizedBox(height: 4),
        Container(height: 16, width: 200, color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildNutritionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_dining,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nutrition Info (per 100g)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Skeletonizer(
              enabled: _loadingNutrition,
              effect: const ShimmerEffect(
                baseColor: Colors.grey,
                highlightColor: Colors.white,
                duration: Duration(seconds: 1),
              ),
              child: _loadingNutrition
                  ? _buildSkeletonNutritionGrid()
                  : _nutritionError != null
                  ? Text(
                      'Unable to load nutrition info',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  : _nutrition != null
                  ? _buildNutritionGrid(_nutrition!)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionGrid(Nutrition nutrition) {
    final nutritionItems = [
      {'label': 'Calories', 'value': '${nutrition.calories}', 'unit': 'kcal'},
      {
        'label': 'Carbohydrate',
        'value': '${nutrition.carbohydrate}',
        'unit': 'g',
      },
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
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: nutritionItems.length,
      itemBuilder: (context, index) {
        final item = nutritionItems[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['label']!,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
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

  Widget _buildSkeletonNutritionGrid() {
    final skeletonItems = [
      {'label': 'Calories', 'value': '150', 'unit': 'kcal'},
      {'label': 'Carbohydrate', 'value': '20', 'unit': 'g'},
      {'label': 'Protein', 'value': '8', 'unit': 'g'},
      {'label': 'Fat', 'value': '5', 'unit': 'g'},
      {'label': 'Fiber', 'value': '3', 'unit': 'g'},
      {'label': 'Sugar', 'value': '2', 'unit': 'g'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: skeletonItems.length,
      itemBuilder: (context, index) {
        final item = skeletonItems[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['label']!,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recipe Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Skeletonizer(
              enabled: _loadingMealInfo,
              effect: const ShimmerEffect(
                baseColor: Colors.grey,
                highlightColor: Colors.white,
                duration: Duration(seconds: 1),
              ),
              child: _loadingMealInfo
                  ? _buildSkeletonMealInfo()
                  : _mealError != null || _mealInfo == null
                  ? Text(
                      'No recipe information found',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  : _buildMealInfoContent(_mealInfo!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonMealInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
        Container(height: 24, width: 200, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Container(height: 18, width: 100, color: Colors.grey[300]),
        const SizedBox(height: 4),
        Container(height: 16, width: double.infinity, color: Colors.grey[300]),
        const SizedBox(height: 4),
        Container(height: 16, width: double.infinity, color: Colors.grey[300]),
        const SizedBox(height: 4),
        Container(height: 16, width: 150, color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildMealInfoContent(Map<String, dynamic> mealInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mealInfo['strMealThumb'] != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              mealInfo['strMealThumb'],
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
        const SizedBox(height: 12),

        Text(
          mealInfo['strMeal'] ?? 'Unknown Recipe',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),

        // Category and Area info
        if (mealInfo['strCategory'] != null || mealInfo['strArea'] != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (mealInfo['strCategory'] != null) ...[
                Chip(
                  label: Text(mealInfo['strCategory']),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (mealInfo['strArea'] != null)
                Chip(
                  label: Text(mealInfo['strArea']),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.tertiaryContainer,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],

        // Show Detail Button
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showRecipeDetails = !_showRecipeDetails;
              });
            },
            icon: Icon(
              _showRecipeDetails ? Icons.expand_less : Icons.expand_more,
            ),
            label: Text(_showRecipeDetails ? 'Hide Details' : 'Show Details'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),

        // Expanded Recipe Details
        if (_showRecipeDetails) ...[
          const SizedBox(height: 16),
          _buildExpandedRecipeDetails(mealInfo),
        ],
      ],
    );
  }

  Widget _buildExpandedRecipeDetails(Map<String, dynamic> mealInfo) {
    final ingredients = _parseIngredients(mealInfo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ingredients Section
        if (ingredients.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ingredients (${ingredients.length} items)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...ingredients.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ingredient = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ingredient['ingredient']!,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                ingredient['measure']!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Instructions Section
        if (mealInfo['strInstructions'] != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.list_alt,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cooking Instructions',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  mealInfo['strInstructions'],
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Additional Information
        if (mealInfo['strYoutube'] != null || mealInfo['strTags'] != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Additional Information',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (mealInfo['strTags'] != null &&
                    mealInfo['strTags'].toString().isNotEmpty) ...[
                  Text(
                    'Tags:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: mealInfo['strTags']
                        .toString()
                        .split(',')
                        .map<Widget>(
                          (tag) => Chip(
                            label: Text(
                              tag.trim(),
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                if (mealInfo['strYoutube'] != null &&
                    mealInfo['strYoutube'].toString().isNotEmpty) ...[
                  Text(
                    'Video Tutorial:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _launchYouTubeUrl(mealInfo['strYoutube']);
                      },
                      icon: const Icon(
                        Icons.play_circle_fill,
                        color: Colors.red,
                      ),
                      label: const Text('Watch on YouTube'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.errorContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onErrorContainer,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            text: 'Back to Preview',
            onPressed: () {
              context.pop();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PrimaryButton(
            text: 'Back to Home',
            onPressed: () {
              context.go('/');
            },
          ),
        ),
      ],
    );
  }
}
