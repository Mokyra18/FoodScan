import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:flutter/foundation.dart';

enum ModelDownloadState { idle, downloading, ready, error }

class FirebaseModelService extends ChangeNotifier {
  FirebaseModelService._();
  static final instance = FirebaseModelService._();

  // Internal state
  ModelDownloadState _state = ModelDownloadState.idle;
  String? _error;
  double _progress = 0.0;
  File? _cachedModel;
  String? _currentModelName;

  // Public getters
  ModelDownloadState get state => _state;
  String? get error => _error;
  double get progress => _progress;
  bool get isReady =>
      _state == ModelDownloadState.ready && _cachedModel != null;
  bool get isDownloading => _state == ModelDownloadState.downloading;
  bool get hasError => _state == ModelDownloadState.error;

  // Download and cache the latest model from Firebase
  Future<File> downloadLatestModel({required String modelName}) async {
    if (_cachedModel != null &&
        _currentModelName == modelName &&
        _state == ModelDownloadState.ready) {
      return _cachedModel!;
    }

    _setState(ModelDownloadState.downloading);
    _error = null;
    _progress = 0.0;
    _currentModelName = modelName;

    try {
      _progress = 0.3;
      notifyListeners();

      final model = await FirebaseModelDownloader.instance.getModel(
        modelName,
        FirebaseModelDownloadType.localModelUpdateInBackground,
      );

      _progress = 0.8;
      notifyListeners();

      final file = File(model.file.path);
      if (!await file.exists()) {
        throw Exception('Model file not found after download');
      }

      _cachedModel = file;
      _progress = 1.0;
      _setState(ModelDownloadState.ready);

      return file;
    } on FirebaseException catch (e) {
      _handleFirebaseError(e);
      rethrow;
    } catch (e) {
      _error = _getGenericErrorMessage(e);
      _setState(ModelDownloadState.error);
      rethrow;
    }
  }

  // Handle Firebase-specific errors
  void _handleFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        _error = 'Access denied. Check internet connection and try again.';
        break;
      case 'unauthenticated':
        _error = 'Authentication failed. App needs to be reconfigured.';
        break;
      case 'not-found':
        _error = 'Model not found. Check app configuration.';
        break;
      case 'resource-exhausted':
        _error = 'Download quota exceeded. Try again later.';
        break;
      case 'unavailable':
        _error = 'Service unavailable. Check internet connection.';
        break;
      case 'deadline-exceeded':
        _error = 'Download timeout. Check internet connection and try again.';
        break;
      default:
        _error = 'Error Firebase: ${e.message ?? e.code}';
    }
    _setState(ModelDownloadState.error);
  }

  // Generic error handling
  String _getGenericErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Internet connection problem. Check connection and try again.';
    } else if (errorString.contains('timeout')) {
      return 'Download timeout. Try again with a more stable connection.';
    } else if (errorString.contains('storage') ||
        errorString.contains('space')) {
      return 'Not enough storage space. Clear storage device.';
    }
    return 'An error occurred: ${error.toString()}';
  }

  void retry() {
    if (_currentModelName != null) {
      downloadLatestModel(modelName: _currentModelName!);
    }
  }

  void _setState(ModelDownloadState newState) {
    _state = newState;
    notifyListeners();
  }

  void reset() {
    _state = ModelDownloadState.idle;
    _error = null;
    _progress = 0.0;
    _cachedModel = null;
    _currentModelName = null;
    notifyListeners();
  }
}
