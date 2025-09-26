import 'package:json_annotation/json_annotation.dart';

part 'customer_responses.g.dart';

@JsonSerializable()
class CustomerResponse {
  final String id;
  final String name;
  final String phone;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const CustomerResponse({required this.id, required this.name, required this.phone, required this.isActive});

  factory CustomerResponse.fromJson(Map<String, dynamic> json) => _$CustomerResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerResponseToJson(this);
}
