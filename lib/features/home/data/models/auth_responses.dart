import 'package:json_annotation/json_annotation.dart';
import 'package:vsc_app/core/enums/user_role.dart';

part 'auth_responses.g.dart';

@JsonSerializable()
class LoginResponse {
  final String message;
  final String token;
  final String role;

  const LoginResponse({required this.message, required this.token, required this.role});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  UserRole get userRole => UserRole.fromString(role);
}
