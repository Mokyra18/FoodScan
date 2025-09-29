import 'package:flutter/material.dart';

class SettingHelpSection extends StatelessWidget {
  final Future<void> Function() launchApiKeyUrl;

  const SettingHelpSection({super.key, required this.launchApiKeyUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'How to get API Key',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('To use nutrition features, you need a Gemini API Key:'),
            const SizedBox(height: 12),
            const Text('1. Visit Google AI Studio'),
            const Text('2. Sign in with your Google account'),
            const Text('3. Create a new API key'),
            const Text('4. Copy and paste the key above'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: launchApiKeyUrl,
                icon: const Icon(Icons.content_copy),
                label: const Text('Copy Google AI Studio URL'),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Your API key is stored locally and securely on your device.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
