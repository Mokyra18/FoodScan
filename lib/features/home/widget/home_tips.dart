import 'package:flutter/material.dart';

class HomeTips extends StatelessWidget {
  const HomeTips({super.key});

  Widget _buildTipRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return ExpansionTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: colorScheme.surface,
      collapsedBackgroundColor: colorScheme.surfaceContainer,

      leading: Icon(
        Icons.auto_awesome_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
      title: Text(
        "Pro Tips for Clear Scans",
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        _buildTipRow(
          context,
          Icons.wb_sunny_outlined,
          "Use bright, even lighting to reveal all food details.",
        ),
        _buildTipRow(
          context,
          Icons.center_focus_strong_outlined,
          "Tap your screen to focus on the food, ensuring a sharp image.",
        ),
        _buildTipRow(
          context,
          Icons.fullscreen_exit_outlined,
          "Position your camera to avoid casting harsh shadows on the dish.",
        ),
      ],
    );
  }
}
