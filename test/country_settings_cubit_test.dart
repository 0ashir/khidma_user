import 'dart:async';
import 'package:e_demand/cubits/countrySettingsCubit.dart';
import 'package:e_demand/data/model/countrySettingsModel.dart';
import 'package:e_demand/data/repository/settingRepository.dart';
import 'package:flutter_test/flutter_test.dart';

class ControlledSettings extends SettingRepository {
  final requests = <Completer<CountrySettings>>[];

  @override
  Future<CountrySettings> getCountrySettings({
    required String latitude,
    required String longitude,
  }) {
    final pending = Completer<CountrySettings>();
    requests.add(pending);
    return pending.future;
  }
}

void main() {
  test(
    'latest selected location wins when older requests finish later',
    () async {
      final repository = ControlledSettings();
      final cubit = CountrySettingsCubit(repository);
      final older = cubit.fetchCountrySettings(latitude: '1', longitude: '1');
      final newer = cubit.fetchCountrySettings(
        latitude: '25.2048',
        longitude: '55.2708',
      );
      repository.requests[1].complete(CountrySettings(currency: 'AED'));
      await newer;
      repository.requests[0].complete(CountrySettings(currency: 'USD'));
      await older;
      expect(cubit.countrySettings?.currency, 'AED');
      await cubit.close();
    },
  );

  test('late failures cannot replace newer country settings', () async {
    final repository = ControlledSettings();
    final cubit = CountrySettingsCubit(repository);
    final older = cubit.fetchCountrySettings(latitude: '1', longitude: '1');
    final newer = cubit.fetchCountrySettings(
      latitude: '25.2048',
      longitude: '55.2708',
    );
    repository.requests[1].complete(CountrySettings(currency: 'AED'));
    await newer;
    repository.requests[0].completeError(Exception('old request failed'));
    await older;
    expect(cubit.countrySettings?.currency, 'AED');
    await cubit.close();
  });
}
