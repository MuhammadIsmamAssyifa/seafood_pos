enum UserRole {
  admin,
  cashier,
  waiter,
  kitchen,
  manager,
  unknown;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'cashier':
      case 'kasir':
        return UserRole.cashier;
      case 'waiter':
      case 'pelayan':
        return UserRole.waiter;
      case 'kitchen':
      case 'koki':
        return UserRole.kitchen;
      case 'manager':
        return UserRole.manager;
      default:
        return UserRole.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.cashier:
        return 'Kasir';
      case UserRole.waiter:
        return 'Waiter';
      case UserRole.kitchen:
        return 'Dapur';
      case UserRole.manager:
        return 'Manager';
      case UserRole.unknown:
        return 'Staff';
    }
  }
}

enum OrderStatus {
  pending,
  inKitchen,
  readyToServe,
  completed,
  cancelled,
}

enum TableStatus {
  available,
  occupied,
  reserved,
  cleaning,
}

