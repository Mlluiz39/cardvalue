import 'dart:async';
import 'package:drift/drift.dart';
import '../../../../services/drift_database.dart';
import '../local/card_local_ds.dart';
import '../../domain/models/card.dart' as domain;

class CardRepository {
  final AppDatabase _db;
  late final CardLocalDs _local;

  CardRepository() : _db = AppDatabase() {
    _local = CardLocalDs(_db);
  }

  Stream<List<domain.CardModel>> watchAll(String userId) {
    final query = _db.customSelect(
      '''
      SELECT c.*, COALESCE(SUM(i.amount), 0.0) AS used_amount
      FROM cards c
      LEFT JOIN purchases p ON p.card_id = c.id
      LEFT JOIN installments i ON i.purchase_id = p.id AND i.status = 'pending'
      WHERE c.user_id = ?
      GROUP BY c.id
      ''',
      variables: [Variable.withString(userId)],
      readsFrom: {_db.cards, _db.purchases, _db.installments},
    );

    return query.watch().map((rows) =>
        rows.map((row) {
          final id = row.read<String>('id');
          final userId = row.read<String>('user_id');
          final bankName = row.read<String>('bank_name');
          final cardName = row.read<String>('card_name');
          final brand = row.read<String>('brand');
          final cardType = row.read<String>('card_type');
          final limitAmount = row.read<double>('limit_amount');
          final closingDay = row.read<int>('closing_day');
          final dueDay = row.read<int>('due_day');
          final color = row.readNullable<String>('color');
          final isActive = row.read<bool>('is_active');
          final createdAt = row.read<DateTime>('created_at');
          final updatedAt = row.read<DateTime>('updated_at');
          final usedAmount = row.read<double>('used_amount');

          return domain.CardModel(
            id: id,
            userId: userId,
            bankName: bankName,
            cardName: cardName,
            brand: brand,
            cardType: cardType,
            limitAmount: limitAmount,
            closingDay: closingDay,
            dueDay: dueDay,
            color: color,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            usedAmount: usedAmount,
          );
        }).toList());
  }

  Future<domain.CardModel?> getById(String id) async {
    final row = await _db.customSelect(
      '''
      SELECT c.*, COALESCE(SUM(i.amount), 0.0) AS used_amount
      FROM cards c
      LEFT JOIN purchases p ON p.card_id = c.id
      LEFT JOIN installments i ON i.purchase_id = p.id AND i.status = 'pending'
      WHERE c.id = ?
      GROUP BY c.id
      ''',
      variables: [Variable.withString(id)],
    ).getSingleOrNull();

    if (row != null) {
      return domain.CardModel(
        id: row.read<String>('id'),
        userId: row.read<String>('user_id'),
        bankName: row.read<String>('bank_name'),
        cardName: row.read<String>('card_name'),
        brand: row.read<String>('brand'),
        cardType: row.read<String>('card_type'),
        limitAmount: row.read<double>('limit_amount'),
        closingDay: row.read<int>('closing_day'),
        dueDay: row.read<int>('due_day'),
        color: row.readNullable<String>('color'),
        isActive: row.read<bool>('is_active'),
        createdAt: row.read<DateTime>('created_at'),
        updatedAt: row.read<DateTime>('updated_at'),
        usedAmount: row.read<double>('used_amount'),
      );
    }
    return null;
  }

  Future<domain.CardModel> create(domain.CardModel card) async {
    await _local.upsert(_toDrift(card));
    return card;
  }

  Future<domain.CardModel> update(domain.CardModel card) async {
    await _local.upsert(_toDrift(card));
    return card;
  }

  Future<void> delete(String id) async {
    await _local.delete(id);
  }

  Future<List<domain.CardModel>> getAll(String userId) async {
    final rows = await _db.customSelect(
      '''
      SELECT c.*, COALESCE(SUM(i.amount), 0.0) AS used_amount
      FROM cards c
      LEFT JOIN purchases p ON p.card_id = c.id
      LEFT JOIN installments i ON i.purchase_id = p.id AND i.status = 'pending'
      WHERE c.user_id = ?
      GROUP BY c.id
      ''',
      variables: [Variable.withString(userId)],
    ).get();

    return rows.map((row) => domain.CardModel(
      id: row.read<String>('id'),
      userId: row.read<String>('user_id'),
      bankName: row.read<String>('bank_name'),
      cardName: row.read<String>('card_name'),
      brand: row.read<String>('brand'),
      cardType: row.read<String>('card_type'),
      limitAmount: row.read<double>('limit_amount'),
      closingDay: row.read<int>('closing_day'),
      dueDay: row.read<int>('due_day'),
      color: row.readNullable<String>('color'),
      isActive: row.read<bool>('is_active'),
      createdAt: row.read<DateTime>('created_at'),
      updatedAt: row.read<DateTime>('updated_at'),
      usedAmount: row.read<double>('used_amount'),
    )).toList();
  }

  CardsCompanion _toDrift(domain.CardModel card) {
    return CardsCompanion(
      id: Value(card.id),
      userId: Value(card.userId),
      bankName: Value(card.bankName),
      cardName: Value(card.cardName),
      brand: Value(card.brand),
      cardType: Value(card.cardType),
      limitAmount: Value(card.limitAmount),
      closingDay: Value(card.closingDay),
      dueDay: Value(card.dueDay),
      color: Value<String?>(card.color),
      isActive: Value(card.isActive),
    );
  }
}