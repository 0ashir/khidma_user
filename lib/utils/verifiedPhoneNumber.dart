/// The phone identity returned by a successful Firebase OTP verification.
/// Keep its national digits exactly as verified, including significant zeros.
class VerifiedPhoneNumber {
  const VerifiedPhoneNumber._({
    required this.countryCode,
    required this.nationalNumber,
    required this.internationalNumber,
  });

  factory VerifiedPhoneNumber.fromFirebase({
    required String? phoneNumber,
    required String countryCode,
  }) {
    final callingCode = countryCode.trim();
    final internationalNumber = phoneNumber ?? '';
    if (!RegExp(r'^\+?[1-9][0-9]{0,2}$').hasMatch(callingCode) ||
        !RegExp(r'^\+[1-9][0-9]{1,14}$').hasMatch(internationalNumber)) {
      throw const FormatException(
        'Verified phone identity is missing or invalid',
      );
    }

    final prefix = '+${callingCode.replaceFirst('+', '')}';
    if (!internationalNumber.startsWith(prefix) ||
        internationalNumber.length == prefix.length) {
      throw const FormatException('Verified phone country code does not match');
    }

    return VerifiedPhoneNumber._(
      countryCode: callingCode,
      nationalNumber: internationalNumber.substring(prefix.length),
      internationalNumber: internationalNumber,
    );
  }

  final String countryCode;
  final String nationalNumber;
  final String internationalNumber;
}
