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
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _MenuCard(
          icon: Icons.camera_alt,
          label: isLoading ? "Capturing..." : "Capture",
          color: Colors.green,
          onTap: isLoading ? null : onCapture,
        ),
        _MenuCard(
          icon: Icons.photo,
          label: isLoading ? "Selecting..." : "Gallery",
          color: Colors.blue,
          onTap: isLoading ? null : onGallery,
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
