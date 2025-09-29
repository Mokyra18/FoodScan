import 'package:flutter/material.dart';

class SettingApiKeySection extends StatelessWidget {
  final bool hasApiKey;
  final String? currentApiKey;
  final TextEditingController apiKeyController;
  final Future<void> Function() saveApiKey;
  final Future<void> Function() removeApiKey;
  final Future<void> Function() testApiKey;
  final void Function() onEdit;

  const SettingApiKeySection({
    super.key,
    required this.hasApiKey,
    required this.currentApiKey,
    required this.apiKeyController,
    required this.saveApiKey,
    required this.removeApiKey,
    required this.testApiKey,
    required this.onEdit,
  });

  String _getMaskedApiKey() {
    final key = currentApiKey ?? '';
    if (key.length > 8) {
      return '${key.substring(0, 8)}...****';
    }
    return key;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (hasApiKey) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.check_circle, color: scheme.secondary),
            title: Text(
              "API Key is configured",
              style: TextStyle(color: scheme.secondary),
            ),
            subtitle: Text("Current: ${_getMaskedApiKey()}"),
          ),
          const SizedBox(height: 12),
          Wrap(
            runSpacing: 8,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    apiKeyController.text = currentApiKey ?? '';
                    onEdit();
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Key'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: testApiKey,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Test Key'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: removeApiKey,
                  icon: const Icon(Icons.delete),
                  label: const Text('Remove Key'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.warning, color: scheme.tertiary),
          title: const Text("API Key required"),
          subtitle: const Text("Needed for nutrition features"),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: apiKeyController,
          decoration: InputDecoration(
            labelText: 'Enter your Gemini API Key',
            hintText: 'AIzaSy...',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.vpn_key),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: saveApiKey,
            icon: const Icon(Icons.save),
            label: const Text('Save API Key'),
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
