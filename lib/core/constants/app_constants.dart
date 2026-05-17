class AppConstants {
  // SharedPreferences keys
  static const String keyBudgetLimit = 'budget_limit';
  static const String keyDefaultCurrency = 'default_currency';
  static const String keyThemeMode = 'theme_mode';
  static const String keyHouseholdId = 'household_id';
  static const String keyUserName = 'user_name';

  // Expense categories
  static const List<String> categories = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Entertainment',
    'Health',
    'Housing',
    'Education',
    'Travel',
    'Other',
  ];

  // Category icons
  static const Map<String, String> categoryEmojis = {
    'Food & Dining': '🍔',
    'Transport': '🚗',
    'Shopping': '🛍️',
    'Entertainment': '🎬',
    'Health': '💊',
    'Housing': '🏠',
    'Education': '📚',
    'Travel': '✈️',
    'Other': '💰',
  };

  // Supported currencies
  static const List<String> currencies = [
    'USD', 'EUR', 'GBP', 'KZT', 'RUB', 'CNY', 'JPY', 'CAD', 'AUD',
  ];

  // Frankfurter API
  static const String currencyApiBase = 'api.frankfurter.app';

  // Firestore collections
  static const String householdsCollection = 'households';
  static const String sharedExpensesSubcollection = 'shared_expenses';
}
