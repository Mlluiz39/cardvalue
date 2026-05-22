import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../installments/presentation/purchase_providers.dart';
import '../../cards/presentation/card_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(cardListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendário Financeiro')),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Card(
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              onDateChanged: (date) => setState(() => _selectedDate = date),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Eventos de ${_selectedDate.format('dd/MM/yyyy')}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          cardsAsync.when(
            data: (cards) {
              final events = <_CalendarEvent>[];

              for (final card in cards) {
                if (card.closingDay == _selectedDate.day) {
                  events.add(_CalendarEvent(
                    title: 'Fechamento - ${card.bankName}',
                    subtitle: card.cardName,
                    icon: Icons.credit_card,
                    color: AppColors.warning,
                  ));
                }
                if (card.dueDay == _selectedDate.day) {
                  events.add(_CalendarEvent(
                    title: 'Vencimento - ${card.bankName}',
                    subtitle: card.cardName,
                    icon: Icons.payment,
                    color: AppColors.expense,
                  ));
                }
              }

              if (events.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        Icon(Icons.event_available, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: AppSpacing.md),
                        Text('Nenhum evento para esta data', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: events.map((event) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: event.color.withValues(alpha: 0.2),
                      child: Icon(event.icon, color: event.color),
                    ),
                    title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(event.subtitle),
                  ),
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text('Erro ao carregar eventos', style: TextStyle(color: AppColors.expense)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarEvent {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  _CalendarEvent({required this.title, required this.subtitle, required this.icon, required this.color});
}
