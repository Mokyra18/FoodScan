import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onSettingsTap;
  final bool hasApiKey;

  const HomeHeader({
    super.key,
    required this.onSettingsTap,
    required this.hasApiKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundColor: Colors.orange,
          child: Icon(Icons.fastfood, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "FoodSnap",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "Recognize your food instantly",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: onSettingsTap,
          tooltip: "Settings",
          color: hasApiKey
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }
}
