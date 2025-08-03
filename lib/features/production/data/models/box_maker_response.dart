import 'package:json_annotation/json_annotation.dart';

part 'box_maker_response.g.dart';

/// Response model for box maker data
@JsonSerializable()
class BoxMakerResponse {
  final String id;
  final String name;
  final String phone;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const BoxMakerResponse({required this.id, required this.name, required this.phone, required this.isActive});

  factory BoxMakerResponse.fromJson(Map<String, dynamic> json) => _$BoxMakerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BoxMakerResponseToJson(this);
}
