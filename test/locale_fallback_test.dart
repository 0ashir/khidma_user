import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  String pick(String l) =>
      Intl.verifiedLocale(l, NumberFormat.localeExists, onFailure: (_) => 'en')!;
  test('unknown device locales fall back instead of throwing', () {
    expect(() => NumberFormat.currency(locale: 'ars_US'), throwsArgumentError);
    expect(NumberFormat.currency(locale: pick('ars_US'), symbol: 'AED')
        .format(1000), contains('1'));
    expect(pick('ar_AE'), startsWith('ar'));
    expect(pick('en_US'), 'en_US');
  });
}
