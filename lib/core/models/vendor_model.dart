import 'package:json_annotation/json_annotation.dart';
import 'package:vsc_app/core/models/api_response.dart';

part 'vendor_model.g.dart';

@JsonSerializable()
class Vendor {
  final String id;
  final String name;
  final String phone;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const Vendor({
    required this.id,
    required this.name,
    required this.phone,
    required this.isActive,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
  Map<String, dynamic> toJson() => _$VendorToJson(this);
}

@JsonSerializable()
class CreateVendorRequest {
  final String name;
  final String phone;

  const CreateVendorRequest({
    required this.name,
    required this.phone,
  });

  factory CreateVendorRequest.fromJson(Map<String, dynamic> json) => _$CreateVendorRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateVendorRequestToJson(this);
}

// Type aliases for better readability
typedef VendorListResponse = ApiResponse<List<Vendor>>;
typedef CreateVendorResponse = ApiResponse<MessageData>; 