import 'package:e_demand/data/model/countrySettingsModel.dart';
import 'package:e_demand/data/model/systemSettingsModel.dart';
import 'package:flutter_test/flutter_test.dart';

/// `PaymentGatewaysSettings.withCountry` overlays `get_country_settings` onto
/// the global `get_settings` gateway config. A country that enables a gateway
/// without its own credentials must keep the global key — otherwise Stripe
/// gets an empty publishable key and every payment fails before the sheet.
void main() {
  final PaymentGatewaysSettings global = PaymentGatewaysSettings.fromJson({
    'stripe_status': 'enable',
    'stripe_mode': 'live',
    'stripe_currency': 'aed',
    'stripe_publishable_key': 'pk_live_global',
    'razorpay_api_status': 'enable',
    'razorpay_key': 'rzp_global',
  });

  CountrySettings country(final List<Map<String, dynamic>> gateways) =>
      CountrySettings.fromJson({
        'currency': 'AED',
        'payment_gateway_setting': '1',
        'cod_setting': '1',
        'payment_gateways': gateways,
      });

  test('country gateway without credentials keeps the global Stripe key', () {
    final merged = global.withCountry(
      country([
        {'gateway': 'stripe'},
      ]),
    );

    expect(merged.stripeStatus, 'enable');
    expect(merged.stripePublishableKey, 'pk_live_global');
    expect(merged.stripeMode, 'live');
    expect(merged.stripeCurrency, 'aed');
  });

  test('country-specific Stripe credentials still override the global', () {
    final merged = global.withCountry(
      country([
        {
          'gateway': 'stripe',
          'mode': 'test',
          'currency': 'pkr',
          'publishable_key': 'pk_test_country',
        },
      ]),
    );

    expect(merged.stripePublishableKey, 'pk_test_country');
    expect(merged.stripeMode, 'test');
    expect(merged.stripeCurrency, 'pkr');
  });

  test('gateway missing from the country list is disabled', () {
    final merged = global.withCountry(
      country([
        {'gateway': 'stripe'},
      ]),
    );

    expect(merged.razorpayApiStatus, 'disable');
  });
}
