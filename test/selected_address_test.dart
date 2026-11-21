import 'package:e_demand/app/generalImports.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('selected_address_test');
    Hive.init(dir.path);
    await Hive.openBox(HiveRepository.userDetailBoxKey);
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test(
    'saved address label applies only while its coordinates are current',
    () {
      HiveRepository.setLatitude = '24.30';
      HiveRepository.setLongitude = '54.55';
      HiveRepository.setSelectedAddress = {
        'id': '92',
        'label': 'Apartment · Marina Tower, Apt 304',
        'latitude': '24.30',
        'longitude': '54.55',
      };
      expect(HiveRepository.getSelectedAddress?['id'], '92');

      // Location changed some other way (map pin, search, GPS).
      HiveRepository.setLatitude = 25.2;
      expect(HiveRepository.getSelectedAddress, isNull);

      // Back on the same spot: active again.
      HiveRepository.setLatitude = '24.30';
      expect(
        HiveRepository.getSelectedAddress?['label'],
        'Apartment · Marina Tower, Apt 304',
      );
    },
  );

  test('nothing selected by default', () async {
    await Hive.box(
      HiveRepository.userDetailBoxKey,
    ).delete(HiveRepository.selectedAddressKey);
    expect(HiveRepository.getSelectedAddress, isNull);
  });
}
