import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodsnap/core/services/firebase_ml_service.dart';
import 'package:foodsnap/core/services/image_service.dart';
import 'package:foodsnap/core/utils/ui_utils.dart';
import 'package:foodsnap/features/preview/widget/preview_action_buttons.dart';
import 'package:go_router/go_router.dart';


class PreviewPage extends StatefulWidget {
  final String? imagePath;
  final String? source; 

  const PreviewPage({
    super.key,
    required this.imagePath,
    required this.source, 
  });

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
    if (!mounted) return;
    SnackBarUtil.showError(context, message);
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    SnackBarUtil.showSuccess(context, message);
  }

  Future<void> _cropImage() async {
    if (_currentImagePath == null || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final croppedPath = await ImageService.cropImage(
        _currentImagePath!,
        context,
      );
      if (mounted && croppedPath != null) {
        setState(() => _currentImagePath = croppedPath);
        _showSuccessSnackBar('Image cropped successfully!');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to crop image: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _analyzeImage() async {
    if (_currentImagePath == null || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final firebaseMLService = FirebaseMLService();
      if (!firebaseMLService.modelStatus['isInitialized']) {
        await firebaseMLService.initialize();
      }
      if (!firebaseMLService.isModelReady) {
        _showSuccessSnackBar('Downloading ML model...');
        await firebaseMLService.downloadModel();
      }
      final results = await firebaseMLService.analyzeImage(
        File(_currentImagePath!),
      );
      if (mounted) {
        context.push(
          '/result',
          extra: {'imagePath': _currentImagePath!, 'analysisResult': results},
        );
      }
    } catch (e) {
      _showErrorSnackBar('Analysis failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentImagePath == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No image provided.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Image'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            padding: const EdgeInsets.only(bottom: 8.0),
            alignment: Alignment.center,
            child: Text(
              'Source: ${widget.source ?? 'Unknown'}',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).appBarTheme.foregroundColor?.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(_currentImagePath!), fit: BoxFit.cover),
                    if (_isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Analyzing...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          PreviewActionButtons(
            onCrop: _cropImage,
            onAnalyze: _analyzeImage,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
