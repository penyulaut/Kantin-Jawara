enum UserRole {
  admin('admin'),
  penjual('penjual'),
  pembeli('pembeli');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'penjual':
        return UserRole.penjual;
      case 'pembeli':
        return UserRole.pembeli;
      default:
        return UserRole.pembeli;
    }
  }
}

enum AuthStatus { loading, authenticated, unauthenticated, error }
