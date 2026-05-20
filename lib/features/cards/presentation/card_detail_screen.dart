import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/credit_card_widget.dart';
import '../../../shared/widgets/invoice_timeline.dart';
import 'card_providers.dart';

class CardDetailScreen extends ConsumerWidget {
  final String cardId;

  const CardDetailScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardAsync = ref.watch(cardDetailProvider(cardId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Cartão'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/cards/$cardId/edit'),
          ),
        ],
      ),
      body: cardAsync.when(
        data: (card) {
          if (card == null) return const Center(child: Text('Cartão não encontrado'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CreditCardWidget(
                bankName: card.bankName,
                cardName: card.cardName,
                lastDigits: card.id.length >= 4 ? card.id.substring(card.id.length - 4) : card.id,
                usedAmount: card.usedAmount,
                totalLimit: card.limitAmount,
                closingDayText: 'Fecha ${card.closingDay}',
                dueDayText: 'Vence ${card.dueDay}',
                color: card.color != null ? Color(int.parse(card.color!.replaceFirst('#', '0xFF'))) : Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text('Faturas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InvoiceTimeline(
                months: [],
                selectedIndex: 0,
                onMonthSelected: (_) {},
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
