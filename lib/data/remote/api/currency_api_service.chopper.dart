// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$CurrencyApiService extends CurrencyApiService {
  _$CurrencyApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = CurrencyApiService;

  @override
  Future<Response<Map<String, dynamic>>> getLatestRates({
    String from = 'USD',
    String? to,
  }) {
    final Uri $url = Uri.parse('/latest/latest');
    final Map<String, dynamic> $params = <String, dynamic>{
      'from': from,
      'to': to,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> convertAmount({
    double amount = 1,
    String from = 'USD',
    String to = 'EUR',
  }) {
    final Uri $url = Uri.parse('/latest/convert');
    final Map<String, dynamic> $params = <String, dynamic>{
      'amount': amount,
      'from': from,
      'to': to,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }
}
