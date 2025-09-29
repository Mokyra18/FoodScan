import 'package:flutter/material.dart';

class SettingServiceStatusSection extends StatelessWidget {
  final Map<String, dynamic> serviceStatus;
  final Future<void> Function() refreshStatus;

  const SettingServiceStatusSection({
    super.key,
    required this.serviceStatus,
    required this.refreshStatus,
  });

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
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Service Status',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (serviceStatus.containsKey('error')) ...[
              ListTile(
                leading: const Icon(Icons.error, color: Colors.red),
                title: const Text('Services Error'),
                subtitle: Text(serviceStatus['error']),
                tileColor: Colors.red.withOpacity(0.1),
              ),
            ] else ...[
              ListTile(
                leading: Icon(
                  serviceStatus['gemini']?['enabled'] == true
                      ? Icons.check_circle
                      : Icons.warning,
                  color: serviceStatus['gemini']?['enabled'] == true
                      ? Colors.green
                      : Colors.orange,
                ),
                title: const Text('Gemini API'),
                subtitle: Text(serviceStatus['gemini']?['status'] ?? 'Unknown'),
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  serviceStatus['firebaseML']?['isModelLoaded'] == true
                      ? Icons.check_circle
                      : Icons.warning,
                  color: serviceStatus['firebaseML']?['isModelLoaded'] == true
                      ? Colors.green
                      : Colors.orange,
                ),
                title: const Text('Firebase ML'),
                subtitle: Text(
                  serviceStatus['firebaseML']?['isModelLoaded'] == true
                      ? 'Model loaded and ready'
                      : 'Model not loaded',
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: refreshStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
