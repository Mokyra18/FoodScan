import 'package:flutter/material.dart';
import 'package:foodsnap/app/navigation/app_router.dart';
import 'package:foodsnap/app/theme/app_theme.dart';

class FoodScanApp extends StatelessWidget {
  const FoodScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FoodScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
