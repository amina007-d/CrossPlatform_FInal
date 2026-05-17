class BudgetSettings {
  final double monthlyLimit;
  final String currency;
  final bool isDarkMode;
  final String householdId;
  final String userName;

  const BudgetSettings({
    this.monthlyLimit = 1000.0,
    this.currency = 'USD',
    this.isDarkMode = false,
    this.householdId = '',
    this.userName = '',
  });

  BudgetSettings copyWith({
    double? monthlyLimit,
    String? currency,
    bool? isDarkMode,
    String? householdId,
    String? userName,
  }) {
    return BudgetSettings(
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      currency: currency ?? this.currency,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      householdId: householdId ?? this.householdId,
      userName: userName ?? this.userName,
    );
  }
}
