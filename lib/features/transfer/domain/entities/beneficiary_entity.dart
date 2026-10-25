/// Pure Dart Beneficiary Entity representing a saved recipient.
class BeneficiaryEntity {
  final String id;
  final String name;
  final String accountNumber;
  final String bankName;
  final String avatarInitial;
  final int colorHex;

  const BeneficiaryEntity({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.bankName,
    required this.avatarInitial,
    required this.colorHex,
  });
}
