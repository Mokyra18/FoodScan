import 'package:flutter/material.dart';

class SettingFirebaseMLSection extends StatelessWidget {
  final Map<String, dynamic> modelInfo;
  final String modelStatus;
  final bool isModelLoading;
  final bool isCheckingModel;
  final Future<void> Function() downloadModel;
  final Future<void> Function() checkModelStatus;

  const SettingFirebaseMLSection({
    super.key,
    required this.modelInfo,
    required this.modelStatus,
    required this.isModelLoading,
    required this.isCheckingModel,
    required this.downloadModel,
    required this.checkModelStatus,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            modelInfo['isDownloaded'] == true
                ? Icons.check_circle
                : Icons.download,
            color: modelInfo['isDownloaded'] == true
                ? colorScheme.secondary
                : colorScheme.primary,
          ),
          title: Text("Status: $modelStatus"),
          subtitle:
              modelInfo['isDownloaded'] == true &&
                  modelInfo['sizeFormatted'] != null
              ? Text("Size: ${modelInfo['sizeFormatted']}")
              : const Text("Model required for recognition"),
        ),
        const SizedBox(height: 12),
        Text(
          "Download Firebase ML model to improve food recognition speed.",
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isModelLoading || isCheckingModel
                    ? null
                    : downloadModel,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: isModelLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        modelInfo['isDownloaded'] == true
                            ? Icons.refresh
                            : Icons.download,
                      ),
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
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isModelLoading || isCheckingModel
                    ? null
                    : checkModelStatus,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: isCheckingModel
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh),
                label: Text(isCheckingModel ? 'Checking...' : 'Check'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
