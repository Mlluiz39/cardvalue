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
    return _local.watchAll(userId).map((rows) =>
        rows.map((row) => domain.CardModel(
          id: row.id,
          userId: row.userId,
          bankName: row.bankName,
          cardName: row.cardName,
          brand: row.brand,
          cardType: row.cardType,
          limitAmount: row.limitAmount,
          closingDay: row.closingDay,
          dueDay: row.dueDay,
          color: row.color,
          isActive: row.isActive,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
        )).toList());
  }

  Future<domain.CardModel?> getById(String id) async {
    final local = await _local.getById(id);
    if (local != null) {
      return domain.CardModel(
        id: local.id,
        userId: local.userId,
        bankName: local.bankName,
        cardName: local.cardName,
        brand: local.brand,
        cardType: local.cardType,
        limitAmount: local.limitAmount,
        closingDay: local.closingDay,
        dueDay: local.dueDay,
        color: local.color,
        isActive: local.isActive,
        createdAt: local.createdAt,
        updatedAt: local.updatedAt,
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
    final rows = await (_db.select(_db.cards)..where((c) => c.userId.equals(userId))).get();
    return rows.map((row) => domain.CardModel(
      id: row.id, userId: row.userId, bankName: row.bankName,
      cardName: row.cardName, brand: row.brand, cardType: row.cardType,
      limitAmount: row.limitAmount, closingDay: row.closingDay, dueDay: row.dueDay,
      color: row.color, isActive: row.isActive, createdAt: row.createdAt, updatedAt: row.updatedAt,
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