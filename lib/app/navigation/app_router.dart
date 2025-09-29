import 'package:foodsnap/features/Result/presentation/result_page.dart';
import 'package:foodsnap/features/home/presentation/home_page.dart';
import 'package:foodsnap/features/preview/presentation/preview_page.dart';
import 'package:foodsnap/features/settings/presentation/settings_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String homeRoute = '/';
  static const String previewRoute = '/preview';
  static const String settingsRoute = '/settings';
  static const String resultRoute = '/result';

  static final GoRouter router = GoRouter(
    initialLocation: homeRoute,
    routes: [
      GoRoute(
        path: homeRoute,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: previewRoute,
        name: 'preview',
        builder: (context, state) {
          final imagePath = state.extra as String?;
          return PreviewPage(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: settingsRoute,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: resultRoute,
        name: 'result',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return ResultPage(
            imagePath: data?['imagePath'] ?? '',
            analysisResult: data?['analysisResult'] ?? {},
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 100,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),

              const SizedBox(height: 24),

              Text(
                "Oops! Page not found",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                "We couldn’t find the page: ${state.uri}\n"
                "Check the URL or go back to the homepage.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: () => context.go(homeRoute),
                icon: const Icon(Icons.home),
                label: const Text("Back to Home"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
