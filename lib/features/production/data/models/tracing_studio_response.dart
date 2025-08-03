import 'package:json_annotation/json_annotation.dart';

part 'tracing_studio_response.g.dart';

/// Response model for tracing studio data
@JsonSerializable()
class TracingStudioResponse {
  final String id;
  final String name;
  final String phone;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const TracingStudioResponse({required this.id, required this.name, required this.phone, required this.isActive});

  factory TracingStudioResponse.fromJson(Map<String, dynamic> json) => _$TracingStudioResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TracingStudioResponseToJson(this);
}
