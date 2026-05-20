import 'package:flutter/material.dart';

class GoalDetailScreen extends StatelessWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Meta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $goalId', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            const Text('Detalhes completos serão exibidos aqui.'),
          ],
        ),
      ),
    );
  }
}
