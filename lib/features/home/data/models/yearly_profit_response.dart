import 'package:json_annotation/json_annotation.dart';

part 'yearly_profit_response.g.dart';

/// API response model for yearly profit data
@JsonSerializable()
class YearlyProfitResponse {
  final List<MonthlyProfitAPIModel> data;

  const YearlyProfitResponse({required this.data});

  factory YearlyProfitResponse.fromJson(Map<String, dynamic> json) => _$YearlyProfitResponseFromJson(json);
  Map<String, dynamic> toJson() => _$YearlyProfitResponseToJson(this);
}

/// API model for monthly profit data
@JsonSerializable()
class MonthlyProfitAPIModel {
  final String month;
  final String profit;

  const MonthlyProfitAPIModel({required this.month, required this.profit});

  factory MonthlyProfitAPIModel.fromJson(Map<String, dynamic> json) => _$MonthlyProfitAPIModelFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlyProfitAPIModelToJson(this);

  // Helper method to convert string profit to double
  double get profitAsDouble => double.tryParse(profit) ?? 0.0;
}
