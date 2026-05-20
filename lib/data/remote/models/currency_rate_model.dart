import 'package:json_annotation/json_annotation.dart';

part 'currency_rate_model.g.dart';

@JsonSerializable()
class CurrencyRateModel {
  final double amount;
  final String base;
  final String date;
  final Map<String, double> rates;

  const CurrencyRateModel({
    required this.amount,
    required this.base,
    required this.date,
    required this.rates,
  });

  factory CurrencyRateModel.fromJson(Map<String, dynamic> json) =>
      _$CurrencyRateModelFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyRateModelToJson(this);
}
