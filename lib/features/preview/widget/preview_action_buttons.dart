import 'package:flutter/material.dart';

class PreviewActionButtons extends StatelessWidget {
  final VoidCallback onCrop;
  final VoidCallback onAnalyze;
  final bool isLoading;

  const PreviewActionButtons({
    super.key,
    required this.onCrop,
    required this.onAnalyze,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onAnalyze,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('Identify Food'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onCrop,
                icon: const Icon(Icons.crop_rotate),
                label: const Text('Crop or Rotate'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: colorScheme.onSurfaceVariant,
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
