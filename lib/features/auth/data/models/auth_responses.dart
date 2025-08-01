import 'package:json_annotation/json_annotation.dart';
import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/models/api_response.dart';

part 'auth_responses.g.dart';

@JsonSerializable()
class LoginData {
  final String message;
  final String token;
  final String role;

  const LoginData({required this.message, required this.token, required this.role});

  factory LoginData.fromJson(Map<String, dynamic> json) => _$LoginDataFromJson(json);
  Map<String, dynamic> toJson() => _$LoginDataToJson(this);

  UserRole get userRole => UserRole.fromString(role);
}

// Type aliases for better readability
typedef LoginResponse = ApiResponse<LoginData>;
typedef RegisterResponse = ApiResponse<MessageData>;
