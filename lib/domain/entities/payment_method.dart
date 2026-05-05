enum PaymentMethod {
  creditCard,
  debitCard,
  bankTransfer,
  eWallet,
  cod, // Cash on Delivery
}

extension PaymentMethodExtension on PaymentMethod {
  String get value {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'credit_card';
      case PaymentMethod.debitCard:
        return 'debit_card';
      case PaymentMethod.bankTransfer:
        return 'bank_transfer';
      case PaymentMethod.eWallet:
        return 'e_wallet';
      case PaymentMethod.cod:
        return 'cod';
    }
  }

  static PaymentMethod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'credit_card':
        return PaymentMethod.creditCard;
      case 'debit_card':
        return PaymentMethod.debitCard;
      case 'bank_transfer':
        return PaymentMethod.bankTransfer;
      case 'e_wallet':
        return PaymentMethod.eWallet;
      case 'cod':
        return PaymentMethod.cod;
      default:
        return PaymentMethod.creditCard;
    }
  }
}
