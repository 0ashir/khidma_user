import 'package:e_demand/ui/screens/homeScreen/widgets/homeHeader.dart';
import 'package:flutter_test/flutter_test.dart';

/// The home header shows the area (and city) from the stored, comma-joined
/// geocoder address "place name, area, city, country".
void main() {
  test('skips the nearby place name and country', () {
    expect(
      cleanLocationLabel(
        'Interlock, Mohammed Bin Zayed City, Abu Dhabi, United Arab Emirates',
      ),
      'Mohammed Bin Zayed City, Abu Dhabi',
    );
  });

  test('drops null pieces, plus codes and street numbers', () {
    expect(
      cleanLocationLabel(
        '5G6X+4R,Mohammed Bin Zayed City,Abu Dhabi,United Arab Emirates',
      ),
      'Mohammed Bin Zayed City, Abu Dhabi',
    );
    expect(
      cleanLocationLabel('12 Street 7,Mohammed Bin Zayed City,Abu Dhabi,UAE'),
      'Mohammed Bin Zayed City, Abu Dhabi',
    );
    expect(
      cleanLocationLabel('null, Interlock ,Mohammed Bin Zayed City,null,UAE'),
      'Mohammed Bin Zayed City',
    );
  });

  test('no repeated city, short inputs, empty input', () {
    expect(cleanLocationLabel('Interlock, Dubai, Dubai, UAE'), 'Dubai');
    expect(cleanLocationLabel('Dubai Marina, UAE'), 'Dubai Marina');
    expect(cleanLocationLabel('Dubai Marina'), 'Dubai Marina');
    expect(cleanLocationLabel(null), '');
    expect(cleanLocationLabel('null,,null'), '');
  });
}
