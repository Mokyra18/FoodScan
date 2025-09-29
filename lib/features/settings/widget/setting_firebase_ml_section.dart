import 'package:flutter/material.dart';

class SettingFirebaseMLSection extends StatelessWidget {
  final Map<String, dynamic> modelInfo;
  final String modelStatus;
  final bool isModelLoading;
  final Future<void> Function() downloadModel;
  final Future<void> Function() checkModelStatus;

  const SettingFirebaseMLSection({
    super.key,
    required this.modelInfo,
    required this.modelStatus,
    required this.isModelLoading,
    required this.downloadModel,
    required this.checkModelStatus,
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
                Icon(Icons.smart_toy, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Firebase ML Model',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  modelInfo['isDownloaded'] == true ? Icons.check_circle : Icons.download,
                  color: modelInfo['isDownloaded'] == true ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: $modelStatus',
                        style: TextStyle(
                          color: modelInfo['isDownloaded'] == true ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (modelInfo['isDownloaded'] == true && modelInfo['sizeFormatted'] != null)
                        Text(
                          'Size: ${modelInfo['sizeFormatted']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'The Firebase ML model is used for food recognition. Download it now to avoid waiting during image analysis.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isModelLoading ? null : downloadModel,
                    icon: isModelLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(modelInfo['isDownloaded'] == true ? Icons.refresh : Icons.download),
                    label: Text(
                      isModelLoading
                          ? 'Downloading...'
                          : modelInfo['isDownloaded'] == true
                              ? 'Update Model'
                              : 'Download Model',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: isModelLoading ? null : checkModelStatus,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check Status'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
