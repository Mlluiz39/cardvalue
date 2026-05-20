import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendário Financeiro')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              onDateChanged: (_) {},
            ),
          ),
          const SizedBox(height: 16),
          const Text('Eventos do Dia', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Card(child: ListTile(title: Text('Nenhum evento para esta data'))),
        ],
      ),
    );
  }
}
