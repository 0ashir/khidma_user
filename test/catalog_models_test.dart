import 'package:e_demand/data/model/countrySettingsModel.dart';
import 'package:e_demand/data/model/serviceModel.dart';
import 'package:e_demand/data/model/sectionModel.dart';
import 'package:e_demand/data/model/sliderImagesModel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('service preserves translated provider name independently of title', () {
    final service = Services.fromJson({
      'title': 'Home cleaning',
      'translated_title': 'تنظيف المنزل',
      'partner_name': 'Khidma',
      'translated_partner_name': 'خدمة',
    });
    expect(service.translatedPartnerName, 'خدمة');
    expect(service.translatedTitle, 'تنظيف المنزل');
  });

  test('service provider name falls back to the original name', () {
    final service = Services.fromJson({'partner_name': 'Khidma'});
    expect(service.translatedPartnerName, 'Khidma');
  });

  test('home service cards parse numeric provider IDs, prices and flags', () {
    final service = Services.fromJson({
      'id': 74,
      'provider_id': 118,
      'price': 160,
      'discounted_price': 140,
      'is_bookmarked': 1,
      'is_provider_verified': 0,
    });
    expect(service.id, '74');
    expect(service.userId, '118');
    expect(service.price, '160');
    expect(service.discountedPrice, '140');
    expect(service.isBookmarked, isTrue);
    expect(service.isProviderVerified, isFalse);
  });

  for (final type in [
    'recommended_service',
    'popular_service',
    'category_wise_service',
  ]) {
    test('$type keeps the service payload', () {
      final section = Sections.fromJson({
        'section_type': type,
        'title': 'Services',
        'services': [
          {'id': 74, 'title': 'Home cleaning', 'provider_id': 118},
        ],
      });
      expect(section.services.single.id, '74');
      expect(section.translatedTitle, 'Services');
    });
  }

  for (final type in ['near_by_provider', 'top_rated_partner', 'partners']) {
    test('$type keeps provider IDs and company names', () {
      final section = Sections.fromJson({
        'section_type': type,
        'providers': [
          {
            'id': 118,
            'company_name': 'Khidma Dubai (Test)',
            'average_rating': 0,
          },
        ],
      });
      expect(section.providers.single.id, '118');
      expect(section.providers.single.companyName, 'Khidma Dubai (Test)');
    });
  }

  test('missing or empty section content is safe to parse', () {
    for (final type in [
      'all_categories',
      'recommended_service',
      'near_by_provider',
      'offers',
      'ongoing_order',
      'banner',
      'unknown',
    ]) {
      final section = Sections.fromJson({'section_type': type});
      expect(section.services, isEmpty);
      expect(section.providers, isEmpty);
    }
  });

  test('UAE settings preserve AED, precision and enabled payment switches', () {
    final country = CountrySettings.fromJson({
      'currency': 'AED',
      'currency_symbol': 'AED',
      'currency_decimal_places': '2',
      'cod_setting': 1,
      'payment_gateway_setting': '1',
      'date_format': 'DD Mon YYYY',
      'time_format': 'H:i',
    });
    expect(country.currency, 'AED');
    expect(country.currencyDecimalPlaces, 2);
    expect(country.codEnabled, isTrue);
    expect(country.intlDateFormat, 'dd MMM yyyy');
    expect(country.use24HourFormat, isTrue);
    expect(country.hasPaymentGatewayList, isFalse);
  });

  test('disabled online payments make an empty gateway list authoritative', () {
    final country = CountrySettings.fromJson({'payment_gateway_setting': 0});
    expect(country.onlinePaymentEnabled, isFalse);
    expect(country.hasPaymentGatewayList, isTrue);
  });

  test('Stripe sandbox gateway keeps its client key and currency', () {
    final country = CountrySettings.fromJson({
      'payment_gateways': [
        {
          'gateway': 'Stripe',
          'mode': 'test',
          'currency': 'AED',
          'publishable_key': 'pk_test_fixture',
        },
      ],
    });
    expect(country.paymentGateways.single.gateway, 'stripe');
    expect(country.paymentGateways.single.clientKey, 'pk_test_fixture');
    expect(country.paymentGateways.single.currency, 'AED');
  });

  for (final type in ['URL', 'url', 'Url']) {
    test('slider routes $type links correctly', () {
      final slider = SliderImage.fromJson({
        'type': type,
        'url': 'https://app.khidmaplus.com/services',
      });
      expect(slider.type, SliderImagesType.url);
      expect(slider.url, 'https://app.khidmaplus.com/services');
    });
  }
}
