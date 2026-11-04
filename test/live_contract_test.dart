import 'dart:convert';
import 'dart:io';
import 'package:e_demand/data/model/cartModel.dart';
import 'package:e_demand/data/model/providerDetailsModel.dart';
import 'package:e_demand/data/model/sectionModel.dart';
import 'package:e_demand/data/model/serviceDetailsModel.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(
          File('test/fixtures/live_customer/$name.json').readAsStringSync(),
        )
        as Map<String, dynamic>;

void main() {
  for (final city in [
    'dubai',
    'sharjah',
    'abu_dhabi',
    'al_ain',
    'rak',
    'fujairah',
    'ar',
  ]) {
    test(
      'actual $city home payload parses without dropping catalog sections',
      () {
        final data = fixture('home_$city')['data'] as Map;
        final sections = (data['featured_sections'] as List)
            .map(
              (row) => Sections.fromJson(Map<String, dynamic>.from(row as Map)),
            )
            .toList();
        expect(
          sections
              .singleWhere((s) => s.sectionType == 'all_categories')
              .categories,
          isNotEmpty,
        );
        expect(
          sections
              .singleWhere((s) => s.sectionType == 'recommended_service')
              .services,
          isNotEmpty,
        );
        expect(
          sections
              .singleWhere((s) => s.sectionType == 'near_by_provider')
              .providers,
          isNotEmpty,
        );
        for (final service in sections.expand((s) => s.services)) {
          final discounted = double.parse(service.discountedPrice!);
          final effectivePrice = discounted > 0
              ? discounted
              : double.parse(service.price!);
          expect(effectivePrice, greaterThan(0));
          expect(
            service.imageOfTheService,
            startsWith('https://admin.khidmaplus.com/'),
          );
        }
      },
    );
  }

  test(
    'actual provider details keep working hours and booking eligibility',
    () {
      final provider = ProviderDetailsModel.fromJson(
        fixture('provider_detail')['data'],
      );
      expect(provider.partnerId, '118');
      expect(provider.isAtDoorstepAvailable, '1');
      expect(provider.shiftsByDay, hasLength(7));
      expect(provider.totalServices, '3');
    },
  );

  test('actual service details keep price, category and provider links', () {
    final service = ServiceDetailsModel.fromJson(
      fixture('service_detail')['data'],
    );
    expect(service.id, '74');
    expect(service.price, '160');
    expect(service.discountedPrice, '140');
    expect(service.provider?.id, '118');
    expect(service.maxQuantityAllowed, '3');
  });

  test('cart uses the backend promo total without applying it twice', () {
    final cart = Cart.fromJson({
      'overall_amount': '200.00',
      'final_total': '180.00',
      'promo': {'discount': '20.00'},
      'visiting_charges': '10.00',
    });
    expect(cart.payableAmount(atStore: false), 180);
    expect(cart.payableAmount(atStore: false, withPromo: false), 200);
    expect(cart.payableAmount(atStore: true), 170);
  });

  test('cart with no promo uses overall amount, including numeric amounts', () {
    final cart = Cart.fromJson({'overall_amount': 149.5, 'final_total': 0});
    expect(cart.payableAmount(atStore: false), 149.5);
    expect(cart.hasBackendPromo, isFalse);
  });

  test('empty cart is safe before the first item is added', () {
    expect(Cart.fromJson({}).payableAmount(atStore: false), 0);
  });
}
