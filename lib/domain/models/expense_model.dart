class ExpenseModel {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String currency;
  final String? note;
  final DateTime date;
  final DateTime? createdAt;

  const ExpenseModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.currency = 'USD',
    this.note,
    required this.date,
    this.createdAt,
  });

  ExpenseModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    String? currency,
    String? note,
    DateTime? date,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      currency: currency ?? this.currency,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt,
    );
  }
}
