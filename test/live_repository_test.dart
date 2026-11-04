import 'dart:io';
import 'package:e_demand/data/model/serviceModel.dart';
import 'package:e_demand/data/repository/hiveRepository.dart';
import 'package:e_demand/data/repository/homeScreenRepository.dart';
import 'package:e_demand/data/repository/providerRepository.dart';
import 'package:e_demand/data/repository/serviceRepository.dart';
import 'package:e_demand/data/repository/settingRepository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Explicit opt-in: the normal suite remains deterministic and works offline.
const runLive = bool.fromEnvironment('RUN_LIVE_API_TESTS');

void main() {
  group('Live guest repository integration', () {
    late Directory storage;
    setUpAll(() async {
      storage = await Directory.systemTemp.createTemp('khidma-live-tests-');
      Hive.init(storage.path);
      await Hive.openBox(HiveRepository.userDetailBoxKey);
      await Hive.openBox(HiveRepository.languageBoxKey);
      await Hive.box(HiveRepository.userDetailBoxKey).putAll({
        HiveRepository.latitudeKey: '25.2048',
        HiveRepository.longitudeKey: '55.2708',
      });
    });
    tearDownAll(() async {
      await Hive.close();
      await storage.delete(recursive: true);
    });

    test('guest home loads categories, services and providers', () async {
      final home = await HomeScreenRepository().fetchHomeScreenData(
        latitude: '25.2048',
        longitude: '55.2708',
      );
      expect(home.sliders, isNotEmpty);
      expect(
        home.sections!
            .singleWhere((s) => s.sectionType == 'recommended_service')
            .services,
        isNotEmpty,
      );
      expect(
        home.sections!
            .singleWhere((s) => s.sectionType == 'near_by_provider')
            .providers,
        isNotEmpty,
      );
    });

    test('country repository returns AED for Dubai', () async {
      final country = await SettingRepository().getCountrySettings(
        latitude: '25.2048',
        longitude: '55.2708',
      );
      expect(country.currency, 'AED');
    });

    test('provider discovery and details agree', () async {
      final repository = ProviderRepository();
      final result = await repository.fetchProviderList(
        isAuthTokenRequired: false,
      );
      expect(result['providerList'], isNotEmpty);
      final detail = await repository.getProviderDetails(partnerId: '118');
      expect(detail.partnerId, '118');
      expect(detail.shiftsByDay, hasLength(7));
    });

    test('service discovery and details agree', () async {
      final repository = ServiceRepository();
      final result = await repository.getServicesForCategory(
        offset: '0',
        limit: '10',
        categoryId: '3',
      );
      expect(result['services'] as List<Services>, isNotEmpty);
      final detail = await repository.getServiceDetails(id: '74');
      expect(detail.provider?.id, '118');
      expect(detail.discountedPrice, '140');
    });
  }, skip: !runLive);
}
