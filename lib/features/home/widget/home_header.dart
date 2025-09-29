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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: colorScheme.primary,
          child: Icon(Icons.fastfood, color: colorScheme.onPrimary, size: 30),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "FoodSnap",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Recognize your food instantly",
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: onSettingsTap,
          tooltip: "Settings",
          color: hasApiKey ? colorScheme.primary : colorScheme.error,
        ),
      ],
    );
  }
}
