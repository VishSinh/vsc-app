import 'package:json_annotation/json_annotation.dart';

part 'customer_requests.g.dart';

@JsonSerializable()
class CreateCustomerRequest {
  final String name;
  final String phone;

  const CreateCustomerRequest({required this.name, required this.phone});

  factory CreateCustomerRequest.fromJson(Map<String, dynamic> json) => _$CreateCustomerRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCustomerRequestToJson(this);
}
