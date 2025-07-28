enum UserRole {
  admin('ADMIN'),
  manager('MANAGER'),
  sales('SALES');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.sales,
    );
  }
} 