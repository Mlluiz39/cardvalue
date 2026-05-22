import 'package:flutter/material.dart';
import '../../features/cards/domain/models/card.dart';

class CardSelector extends StatelessWidget {
  final List<CardModel> cards;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  const CardSelector({
    super.key,
    required this.cards,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedId,
      decoration: const InputDecoration(labelText: 'Cartão'),
      items: cards.map((card) => DropdownMenuItem(
        value: card.id,
        child: Text('${card.bankName} - ${card.cardName}'),
      )).toList(),
      onChanged: onSelected,
    );
  }
}
