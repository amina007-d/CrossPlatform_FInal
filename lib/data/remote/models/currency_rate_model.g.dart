// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_rate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyRateModel _$CurrencyRateModelFromJson(Map<String, dynamic> json) =>
    CurrencyRateModel(
      amount: (json['amount'] as num).toDouble(),
      base: json['base'] as String,
      date: json['date'] as String,
      rates: (json['rates'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$CurrencyRateModelToJson(CurrencyRateModel instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'base': instance.base,
      'date': instance.date,
      'rates': instance.rates,
    };
