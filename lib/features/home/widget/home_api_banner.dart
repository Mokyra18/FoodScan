import 'package:flutter/material.dart';

class HomeApiBanner extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const HomeApiBanner({super.key, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: const Text(
        "You need to set up your Gemini API Key in Settings to continue.",
      ),
      leading: const Icon(Icons.key, color: Colors.red),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      actions: [
        TextButton.icon(
          onPressed: onSettingsTap,
          icon: const Icon(Icons.settings),
          label: const Text("Setup"),
        ),
      ],
    );
  }
}
