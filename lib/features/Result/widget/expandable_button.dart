import 'package:flutter/material.dart';

class ExpandableButton extends StatelessWidget {
  final bool expanded;
  final VoidCallback onPressed;

  const ExpandableButton({
    super.key,
    required this.expanded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
        label: FittedBox(
          child: Text(expanded ? 'Hide Details' : 'Show Details'),
        ),
      ),
    );
  }
}
