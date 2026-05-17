import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, String currency) {
    final formatter = NumberFormat.currency(
      symbol: _getSymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount, String currency) {
    if (amount >= 1000000) {
      return '${_getSymbol(currency)}${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${_getSymbol(currency)}${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, currency);
  }

  static String _getSymbol(String currency) {
    const symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'KZT': '₸',
      'RUB': '₽',
      'CNY': '¥',
      'JPY': '¥',
      'CAD': 'CA\$',
      'AUD': 'A\$',
    };
    return symbols[currency] ?? currency;
  }
}

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  static String formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
}
