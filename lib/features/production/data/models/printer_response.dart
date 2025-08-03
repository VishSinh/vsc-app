import 'package:json_annotation/json_annotation.dart';

part 'printer_response.g.dart';

/// Response model for printer data
@JsonSerializable()
class PrinterResponse {
  final String id;
  final String name;
  final String phone;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const PrinterResponse({required this.id, required this.name, required this.phone, required this.isActive});

  factory PrinterResponse.fromJson(Map<String, dynamic> json) => _$PrinterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PrinterResponseToJson(this);
}
