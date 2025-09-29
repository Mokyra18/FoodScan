import 'dart:io';
import 'dart:isolate';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

Future<Map<String, dynamic>> _runInferenceIsolate(
  (String, int, List<String>) params,
) async {
  final imagePath = params.$1;
  final interpreterAddress = params.$2;
  final labels = params.$3;

  final interpreter = Interpreter.fromAddress(interpreterAddress);
  final imageFile = File(imagePath);


  final inputShape = interpreter.getInputTensor(0).shape;
  final inputSize = inputShape[1];
  final bytes = imageFile.readAsBytesSync();
  img.Image? image = img.decodeImage(bytes);
  if (image == null) throw Exception('Could not decode image');
  final resizedImage = img.copyResize(
    image,
    width: inputSize,
    height: inputSize,
  );

  final imageBytes = resizedImage.getBytes(order: img.ChannelOrder.rgb);
  final inputBuffer = List.generate(
    1,
    (_) => List.generate(
      inputSize,
      (_) => List.generate(inputSize, (_) => List.filled(3, 0)), 
    ),
  );

  int pixelIndex = 0;
  for (int i = 0; i < inputSize; i++) {
    for (int j = 0; j < inputSize; j++) {
      inputBuffer[0][i][j][0] = imageBytes[pixelIndex++];
      inputBuffer[0][i][j][1] = imageBytes[pixelIndex++];
      inputBuffer[0][i][j][2] = imageBytes[pixelIndex++];
    }
  }

  final outputShape = interpreter.getOutputTensor(0).shape;
  final numClasses = outputShape[1];
  final output = List.generate(1, (_) => List<int>.filled(numClasses, 0));

  interpreter.run(inputBuffer, output);

  final probabilities = output[0];
  final results = <Map<String, dynamic>>[];

  final totalScore = probabilities.reduce((a, b) => a + b);

  for (int i = 0; i < probabilities.length; i++) {
    final confidence = totalScore > 0
        ? probabilities[i].toDouble() / totalScore.toDouble()
        : 0.0;
    if (confidence > 0.01) {
      results.add({'label': labels[i], 'confidence': confidence});
    }
  }

  results.sort(
    (a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double),
  );

  return {
    'results': results,
    'topResult': results.isNotEmpty
        ? results.first
        : {'label': 'Unknown', 'confidence': 0.0},
  };
}

class FirebaseMLService {
  static const String _modelName = 'food-classifier-v1';

  Interpreter? _interpreter;
  List<String>? _labels;

  static final FirebaseMLService _instance = FirebaseMLService._internal();
  factory FirebaseMLService() => _instance;
  FirebaseMLService._internal();

  Future<void> downloadModel() async {
    final modelDownloader = FirebaseModelDownloader.instance;
    try {
      final model = await modelDownloader.getModel(
        _modelName,
        FirebaseModelDownloadType.latestModel,
        FirebaseModelDownloadConditions(iosAllowsCellularAccess: true),
      );
      _loadTFLiteModel(model.file);
      await _loadLabels();
    } catch (e) {
      debugPrint("Error downloading or loading model: $e");
      throw Exception("Failed to prepare model.");
    }
  }

  void _loadTFLiteModel(File modelFile) {
    try {
      _interpreter = Interpreter.fromFile(modelFile);
    } catch (e) {
      debugPrint("Error loading TFLite model: $e");
      rethrow;
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData
          .split('\n')
          .where((line) => line.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint("Error loading labels: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    if (_interpreter == null || _labels == null) {
      debugPrint("Model or labels not loaded. Downloading...");
      await downloadModel();
      if (_interpreter == null || _labels == null) {
        throw Exception('Model initialization failed after download.');
      }
    }

    final params = (imageFile.path, _interpreter!.address, _labels!);

    return Isolate.run(() => _runInferenceIsolate(params));
  }

  bool get isModelReady => _interpreter != null;

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
