import 'package:json_annotation/json_annotation.dart';
import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/models/api_response.dart';

part 'auth_model.g.dart';

@JsonSerializable()
class LoginRequest {
  final String phone;
  final String password;

  const LoginRequest({required this.phone, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

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

@JsonSerializable()
class RegisterRequest {
  final String name;
  final String phone;
  final String password;
  final String role;

  const RegisterRequest({required this.name, required this.phone, required this.password, required this.role});

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

// Type aliases for better readability
typedef LoginResponse = ApiResponse<LoginData>;
typedef RegisterResponse = ApiResponse<MessageData>;
