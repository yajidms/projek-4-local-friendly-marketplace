enum Role {
  buyer,
  seller,
  admin,
}

extension RoleExtension on Role {
  String get value {
    switch (this) {
      case Role.buyer:
        return 'buyer';
      case Role.seller:
        return 'seller';
      case Role.admin:
        return 'admin';
    }
  }

  static Role fromString(String value) {
    switch (value.toLowerCase()) {
      case 'buyer':
        return Role.buyer;
      case 'seller':
        return Role.seller;
      case 'admin':
        return Role.admin;
      default:
        return Role.buyer;
    }
  }
}
