import 'package:vsc_app/core/enums/user_role.dart';

/// Pure domain model for authenticated user
class AuthUser {
  final String id;
  final String name;
  final String phone;
  final String token;
  final UserRole role;
  final DateTime createdAt;

  const AuthUser({required this.id, required this.name, required this.phone, required this.token, required this.role, required this.createdAt});

  /// Create a copy with updated values
  AuthUser copyWith({String? id, String? name, String? phone, String? token, UserRole? role, DateTime? createdAt}) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      token: token ?? this.token,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if user has admin privileges
  bool get isAdmin => role == UserRole.admin;

  /// Check if user has manager privileges
  bool get isManager => role == UserRole.manager || role == UserRole.admin;

  /// Check if user has sales privileges
  bool get isSales => role == UserRole.sales || role == UserRole.manager || role == UserRole.admin;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phone == other.phone &&
          token == other.token &&
          role == other.role;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ phone.hashCode ^ token.hashCode ^ role.hashCode;

  @override
  String toString() => 'AuthUser(id: $id, name: $name, phone: $phone, role: $role)';
}
