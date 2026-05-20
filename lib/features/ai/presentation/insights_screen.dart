import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights de IA')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue.shade50,
            child: const ListTile(
              leading: Icon(Icons.lightbulb, color: Colors.blue),
              title: Text('Análise Inteligente'),
              subtitle: Text('Seus insights financeiros aparecerão aqui após analisar seus dados.'),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Categorias com Maior Gasto', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Card(child: ListTile(title: Text('Nenhum dado disponível'))),
          const SizedBox(height: 16),
          const Text('Alertas', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Card(child: ListTile(title: Text('Nenhum alerta no momento'))),
        ],
      ),
    );
  }
}
