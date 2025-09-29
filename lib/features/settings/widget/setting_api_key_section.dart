import 'package:flutter/material.dart';

class SettingApiKeySection extends StatelessWidget {
  final bool hasApiKey;
  final String? currentApiKey;
  final TextEditingController apiKeyController;
  final Future<void> Function() saveApiKey;
  final Future<void> Function() removeApiKey;
  final Future<void> Function() testApiKey;

  const SettingApiKeySection({
    super.key,
    required this.hasApiKey,
    required this.currentApiKey,
    required this.apiKeyController,
    required this.saveApiKey,
    required this.removeApiKey,
    required this.testApiKey,
  });

  // Fungsi helper untuk menyamarkan API key dengan aman.
  String _getMaskedApiKey() {
    final key = currentApiKey ?? '';
    // PERBAIKAN: Hanya panggil substring jika panjang string mencukupi.
    if (key.length > 8) {
      return '${key.substring(0, 8)}...****';
    }
    // Jika tidak, tampilkan key apa adanya.
    return key;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Kode untuk judul tetap sama)
            Row(
              children: [
                Icon(Icons.key, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Gemini API Key',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tampilan jika sudah ada API Key
            if (hasApiKey) ...[
              // ... (Kode untuk status "configured" tetap sama)
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'API Key is configured',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                // Menggunakan fungsi helper yang aman
                'Current API Key: ${_getMaskedApiKey()}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // ... (Sisa kode untuk tombol-tombol tetap sama)
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      apiKeyController.text = currentApiKey ?? '';
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Key'),
                  ),
                  OutlinedButton.icon(
                    onPressed: testApiKey,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Test Key'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: removeApiKey,
                  icon: const Icon(Icons.delete),
                  label: const Text('Remove Key'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ]
            // Tampilan jika belum ada API Key
            else ...[
              // ... (Sisa kode untuk input API Key tetap sama)
              Row(
                children: const [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'API Key required for nutrition features',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'Enter your Gemini API Key',
                  hintText: 'AIzaSy...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your API Key';
                  }
                  if (!value.startsWith('AIza')) {
                    return 'Invalid API Key format';
                  }
                  if (value.length < 35) {
                    return 'API Key seems too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: saveApiKey,
                  icon: const Icon(Icons.save),
                  label: const Text('Save API Key'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
