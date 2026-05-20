import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/credit_card_widget.dart';
import 'card_providers.dart';

class CardListScreen extends ConsumerWidget {
  const CardListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cartões')),
      body: cardsAsync.when(
        data: (cards) => cards.isEmpty
            ? const Center(child: Text('Nenhum cartão cadastrado'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cards.length,
                itemBuilder: (_, i) {
                  final card = cards[i];
                  return CreditCardWidget(
                    bankName: card.bankName,
                    cardName: card.cardName,
                    lastDigits: card.id.length >= 4 ? card.id.substring(card.id.length - 4) : card.id,
                    usedAmount: card.usedAmount,
                    totalLimit: card.limitAmount,
                    closingDayText: 'Fecha ${card.closingDay}',
                    dueDayText: 'Vence ${card.dueDay}',
                    color: card.color != null ? Color(int.parse(card.color!.replaceFirst('#', '0xFF'))) : Colors.blue,
                    onTap: () => context.push('/cards/${card.id}'),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/cards/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
