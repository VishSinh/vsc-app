import 'package:json_annotation/json_annotation.dart';

part 'model_log_response.g.dart';

@JsonSerializable()
class ModelLogResponse {
  final String id;
  @JsonKey(name: 'staff_id')
  final String staffId;
  @JsonKey(name: 'staff_name')
  final String staffName;
  @JsonKey(name: 'model_name')
  final String modelName;
  @JsonKey(name: 'model_id')
  final String modelId;
  final String action;
  @JsonKey(name: 'old_values', defaultValue: <String, dynamic>{})
  final Map<String, dynamic> oldValues;
  @JsonKey(name: 'new_values', defaultValue: <String, dynamic>{})
  final Map<String, dynamic> newValues;
  @JsonKey(name: 'request_id')
  final String? requestId;
  @JsonKey(name: 'actor_ip')
  final String? actorIp;
  @JsonKey(name: 'actor_user_agent', defaultValue: '')
  final String actorUserAgent;
  @JsonKey(defaultValue: '')
  final String notes;
  @JsonKey(defaultValue: '')
  final String source;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const ModelLogResponse({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.modelName,
    required this.modelId,
    required this.action,
    required this.oldValues,
    required this.newValues,
    this.requestId,
    this.actorIp,
    required this.actorUserAgent,
    required this.notes,
    required this.source,
    required this.createdAt,
  });

  factory ModelLogResponse.fromJson(Map<String, dynamic> json) => _$ModelLogResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ModelLogResponseToJson(this);
}
