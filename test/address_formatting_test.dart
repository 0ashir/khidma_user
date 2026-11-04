import 'package:e_demand/utils/validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('missing UAE postal codes do not render as null on the home screen', () {
    expect(filterAddressString('null,Dubai,Dubai'), 'Dubai, Dubai');
  });
  test('empty address components and stray commas are removed', () {
    expect(
      filterAddressString(' , Building 1, , Dubai, , '),
      'Building 1, Dubai',
    );
    expect(filterAddressString('null, , NULL'), isEmpty);
  });
  test('single-letter buildings and Arabic addresses are preserved', () {
    expect(filterAddressString('Tower,A,Dubai'), 'Tower, A, Dubai');
    expect(filterAddressString('دبي,null,الإمارات'), 'دبي, الإمارات');
  });
}
