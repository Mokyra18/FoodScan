import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodsnap/app.dart';
import 'package:foodsnap/core/services/firebase_ml_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase ML Service
  try {
    final firebaseMLService = FirebaseMLService();
    await firebaseMLService.initialize();
    print('Firebase ML Service initialized successfully');
  } catch (e) {
    print('Firebase ML Service initialization failed: $e');
    // Continue app startup even if ML service fails
  }

  runApp(const FoodScanApp());
}
