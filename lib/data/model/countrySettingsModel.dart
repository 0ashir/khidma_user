/// Currency and date/time display formats of the country that covers the
/// customer's coordinates (`get_country_settings`). Locations outside every
/// active country resolve to the default country on the backend.
class CountrySettings {
  CountrySettings({
    this.currency = '',
    this.currencySymbol = '',
    this.currencyDecimalPlaces = 2,
    this.dateFormat = 'DD-MM-YYYY',
    this.timeFormat = 'h:i A',
    this.codEnabled,
    this.onlinePaymentEnabled,
    this.paymentGateways = const <CountryPaymentGateway>[],
  });

  CountrySettings.fromJson(final Map<String, dynamic> json)
    : currency = json['currency']?.toString() ?? '',
      currencySymbol = json['currency_symbol']?.toString() ?? '',
      currencyDecimalPlaces =
          int.tryParse(json['currency_decimal_places']?.toString() ?? '') ?? 2,
      dateFormat = (json['date_format']?.toString() ?? '').isNotEmpty
          ? json['date_format'].toString()
          : 'DD-MM-YYYY',
      timeFormat = (json['time_format']?.toString() ?? '').isNotEmpty
          ? json['time_format'].toString()
          : 'h:i A',
      codEnabled = _flag(json['cod_setting']),
      onlinePaymentEnabled = _flag(json['payment_gateway_setting']),
      paymentGateways = json['payment_gateways'] is List
          ? [
              for (final Object? g in json['payment_gateways'] as List)
                if (g is Map)
                  CountryPaymentGateway.fromJson(Map<String, dynamic>.from(g)),
            ]
          : const <CountryPaymentGateway>[];

  static bool? _flag(final Object? value) =>
      value == null ? null : value.toString() == '1';

  /// ISO currency code, e.g. `INR`.
  final String currency;

  /// Symbol, or the currency text when the country has no symbol.
  final String currencySymbol;
  final int currencyDecimalPlaces;

  /// One of `DD-MM-YYYY`, `MM-DD-YYYY`, `YYYY-MM-DD`, `DD/MM/YYYY`,
  /// `MM/DD/YYYY`, `DD Mon YYYY`.
  final String dateFormat;

  /// `h:i A` (12-hour) or `H:i` (24-hour).
  final String timeFormat;

  /// [dateFormat] as an `intl` pattern, e.g. `DD Mon YYYY` -> `dd MMM yyyy`.
  String get intlDateFormat => dateFormat
      .replaceAll('DD', 'dd')
      .replaceAll('YYYY', 'yyyy')
      .replaceAll('Mon', 'MMM');

  bool get use24HourFormat => timeFormat == 'H:i';

  /// Cash on delivery switch for this country (`cod_setting`); null when the
  /// backend didn't send it.
  final bool? codEnabled;

  /// Online payment switch for this country (`payment_gateway_setting`).
  final bool? onlinePaymentEnabled;

  /// Enabled gateways for this country. Only returned for a logged-in
  /// customer, so it is empty for a guest even when online payment is on.
  final List<CountryPaymentGateway> paymentGateways;

  /// Whether [paymentGateways] can be trusted as the full gateway list: it is
  /// empty-and-meaningful only when online payment is off. An empty list with
  /// online payment on just means the settings were fetched without a token.
  bool get hasPaymentGatewayList =>
      paymentGateways.isNotEmpty || onlinePaymentEnabled == false;
}

/// One enabled gateway of `get_country_settings.payment_gateways`. Secret keys
/// are never returned.
class CountryPaymentGateway {
  CountryPaymentGateway.fromJson(final Map<String, dynamic> json)
    : gateway = (json['gateway']?.toString() ?? '').toLowerCase(),
      label = json['label']?.toString() ?? '',
      mode = json['mode']?.toString() ?? '',
      currency = json['currency']?.toString() ?? '',
      appId = json['app_id']?.toString() ?? '',
      clientKey = _clientKey(json);

  /// Lower-case id: `stripe`, `razorpay`, `paystack`, `paypal`,
  /// `flutterwave`, `xendit`, `cashfree`.
  final String gateway;
  final String label;
  final String mode;
  final String currency;

  /// Cashfree's `app_id` (it has no client key).
  final String appId;

  /// The public key, whatever the gateway calls it: `key` (Razorpay,
  /// Paystack), `publishable_key` (Stripe), `client_key` (PayPal),
  /// `public_key` (Flutterwave).
  final String clientKey;

  static String _clientKey(final Map<String, dynamic> json) {
    for (final String field in const [
      'publishable_key',
      'key',
      'client_key',
      'public_key',
    ]) {
      final String value = json[field]?.toString() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }
}
