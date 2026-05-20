import 'package:chopper/chopper.dart';

part 'currency_api_service.chopper.dart';

@ChopperApi(baseUrl: '/latest')
abstract class CurrencyApiService extends ChopperService {
  static CurrencyApiService create() {
    final client = ChopperClient(
      baseUrl: Uri.parse('https://api.frankfurter.app'),
      services: [_$CurrencyApiService()],
      converter: const JsonConverter(),
      interceptors: [
        HttpLoggingInterceptor(),
      ],
    );
    return _$CurrencyApiService(client);
  }

  @Get(path: '/latest')
  Future<Response<Map<String, dynamic>>> getLatestRates({
    @Query('from') String from = 'USD',
    @Query('to') String? to,
  });

  @Get(path: '/convert')
  Future<Response<Map<String, dynamic>>> convertAmount({
    @Query('amount') double amount = 1,
    @Query('from') String from = 'USD',
    @Query('to') String to = 'EUR',
  });
}
