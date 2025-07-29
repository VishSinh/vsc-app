import 'package:json_annotation/json_annotation.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class Customer {
  final String id;
  final String name;
  final String phone;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const Customer({required this.id, required this.name, required this.phone, required this.isActive});

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}

@JsonSerializable()
class CreateCustomerRequest {
  final String name;
  final String phone;

  const CreateCustomerRequest({required this.name, required this.phone});

  factory CreateCustomerRequest.fromJson(Map<String, dynamic> json) => _$CreateCustomerRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCustomerRequestToJson(this);
}
