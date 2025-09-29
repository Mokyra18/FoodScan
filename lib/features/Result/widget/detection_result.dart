import 'package:flutter/material.dart';
import 'section_title.dart';

class DetectionResults extends StatelessWidget {
  final List<Map<String, dynamic>> results;

  const DetectionResults({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "Detection Results", icon: Icons.search),
        const SizedBox(height: 12),
        ...results.map((result) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.fastfood,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                result['label'],
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                "Confidence: ${(result['confidence'] * 100).toStringAsFixed(2)}%",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
