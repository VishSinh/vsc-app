import 'package:json_annotation/json_annotation.dart';

part 'message_data.g.dart';

/// Standard message data structure for simple responses
@JsonSerializable()
class MessageData {
  final String message;

  const MessageData({required this.message});

  factory MessageData.fromJson(Map<String, dynamic> json) => _$MessageDataFromJson(json);
  Map<String, dynamic> toJson() => _$MessageDataToJson(this);
}
