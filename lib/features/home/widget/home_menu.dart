import 'package:flutter/material.dart';

class HomeMenu extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final bool isLoading;

  const HomeMenu({
    super.key,
    required this.onCapture,
    required this.onGallery,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _MenuCard(
          icon: Icons.camera_alt,
          label: isLoading ? "Processing..." : "Capture",
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          onTap: isLoading ? null : onCapture,
        ),
        _MenuCard(
          icon: Icons.photo_library,
          label: isLoading ? "Processing..." : "Gallery",
          backgroundColor: colorScheme.tertiary,
          foregroundColor: colorScheme.onTertiary,
          onTap: isLoading ? null : onGallery,
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [backgroundColor, backgroundColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: foregroundColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
