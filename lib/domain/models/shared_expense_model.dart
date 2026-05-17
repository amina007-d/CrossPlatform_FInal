class SharedExpenseModel {
  final String? id;
  final String title;
  final double amount;
  final String currency;
  final String category;
  final String paidBy;
  final String? note;
  final DateTime date;
  final List<String> splitBetween;

  const SharedExpenseModel({
    this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.paidBy,
    this.note,
    required this.date,
    required this.splitBetween,
  });

  factory SharedExpenseModel.fromFirestore(
    Map<String, dynamic> data,
    String docId,
  ) {
    return SharedExpenseModel(
      id: docId,
      title: data['title'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] ?? 'USD',
      category: data['category'] ?? 'Other',
      paidBy: data['paidBy'] ?? '',
      note: data['note'],
      date: DateTime.fromMillisecondsSinceEpoch(data['date'] as int),
      splitBetween: List<String>.from(data['splitBetween'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'currency': currency,
      'category': category,
      'paidBy': paidBy,
      'note': note,
      'date': date.millisecondsSinceEpoch,
      'splitBetween': splitBetween,
    };
  }

  double get perPersonAmount =>
      splitBetween.isEmpty ? amount : amount / splitBetween.length;
}
