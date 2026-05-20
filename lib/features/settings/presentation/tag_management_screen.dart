import 'package:flutter/material.dart';

class TagManagementScreen extends StatelessWidget {
  const TagManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tags')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('urgente')),
              Chip(label: Text('recorrente')),
              Chip(label: Text('assinatura')),
              Chip(label: Text('trabalho')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
