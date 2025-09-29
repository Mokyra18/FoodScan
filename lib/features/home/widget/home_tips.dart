import 'package:flutter/material.dart';

class HomeTips extends StatelessWidget {
  const HomeTips({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.lightbulb_outline),
      title: const Text("Tips for better results"),
      children: const [
        ListTile(title: Text("1. Ensure good lighting")),
        ListTile(title: Text("2. Keep the image clear & focused")),
        ListTile(title: Text("3. Avoid shadows and glare")),
      ],
    );
  }
}
