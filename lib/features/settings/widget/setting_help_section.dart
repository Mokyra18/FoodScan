import 'package:flutter/material.dart';

class SettingHelpSection extends StatelessWidget {
  final Future<void> Function() launchApiKeyUrl;

  const SettingHelpSection({super.key, required this.launchApiKeyUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("To use nutrition features, you need a Gemini API Key:"),
        const SizedBox(height: 12),
        const Text("1. Visit Google AI Studio"),
        const Text("2. Sign in with your Google account"),
        const Text("3. Create a new API key"),
        const Text("4. Copy and paste it above"),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: launchApiKeyUrl,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Google AI Studio'),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: const [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Your API key is stored locally and securely on your device.",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
