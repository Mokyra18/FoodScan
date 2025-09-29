import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class FirebaseMLService {
  static const String _modelName = 'food-classifier-v1';

  FirebaseModelDownloader? _modelDownloader;
  Interpreter? _interpreter;
  List<String>? _labels;

  static final FirebaseMLService _instance = FirebaseMLService._internal();
  factory FirebaseMLService() => _instance;
  FirebaseMLService._internal();

  Future<void> initialize() async {
    try {
      _modelDownloader = FirebaseModelDownloader.instance;
      print('Firebase ML Model Downloader initialized successfully');
    } catch (e) {
      print('Error initializing Firebase ML Model Downloader: $e');
      throw Exception('Failed to initialize Firebase ML Service: $e');
    }
  }

  Future<FirebaseCustomModel?> downloadModel({
    bool enableModelUpdates = true,
  }) async {
    if (_modelDownloader == null) {
      throw Exception('Firebase ML Service not initialized');
    }

    try {
      print('Attempting to download model: $_modelName');

      final FirebaseCustomModel customModel = await _modelDownloader!.getModel(
        _modelName,
        FirebaseModelDownloadType.latestModel,
        FirebaseModelDownloadConditions(
          iosAllowsCellularAccess: true,
          iosAllowsBackgroundDownloading: false,
          androidChargingRequired: false,
          androidWifiRequired: false,
          androidDeviceIdleRequired: false,
        ),
      );

      print('Model downloaded successfully: ${customModel.name}');
      print('Model size: ${customModel.size} bytes');

      await _loadTFLiteModel(customModel.file);

      return customModel;
    } catch (e) {
      print('Error downloading model: $e');

      try {
        final FirebaseCustomModel cachedModel = await _modelDownloader!
            .getModel(_modelName, FirebaseModelDownloadType.localModel);

        print('Using cached model: ${cachedModel.name}');
        await _loadTFLiteModel(cachedModel.file);
        return cachedModel;
      } catch (cacheError) {
        print('No cached model available: $cacheError');
        throw Exception('Model not available: $e');
      }
    }
  }

  Future<void> _loadTFLiteModel(File modelFile) async {
    try {
      _interpreter = Interpreter.fromFile(modelFile);
      print('TensorFlow Lite model loaded successfully');
      print('Input shape: ${_interpreter!.getInputTensors()}');
      print('Output shape: ${_interpreter!.getOutputTensors()}');
    } catch (e) {
      print('Error loading TensorFlow Lite model: $e');
      throw Exception('Failed to load TensorFlow Lite model: $e');
    }
  }

  Future<void> loadLabels() async {
    try {
      print('Loading labels from assets/labels.txt');
      final labelsData = await rootBundle.loadString('assets/labels.txt');

      _labels = labelsData
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      print('Labels loaded successfully: ${_labels?.length} labels found');
      print('Labels: $_labels');
    } catch (e) {
      print('Error loading labels from assets: $e');

      _labels = [
        'Pizza',
        'Burger',
        'Pasta',
        'Salad',
        'Sushi',
        'Steak',
        'Soup',
        'Dessert',
        'Rice',
        'Noodles',
      ];
      print('Using fallback labels: $_labels');
    }
  }

  List<List<List<List<int>>>> _preprocessImage(File imageFile, int inputSize) {
    try {
      final bytes = imageFile.readAsBytesSync();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Could not decode image');
      }

      image = img.copyResize(image, width: inputSize, height: inputSize);

      final input = List.generate(
        1,
        (_) => List.generate(
          inputSize,
          (y) => List.generate(
            inputSize,
            (x) => List.generate(3, (c) {
              final pixel = image!.getPixel(x, y);
              final value = c == 0
                  ? pixel.r
                  : c == 1
                  ? pixel.g
                  : pixel.b;
              return value.clamp(0, 255).toInt();
            }),
          ),
        ),
      );

      print(
        'Input tensor created with shape: [${input.length}, ${input[0].length}, ${input[0][0].length}, ${input[0][0][0].length}]',
      );
      return input;
    } catch (e) {
      print('Error preprocessing image: $e');
      throw Exception('Failed to preprocess image: $e');
    }
  }

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    if (_interpreter == null) {
      throw Exception('Model not loaded. Call downloadModel() first.');
    }

    if (_labels == null) {
      await loadLabels();
    }

    try {
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final inputSize = inputShape[1];
      final inputWidth = inputShape[2];
      final inputChannels = inputShape[3];

      print('Model input shape: $inputShape');
      print('Expected input size: ${inputSize}x${inputWidth}x$inputChannels');

      final inputData = _preprocessImage(imageFile, inputSize);

      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final numClasses = outputShape[1];
      final output = List.generate(1, (_) => List<int>.filled(numClasses, 0));

      print('Output tensor shape: $outputShape');
      print('Number of classes: $numClasses');
      print('Running inference...');

      _interpreter!.run(inputData, output);

      print('Inference completed successfully');

      final probs = output[0];
      int maxV = -2147483648;
      int maxI = 0;

      for (int i = 0; i < probs.length; i++) {
        if (probs[i] > maxV) {
          maxV = probs[i];
          maxI = i;
        }
      }

      final results = <Map<String, dynamic>>[];

      if (maxV > -2147483648 && maxI >= 0 && maxI < _labels!.length) {
        final totalScore = probs.reduce((a, b) => a + b);

        for (int i = 0; i < probs.length && i < _labels!.length; i++) {
          if (probs[i] > 0) {
            final confidence = totalScore > 0
                ? (probs[i].toDouble() / totalScore.toDouble()).abs()
                : 0.0;

            if (confidence > 0.001) {
              results.add({
                'label': _labels![i],
                'confidence': confidence.clamp(0.0, 1.0),
              });
            }
          }
        }

        if (results.isEmpty && maxI < _labels!.length) {
          results.add({'label': _labels![maxI], 'confidence': 0.5});
        }
      }

      results.sort((a, b) => b['confidence'].compareTo(a['confidence']));

      final topResults = results.take(10).toList();

      return {
        'results': topResults,
        'topResult': topResults.isNotEmpty
            ? topResults.first
            : {'label': 'Unknown', 'confidence': 0.0},
        'timestamp': DateTime.now().toIso8601String(),
        'totalClasses': probs.length,
        'nonZeroResults': results.length,
      };
    } catch (e) {
      print('Error analyzing image: $e');
      throw Exception('Failed to analyze image: $e');
    }
  }

  bool get isModelReady => _interpreter != null;

  Map<String, dynamic> get modelStatus => {
    'isInitialized': _modelDownloader != null,
    'isModelLoaded': _interpreter != null,
    'hasLabels': _labels != null,
    'modelName': _modelName,
  };

  Future<Map<String, dynamic>> getModelInfo() async {
    if (_modelDownloader == null) {
      return {'isDownloaded': false, 'error': 'Service not initialized'};
    }

    try {
      final localModel = await _modelDownloader!.getModel(
        _modelName,
        FirebaseModelDownloadType.localModel,
      );

      return {
        'isDownloaded': true,
        'name': localModel.name,
        'size': localModel.size,
        'sizeFormatted': _formatFileSize(localModel.size),
        'filePath': localModel.file.path,
        'isLoaded': _interpreter != null,
      };
    } catch (e) {
      return {'isDownloaded': false, 'error': 'Model not found locally'};
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (bytes.bitLength - 1) ~/ 10;
    if (i >= suffixes.length) i = suffixes.length - 1;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${suffixes[i]}';
  }

  Future<FirebaseCustomModel> downloadLatestModel() async {
    if (_modelDownloader == null) {
      throw Exception('Firebase ML Service not initialized');
    }

    try {
      print('Force downloading latest model: $_modelName');

      final model = await _modelDownloader!.getModel(
        _modelName,
        FirebaseModelDownloadType.latestModel,
        FirebaseModelDownloadConditions(
          iosAllowsCellularAccess: true,
          iosAllowsBackgroundDownloading: false,
          androidChargingRequired: false,
          androidWifiRequired: false,
          androidDeviceIdleRequired: false,
        ),
      );

      await _loadTFLiteModel(model.file);

      print('Latest model downloaded and loaded: ${model.name}');
      return model;
    } catch (e) {
      print('Error downloading latest model: $e');
      throw Exception('Failed to download latest model: $e');
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    print('Firebase ML Service disposed');
  }
}
