import 'package:e_demand/utils/verifiedPhoneNumber.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registration uses Firebase national digits after normalization', () {
    final phone = VerifiedPhoneNumber.fromFirebase(
      phoneNumber: '+923001234567',
      countryCode: '92',
    );
    expect(phone.nationalNumber, '3001234567');
    expect(phone.countryCode, '92');
    expect(phone.internationalNumber, '+923001234567');
  });

  test('calling code may include a plus without duplicating it', () {
    final phone = VerifiedPhoneNumber.fromFirebase(
      phoneNumber: '+971501234567',
      countryCode: '+971',
    );
    expect(phone.nationalNumber, '501234567');
    expect(phone.countryCode, '+971');
    expect(phone.internationalNumber, '+971501234567');
  });

  test('significant national zeros in verified numbers are preserved', () {
    final phone = VerifiedPhoneNumber.fromFirebase(
      phoneNumber: '+390612345678',
      countryCode: '39',
    );
    expect(phone.nationalNumber, '0612345678');
  });

  test('a different verified calling code is rejected', () {
    expect(
      () => VerifiedPhoneNumber.fromFirebase(
        phoneNumber: '+447700900123',
        countryCode: '92',
      ),
      throwsFormatException,
    );
  });

  test('missing or malformed verified identities are rejected', () {
    for (final number in [null, '', '923001234567', '+92', '+92bad']) {
      expect(
        () => VerifiedPhoneNumber.fromFirebase(
          phoneNumber: number,
          countryCode: '92',
        ),
        throwsFormatException,
      );
    }
    for (final code in ['', '0', '0092', '+', '92bad']) {
      expect(
        () => VerifiedPhoneNumber.fromFirebase(
          phoneNumber: '+923001234567',
          countryCode: code,
        ),
        throwsFormatException,
      );
    }
  });
}
