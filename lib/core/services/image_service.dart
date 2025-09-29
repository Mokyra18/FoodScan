import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

/// Service class to handle image operations
class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Request necessary permissions for camera and gallery
  static Future<bool> requestPermissions() async {
    try {
      final cameraStatus = await Permission.camera.request();
      final photoStatus = await Permission.photos.request();

      return cameraStatus.isGranted && photoStatus.isGranted;
    } catch (e) {
      print('Permission request error: $e');
      return false;
    }
  }

  /// Check if permissions are granted
  static Future<bool> hasPermissions() async {
    try {
      final cameraStatus = await Permission.camera.status;
      final photoStatus = await Permission.photos.status;

      return cameraStatus.isGranted && photoStatus.isGranted;
    } catch (e) {
      print('Permission check error: $e');
      return false;
    }
  }

  /// Pick image from camera
  static Future<String?> pickImageFromCamera() async {
    try {
      // Check permissions first
      if (!await hasPermissions()) {
        final granted = await requestPermissions();
        if (!granted) {
          throw Exception('Camera permissions are required');
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      return image?.path;
    } catch (e) {
      print('Camera capture error: $e');
      rethrow;
    }
  }

  /// Pick image from gallery
  static Future<String?> pickImageFromGallery() async {
    try {
      // Check permissions first
      if (!await hasPermissions()) {
        final granted = await requestPermissions();
        if (!granted) {
          throw Exception('Photo library permissions are required');
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      return image?.path;
    } catch (e) {
      print('Gallery selection error: $e');
      rethrow;
    }
  }

  /// Crop image
  static Future<String?> cropImage(
    String imagePath,
    BuildContext context,
  ) async {
    try {
      // Verify file exists
      final theme = Theme.of(context);
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found');
      }

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: theme.colorScheme.primary,
            toolbarWidgetColor: theme.colorScheme.onPrimary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
            showCropGrid: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            cancelButtonTitle: 'Cancel',
            doneButtonTitle: 'Done',
            minimumAspectRatio: 0.5,
            aspectRatioLockDimensionSwapEnabled: false,
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(width: 520, height: 520),
          ),
        ],
      );

      if (croppedFile != null) {
        // Verify cropped file was created
        final croppedFileExists = await File(croppedFile.path).exists();
        if (!croppedFileExists) {
          throw Exception('Cropped image was not saved properly');
        }
        return croppedFile.path;
      }

      return null; // User cancelled
    } catch (e) {
      print('Crop error: $e');
      rethrow;
    }
  }

  /// Delete temporary image file
  static Future<void> deleteImageFile(String? imagePath) async {
    if (imagePath == null) return;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Failed to delete image file: $e');
    }
  }

  /// Get image file size in bytes
  static Future<int?> getImageFileSize(String? imagePath) async {
    if (imagePath == null) return null;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      print('Failed to get image file size: $e');
    }
    return null;
  }

  /// Format file size to human readable string
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
