import 'package:flutter/material.dart';
import 'package:foodsnap/core/services/firebase_ml_service.dart';
import 'package:foodsnap/core/services/image_service.dart';
import 'package:foodsnap/core/utils/ui_utils.dart';
import 'package:foodsnap/shared/widget/custom_button.dart';
import 'package:foodsnap/shared/widget/custom_widget.dart';
import 'package:foodsnap/shared/widget/widget_common.dart';
import 'package:go_router/go_router.dart';

import 'dart:io';

class PreviewPage extends StatefulWidget {
  final String? imagePath;

  const PreviewPage({super.key, required this.imagePath});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  String? _currentImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
  }

  void _showErrorSnackBar(String message) {
    SnackBarUtil.showError(context, message);
  }

  void _showSuccessSnackBar(String message) {
    SnackBarUtil.showSuccess(context, message);
  }

  Future<void> _cropImage() async {
    if (_currentImagePath == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final croppedPath = await ImageService.cropImage(
        _currentImagePath!,
        context,
      );

      if (!mounted) return; // Check if widget is still mounted

      if (croppedPath != null) {
        setState(() {
          _currentImagePath = croppedPath;
        });
        _showSuccessSnackBar('Image cropped successfully!');
      } else {
        _showSuccessSnackBar('Crop cancelled');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to crop image: ${e.toString()}');
      }
      print('Crop error: $e'); // For debugging
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _retakePhoto() {
    context.pop();
  }

  Future<void> _analyzeImage() async {
    if (_currentImagePath == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final firebaseMLService = FirebaseMLService();

      // Initialize Firebase ML service if not already initialized
      if (!firebaseMLService.modelStatus['isInitialized']) {
        SnackBarUtil.showInfo(context, 'Initializing Firebase ML service...');
        await firebaseMLService.initialize();
      }

      // Download model if not already loaded
      if (!firebaseMLService.isModelReady) {
        SnackBarUtil.showInfo(context, 'Downloading ML model...');
        await firebaseMLService.downloadModel();
      }

      // Analyze the image
      SnackBarUtil.showInfo(context, 'Analyzing image...');
      final results = await firebaseMLService.analyzeImage(
        File(_currentImagePath!),
      );

      if (!mounted) return;

      // Show results dialog
      _showAnalysisResults(results);

      // Navigate to result page
      context.push(
        '/result',
        extra: {'imagePath': _currentImagePath!, 'analysisResult': results},
      );
    } catch (e) {
      if (!mounted) return;

      print('Analysis error: $e');
      _showErrorSnackBar('Analysis failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAnalysisResults(Map<String, dynamic> results) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final topResult = results['topResult'] as Map<String, dynamic>;
        final allResults = results['results'] as List<Map<String, dynamic>>;

        return AlertDialog(
          title: const Text('Food Recognition Results'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Result: ${topResult['label']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Confidence: ${(topResult['confidence'] * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'All Results:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...allResults
                  .take(5)
                  .map(
                    (result) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(result['label']),
                          Text(
                            '${(result['confidence'] * 100).toStringAsFixed(1)}%',
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentImagePath == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Preview'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: const EmptyStateWidget(
          title: 'No image selected',
          subtitle: 'Please go back and select an image',
          icon: Icons.image_not_supported,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: _retakePhoto,
            icon: const Icon(Icons.refresh),
            tooltip: 'Retake photo',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: CustomCard(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: _isLoading
                      ? const LoadingWidget(message: 'Processing image...')
                      : CustomImageWidget(
                          imagePath: _currentImagePath,
                          fit: BoxFit.contain,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                          errorMessage: 'Failed to load image',
                        ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                PrimaryButton(
                  text: _isLoading ? 'Cropping...' : 'Crop Image',
                  icon: Icons.crop,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _cropImage,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'Identify Food',
                  icon: Icons.restaurant_menu,
                  onPressed: _isLoading ? null : _analyzeImage,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  text: 'Retake Photo',
                  icon: Icons.camera_alt,
                  onPressed: _isLoading ? null : _retakePhoto,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
