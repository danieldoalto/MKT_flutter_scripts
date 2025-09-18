import 'package:flutter/material.dart';

class OutputPanel extends StatelessWidget {
  final String title;
  final String content;

  const OutputPanel({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(content),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
