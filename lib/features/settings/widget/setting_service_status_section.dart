import 'package:flutter/material.dart';

class SettingServiceStatusSection extends StatelessWidget {
  final Map<String, dynamic> serviceStatus;
  final Future<void> Function() refreshStatus;
  final bool isRefreshing;

  const SettingServiceStatusSection({
    super.key,
    required this.serviceStatus,
    required this.refreshStatus,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        ListTile(
          leading: Icon(
            serviceStatus['gemini']?['enabled'] == true
                ? Icons.check_circle
                : Icons.warning,
            color: serviceStatus['gemini']?['enabled'] == true
                ? colorScheme.secondary
                : colorScheme.primary,
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
                ? colorScheme.secondary
                : colorScheme.primary,
          ),
          title: const Text('Firebase ML'),
          subtitle: Text(
            serviceStatus['firebaseML']?['isModelLoaded'] == true
                ? 'Model loaded and ready'
                : 'Model not loaded',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isRefreshing ? null : refreshStatus,
            icon: isRefreshing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
            label: Text(isRefreshing ? 'Refreshing...' : 'Refresh Status'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
