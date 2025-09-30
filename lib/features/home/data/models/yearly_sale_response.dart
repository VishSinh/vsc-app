import 'package:json_annotation/json_annotation.dart';

part 'yearly_sale_response.g.dart';

/// API response model for yearly sale data
@JsonSerializable()
class YearlySaleResponse {
  final List<MonthlySaleAPIModel> data;

  const YearlySaleResponse({required this.data});

  factory YearlySaleResponse.fromJson(Map<String, dynamic> json) => _$YearlySaleResponseFromJson(json);
  Map<String, dynamic> toJson() => _$YearlySaleResponseToJson(this);
}

/// API model for monthly sale data
@JsonSerializable()
class MonthlySaleAPIModel {
  final String month;
  final String sale;

  const MonthlySaleAPIModel({required this.month, required this.sale});

  factory MonthlySaleAPIModel.fromJson(Map<String, dynamic> json) => _$MonthlySaleAPIModelFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlySaleAPIModelToJson(this);

  // Helper method to convert string sale to double
  double get saleAsDouble => double.tryParse(sale) ?? 0.0;
}
