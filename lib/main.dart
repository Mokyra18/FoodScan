import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodsnap/app.dart';
import 'package:foodsnap/core/services/firebase_ml_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    final firebaseMLService = FirebaseMLService();
    await firebaseMLService.initialize();
    print('Firebase ML Service initialized successfully');
  } catch (e) {
    print('Firebase ML Service initialization failed: $e');
  }

  runApp(const FoodScanApp());
}
