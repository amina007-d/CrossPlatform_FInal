import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../domain/repositories/repositories.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  static const _baseUrl = 'https://api.fastforex.io';
  static const _apiKey = 'c6865f1029-01fd0e797a-tfc8ed';

  static const _headers = {
    'X-API-Key': _apiKey,
    'Accept': 'application/json',
  };

  @override
  Future<Map<String, double>> getLatestRates(String base) async {
    // fetch-multi: get all major currencies at once
    const targets = 'EUR,GBP,KZT,RUB,CNY,JPY,CAD,AUD,CHF,USD';
    final uri = Uri.parse('$_baseUrl/fetch-multi?from=$base&to=$targets');
    developer.log('Fetching: $uri', name: 'Currency');

    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      developer.log('Status: ${response.statusCode}', name: 'Currency');
      developer.log('Body: ${response.body}', name: 'Currency');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as Map<String, dynamic>;
        return results.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      developer.log('Error: $e', name: 'Currency');
      throw Exception(e.toString());
    }
  }

  @override
  Future<double> convert(double amount, String from, String to) async {
    if (from == to) return amount;
    final uri = Uri.parse('$_baseUrl/fetch-one?from=$from&to=$to');
    developer.log('Converting: $uri', name: 'Currency');

    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      developer.log('Status: ${response.statusCode}', name: 'Currency');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['result'] as Map<String, dynamic>;
        final rate = (results[to] as num).toDouble();
        return amount * rate;
      }
      throw Exception('HTTP ${response.statusCode}');
    } catch (e) {
      developer.log('Error: $e', name: 'Currency');
      throw Exception(e.toString());
    }
  }
}