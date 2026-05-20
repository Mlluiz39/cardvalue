import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'drift_database.g.dart';

class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get bankName => text()();
  TextColumn get cardName => text()();
  TextColumn get brand => text()();
  TextColumn get cardType => text().withDefault(const Constant('physical'))();
  RealColumn get limitAmount => real()();
  IntColumn get closingDay => integer()();
  IntColumn get dueDay => integer()();
  TextColumn? get color => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Purchases extends Table {
  TextColumn get id => text()();
  TextColumn get cardId => text().references(Cards, #id)();
  TextColumn get userId => text()();
  TextColumn get merchantName => text()();
  RealColumn get totalAmount => real()();
  TextColumn get categoryId => text()();
  DateTimeColumn get purchaseDate => dateTime()();
  IntColumn get installmentCount => integer()();
  TextColumn? get notes => text().nullable()();
  BoolColumn get isReconciled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Installments extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseId => text().references(Purchases, #id)();
  TextColumn? get invoiceCycleId => text().references(InvoiceCycles, #id).nullable()();
  TextColumn get userId => text()();
  IntColumn get sequenceNumber => integer()();
  IntColumn get totalInstallments => integer()();
  RealColumn get amount => real()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn? get paidAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class InvoiceCycles extends Table {
  TextColumn get id => text()();
  TextColumn get cardId => text().references(Cards, #id)();
  TextColumn get userId => text()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  DateTimeColumn get closingDate => dateTime()();
  DateTimeColumn get dueDate => dateTime()();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  DateTimeColumn? get paidAt => dateTime().nullable()();
  TextColumn? get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text()();
  TextColumn? get paymentMethod => text().nullable()();
  TextColumn get categoryId => text()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn? get notes => text().nullable()();
  TextColumn? get recurrenceRuleId => text().nullable()();
  TextColumn? get debtId => text().nullable()();
  TextColumn? get goalId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn? get icon => text().nullable()();
  TextColumn? get color => text().nullable()();
  TextColumn get type => text()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn? get color => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class TransactionTags extends Table {
  TextColumn get transactionId => text().references(Transactions, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {transactionId, tagId};
}

class Debts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  RealColumn get totalAmount => real()();
  RealColumn get remainingAmount => real()();
  RealColumn get interestRate => real().withDefault(const Constant(0))();
  IntColumn get totalInstallments => integer()();
  IntColumn get remainingInstallments => integer()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get priority => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn? get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0))();
  DateTimeColumn? get deadline => dateTime().nullable()();
  TextColumn? get categoryId => text().nullable()();
  RealColumn? get monthlyContribution => real().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Receipts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn? get transactionId => text().nullable()();
  TextColumn? get purchaseId => text().nullable()();
  TextColumn get fileUrl => text()();
  TextColumn get fileType => text()();
  TextColumn? get extractedText => text().nullable()();
  TextColumn? get extractedData => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ReconciliationReports extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceCycleId => text().unique()();
  TextColumn get userId => text()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get summary => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ReconciliationItems extends Table {
  TextColumn get id => text()();
  TextColumn get reportId => text().references(ReconciliationReports, #id)();
  TextColumn get invoiceDescription => text()();
  RealColumn get invoiceAmount => real()();
  TextColumn get matchStatus => text()();
  TextColumn? get matchedPurchaseId => text().nullable()();
  RealColumn? get registeredAmount => real().nullable()();
  RealColumn? get difference => real().nullable()();
  TextColumn? get userAction => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class FinancialAlerts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get message => text()();
  TextColumn get severity => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn? get data => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class RecurrenceRules extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get frequency => text()();
  IntColumn get interval => integer().withDefault(const Constant(1))();
  IntColumn? get dayOfMonth => integer().nullable()();
  IntColumn? get dayOfWeek => integer().nullable()();
  TextColumn get endType => text().withDefault(const Constant('never'))();
  IntColumn? get endCount => integer().nullable()();
  DateTimeColumn? get endDate => dateTime().nullable()();
  DateTimeColumn? get nextOccurrence => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get targetTable => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn? get error => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Cards,
  Purchases,
  Installments,
  InvoiceCycles,
  Transactions,
  Categories,
  Tags,
  TransactionTags,
  Debts,
  Goals,
  Receipts,
  ReconciliationReports,
  ReconciliationItems,
  FinancialAlerts,
  RecurrenceRules,
  SyncOutbox,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'cardvalue.sqlite'));
    return NativeDatabase(file);
  });
}
