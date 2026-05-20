# Shared Widget Contracts

## Dashboard Widgets

### ExpenseCard
```dart
ExpenseCard({
  required String title,           // "Gastos do Mês"
  required double amount,          // 4530.00
  required String formattedAmount, // "R\$ 4.530,00" (already formatted)
  required IconData icon,          // Icons.trending_down
  required Color color,            // Theme primary color
  String? subtitle,                // "+12% vs mês passado"
  Widget? trailing,                // Optional trailing widget (badge, chart sparkline)
  VoidCallback? onTap,
})
```

### InvoiceCard
```dart
InvoiceCard({
  required String cardName,        // "Nubank"
  required double totalAmount,
  required double usedLimit,       // 4100.00
  required double totalLimit,      // 5000.00
  required int closingDay,
  required int dueDay,
  required Color cardColor,
  required bool isPaid,
  VoidCallback? onTap,
})
```

### FinancialChart
```dart
FinancialChart({
  required ChartType type,          // ChartType.pie | .bar | .line | .radar
  required List<ChartDataPoint> data,
  double? height,                   // default 200
  bool showLegend = true,
  bool animated = true,
})
```

### SpendingRadar
```dart
SpendingRadar({
  required List<RadarCategory> categories,  // [{name, amount, color, maxAmount}]
  double? size,                              // default 250
})
```

### MonthlyComparison
```dart
MonthlyComparison({
  required List<MonthData> currentYear,  // monthly totals for current year
  List<MonthData>? previousYear,         // monthly totals for previous year
  required String currentLabel,          // "2026"
  String? previousLabel,                 // "2025"
})
```

### UpcomingBills
```dart
UpcomingBills({
  required List<UpcomingBill> bills,    // [{description, amount, dueDate, category}]
  int maxItems = 5,
  VoidCallback? onViewAll,
})
```

## Card Widgets

### CreditCardWidget
```dart
CreditCardWidget({
  required String bankName,        // "Nubank"
  required String cardName,        // "Ultravioleta"
  required String lastDigits,      // "1234"
  required double usedAmount,
  required double totalLimit,
  required String closingDayText,  // "Fecha dia 15"
  required String dueDayText,      // "Vence dia 22"
  required Color color,
  bool isFlipped = false,
  VoidCallback? onTap,
})
```

### InvoiceTimeline
```dart
InvoiceTimeline({
  required List<InvoiceMonth> months,  // [{month, year, total, isPaid, isCurrent}]
  required int selectedIndex,
  required ValueChanged<int> onMonthSelected,
})
```

### InstallmentProgress
```dart
InstallmentProgress({
  required int paidCount,
  required int totalCount,
  required double paidAmount,
  required double totalAmount,
  double size = 80,
})
```

## Transaction Widgets

### TransactionTile
```dart
TransactionTile({
  required String description,
  required String formattedAmount,     // "-R\$ 150,00"
  required String category,
  required IconData categoryIcon,
  required Color categoryColor,
  required DateTime date,
  String? paymentMethod,               // "PIX", "Débito"
  bool isIncome = false,
  VoidCallback? onTap,
})
```

### CategoryPieChart
```dart
CategoryPieChart({
  required List<CategorySpending> categories,  // [{name, amount, color, percentage}]
  double? height,
  bool showLabels = true,
})
```

### ExpenseHeatmap
```dart
ExpenseHeatmap({
  required Map<DateTime, double> dailyExpenses,  // date → amount
  required int year,
  required int month,
  Color? lowColor,
  Color? highColor,
})
```

## Common Widgets

### AmountField (form input)
```dart
AmountField({
  required TextEditingController controller,
  required String label,
  String? hintText,
  bool autofocus = false,
  ValueChanged<String>? onChanged,
})
```

### CategorySelector
```dart
CategorySelector({
  required List<Category> categories,
  required Category? selected,
  required ValueChanged<Category> onSelected,
  String type = 'expense',       // filter by type
})
```

### CardSelector
```dart
CardSelector({
  required List<Card> cards,
  required Card? selected,
  required ValueChanged<Card> onSelected,
})
```

### DatePickerField
```dart
DatePickerField({
  required DateTime selectedDate,
  required ValueChanged<DateTime> onDateChanged,
  DateTime? firstDate,
  DateTime? lastDate,
})
```

### InstallmentSelector
```dart
InstallmentSelector({
  required int installmentCount,
  required ValueChanged<int> onChanged,
  int min = 1,
  int max = 48,
})
```

### PaymentMethodSelector
```dart
PaymentMethodSelector({
  required PaymentMethod? selected,
  required ValueChanged<PaymentMethod> onSelected,
  required List<PaymentMethod> availableMethods,
})
```
