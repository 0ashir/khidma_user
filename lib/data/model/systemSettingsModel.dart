import 'package:intl/intl.dart';
import '../../app/generalImports.dart';

class SystemSettingsModel {
  SystemSettingsModel({
    this.paymentGatewaysSettings,
    this.generalSettings,
    this.socialMediaURLs,
    this.appSetting,
    this.systemTaxSettings,
    this.loginSettings,
    this.chatSettings,
    this.customJobSettings,
    this.mapProvider,
    this.cartSettings,
  });

  SystemSettingsModel.fromJson(final Map<String, dynamic> json) {
    paymentGatewaysSettings = json["payment_gateways_settings"] != null
        ? PaymentGatewaysSettings.fromJson(json["payment_gateways_settings"])
        : null;
    appSetting = json["app_settings"] != null
        ? AppSetting.fromJson(json["app_settings"])
        : null;
    generalSettings = json["general_settings"] != null
        ? GeneralSettings.fromJson(json["general_settings"])
        : null;
    socialMediaURLs =
        json["web_settings"] != null &&
            json["web_settings"]["social_media"] != null &&
            (json["web_settings"]["social_media"] is List) &&
            (json["web_settings"]["social_media"] as List).isNotEmpty
        ? (json["web_settings"]["social_media"] as List)
              .map((e) => SocialMediaURL.fromJson(Map.from(e)))
              .toList()
        : [];
    systemTaxSettings = json["system_tax_settings"] != null
        ? SystemTaxSettings.fromJson(json["system_tax_settings"])
        : null;

    loginSettings = json["login_settings"] != null
        ? LoginSettings.fromJson(json["login_settings"])
        : null;

    chatSettings = json["chat_settings"] != null
        ? ChatSettings.fromJson(json["chat_settings"])
        : null;
    customJobSettings = json["custom_job_settings"] != null
        ? CustomJobSettings.fromJson(
            Map<String, dynamic>.from(json["custom_job_settings"]),
          )
        : null;
    mapProvider = json["map_provider"]?.toString().toLowerCase();
    cartSettings = json["cart_settings"] != null
        ? CartSettings.fromJson(
            Map<String, dynamic>.from(json["cart_settings"]),
          )
        : null;
  }

  List<SocialMediaURL>? socialMediaURLs;
  PaymentGatewaysSettings? paymentGatewaysSettings;
  GeneralSettings? generalSettings;
  AppSetting? appSetting;
  SystemTaxSettings? systemTaxSettings;
  LoginSettings? loginSettings;
  ChatSettings? chatSettings;
  CustomJobSettings? customJobSettings;
  String? mapProvider;
  CartSettings? cartSettings;
}

class PaymentGatewaysSettings {
  PaymentGatewaysSettings({
    this.razorpayApiStatus,
    this.razorpayMode,
    this.razorpayCurrency,
    this.razorpayKey,
    this.paystackStatus,
    this.paystackMode,
    this.paystackCurrency,
    this.paystackKey,
    this.flutterPublicKey,
    this.stripeStatus,
    this.stripeMode,
    this.stripeCurrency,
    this.stripePublishableKey,
    this.paypalStatus,
    this.isOnlinePaymentEnable,
    this.isPayLaterEnable,
    this.isFlutterwaveEnable,
    this.flutterwaveWebsiteUrl,
    this.paypalWebsiteUrl,
    this.isXenditEnabled,
    this.xenditWebsiteUrl,
    this.isCashfreeEnabled,
    this.cashfreeEnvironment,
    this.cashfreeAppId,
  });

  PaymentGatewaysSettings.fromJson(final Map<String, dynamic> json) {
    isPayLaterEnable = json["cod_setting"]?.toString() ?? "1";
    isOnlinePaymentEnable = json["payment_gateway_setting"]?.toString() ?? "0";
    razorpayApiStatus = json["razorpayApiStatus"];
    razorpayMode = json["razorpay_mode"];
    razorpayCurrency = json["razorpay_currency"];
    razorpayKey = json["razorpay_key"];
    paystackStatus = json["paystack_status"];
    paystackMode = json["paystack_mode"];
    paystackCurrency = json["paystack_currency"];
    paystackKey = json["paystack_key"];
    flutterPublicKey = json["flutter_public_key"];
    stripeStatus = json["stripe_status"];
    stripeMode = json["stripe_mode"];
    stripeCurrency = json["stripe_currency"];
    stripePublishableKey = json["stripe_publishable_key"];
    paypalStatus = json["paypal_status"];
    isFlutterwaveEnable = json["flutterwave_status"];
    flutterwaveWebsiteUrl = json["flutterwave_website_url"];
    paypalWebsiteUrl = json["paypal_website_url"];
    isXenditEnabled = (json['xendit_status']?.toString() ?? '') == 'enable';
    xenditWebsiteUrl = json['xendit_website_url'];
    // Cashfree
    isCashfreeEnabled = (json['cashfree_status']?.toString() ?? '') == 'enable';
    cashfreeEnvironment = json['cashfree_mode']?.toString() ?? '';
    cashfreeAppId = json['cashfree_app_id']?.toString() ?? '';
  }

  /// This settings object with the country's payment setup applied
  /// (`get_country_settings`): COD / online switches, which gateways are on,
  /// and their key, mode and currency. Anything the country response doesn't
  /// carry (website URLs, Cashfree app id) keeps its `get_settings` value.
  PaymentGatewaysSettings withCountry(final CountrySettings country) {
    final PaymentGatewaysSettings merged = PaymentGatewaysSettings()
      ..razorpayApiStatus = razorpayApiStatus
      ..razorpayMode = razorpayMode
      ..razorpayCurrency = razorpayCurrency
      ..razorpayKey = razorpayKey
      ..paystackStatus = paystackStatus
      ..paystackMode = paystackMode
      ..paystackCurrency = paystackCurrency
      ..paystackKey = paystackKey
      ..flutterPublicKey = flutterPublicKey
      ..stripeStatus = stripeStatus
      ..stripeMode = stripeMode
      ..stripeCurrency = stripeCurrency
      ..stripePublishableKey = stripePublishableKey
      ..paypalStatus = paypalStatus
      ..isPayLaterEnable = isPayLaterEnable
      ..isOnlinePaymentEnable = isOnlinePaymentEnable
      ..isFlutterwaveEnable = isFlutterwaveEnable
      ..flutterwaveWebsiteUrl = flutterwaveWebsiteUrl
      ..paypalWebsiteUrl = paypalWebsiteUrl
      ..isXenditEnabled = isXenditEnabled
      ..xenditWebsiteUrl = xenditWebsiteUrl
      ..isCashfreeEnabled = isCashfreeEnabled
      ..cashfreeEnvironment = cashfreeEnvironment
      ..cashfreeAppId = cashfreeAppId;

    if (country.codEnabled != null) {
      merged.isPayLaterEnable = country.codEnabled! ? '1' : '0';
    }
    if (country.onlinePaymentEnabled != null) {
      merged.isOnlinePaymentEnable = country.onlinePaymentEnabled! ? '1' : '0';
    }
    if (!country.hasPaymentGatewayList) return merged;

    CountryPaymentGateway? gateway(final String id) {
      for (final CountryPaymentGateway g in country.paymentGateways) {
        if (g.gateway == id) return g;
      }
      return null;
    }

    String status(final CountryPaymentGateway? g) =>
        g == null ? 'disable' : 'enable';

    // CountryPaymentGateway fields default to '' (never null), so `??` alone
    // would replace a valid global key/mode/currency with an empty string
    // whenever a country enables a gateway without its own credentials.
    String? orGlobal(final String? countryValue, final String? globalValue) =>
        (countryValue == null || countryValue.isEmpty)
        ? globalValue
        : countryValue;

    final CountryPaymentGateway? stripe = gateway('stripe');
    merged
      ..stripeStatus = status(stripe)
      ..stripeMode = orGlobal(stripe?.mode, stripeMode)
      ..stripeCurrency = orGlobal(stripe?.currency, stripeCurrency)
      ..stripePublishableKey = orGlobal(
        stripe?.clientKey,
        stripePublishableKey,
      );

    final CountryPaymentGateway? razorpay = gateway('razorpay');
    merged
      ..razorpayApiStatus = status(razorpay)
      ..razorpayMode = orGlobal(razorpay?.mode, razorpayMode)
      ..razorpayCurrency = orGlobal(razorpay?.currency, razorpayCurrency)
      ..razorpayKey = orGlobal(razorpay?.clientKey, razorpayKey);

    final CountryPaymentGateway? paystack = gateway('paystack');
    merged
      ..paystackStatus = status(paystack)
      ..paystackMode = orGlobal(paystack?.mode, paystackMode)
      ..paystackCurrency = orGlobal(paystack?.currency, paystackCurrency)
      ..paystackKey = orGlobal(paystack?.clientKey, paystackKey);

    merged.paypalStatus = status(gateway('paypal'));

    final CountryPaymentGateway? flutterwave = gateway('flutterwave');
    merged
      ..isFlutterwaveEnable = status(flutterwave)
      ..flutterPublicKey = orGlobal(flutterwave?.clientKey, flutterPublicKey);

    merged.isXenditEnabled = gateway('xendit') != null;

    final CountryPaymentGateway? cashfree = gateway('cashfree');
    merged.isCashfreeEnabled = cashfree != null;
    if (cashfree != null) {
      if (cashfree.appId.isNotEmpty) merged.cashfreeAppId = cashfree.appId;
      // The SDK environment is 'production' or 'sandbox'; the country
      // response says 'test' for sandbox.
      final String mode = cashfree.mode.toLowerCase();
      if (mode.isNotEmpty) {
        merged.cashfreeEnvironment = mode == 'production' || mode == 'live'
            ? 'production'
            : 'sandbox';
      }
    }
    return merged;
  }

  String? razorpayApiStatus;
  String? razorpayMode;
  String? razorpayCurrency;
  String? razorpayKey;
  String? paystackStatus;
  String? paystackMode;
  String? paystackCurrency;
  String? paystackKey;
  String? flutterPublicKey;
  String? stripeStatus;
  String? stripeMode;
  String? stripeCurrency;
  String? stripePublishableKey;
  String? paypalStatus;
  String? isPayLaterEnable;
  String? isOnlinePaymentEnable;
  String? isFlutterwaveEnable;
  String? flutterwaveWebsiteUrl;
  String? paypalWebsiteUrl;
  bool? isXenditEnabled;
  String? xenditWebsiteUrl;
  // Cashfree
  bool? isCashfreeEnabled;

  /// 'sandbox' or 'production'
  String? cashfreeEnvironment;
  String? cashfreeAppId;
}

class SocialMediaURL {
  SocialMediaURL({this.imageURL, this.url});

  SocialMediaURL.fromJson(final Map<String, dynamic> json) {
    imageURL = json["file"];
    url = json["url"];
  }

  String? imageURL;
  String? url;
}

class GeneralSettings {
  GeneralSettings({
    this.translatedCompanyTitle,
    this.supportName,
    this.supportEmail,
    this.phone,
    this.maxServiceableDistance,
    this.translatedAddress,
    this.translatedShortDescription,
    this.translatedCopyrightDetails,
    this.supportHours,
    this.isOTPSystemEnable,
    this.showProviderAddress,
    required this.isDemoModeEnabled,
    this.distanceUnit,
    this.defaultCountryCode,
    this.countryCurrencyCode,
    this.currency,
    this.decimalPoint,
    this.categoryDetailsViewType,
  });

  GeneralSettings.fromJson(final Map<String, dynamic> json) {
    translatedCompanyTitle =
        (json["translated_company_title"]?.toString() ?? '').isNotEmpty
        ? json["translated_company_title"]!.toString()
        : (json["company_title"]?.toString() ?? '');
    supportName = json["support_name"];
    supportEmail = json["support_email"];
    phone = json["phone"];
    maxServiceableDistance =
        json["max_serviceable_distance"]?.toString() ?? "0";

    translatedAddress =
        (json["translated_address"]?.toString() ?? '').isNotEmpty
        ? json["translated_address"]!.toString()
        : (json["address"]?.toString() ?? '');
    translatedShortDescription =
        (json["translated_short_description"]?.toString() ?? '').isNotEmpty
        ? json["translated_short_description"]!.toString()
        : (json["short_description"]?.toString() ?? '');
    translatedCopyrightDetails =
        (json["translated_copyright_details"]?.toString() ?? '').isNotEmpty
        ? json["translated_copyright_details"]!.toString()
        : (json["copyright_details"]?.toString() ?? '');
    supportHours = json["support_hours"];
    isOTPSystemEnable = json["otp_system"];
    showProviderAddress = json['provider_location_in_provider_details'] ?? "0";

    defaultCountryCode = json["default_country_code"];
    isDemoModeEnabled =
        (json['demo_mode'] == "" || json["demo_mode"] == null
            ? 0
            : json["demo_mode"]) ==
        "1";
    distanceUnit = json["distance_unit"];

    countryCurrencyCode = json["country_currency_code"];
    currency = json["currency"];
    decimalPoint = json["decimal_point"] == "" ? "0" : json["decimal_point"];
    categoryDetailsViewType =
        json["category_details_view_type"]?.toString() ?? "providers";
  }

  String? companyTitle;
  String? translatedCompanyTitle;
  String? supportName;
  String? supportEmail;
  String? phone;

  String? maxServiceableDistance;

  String? address;
  String? translatedAddress;
  String? shortDescription;
  String? translatedShortDescription;
  String? copyrightDetails;
  String? translatedCopyrightDetails;
  String? supportHours;
  String? isOTPSystemEnable;
  String? showProviderAddress;

  bool isDemoModeEnabled = false;
  String? distanceUnit;
  String? defaultCountryCode;

  String? countryCurrencyCode;
  String? currency;
  String? decimalPoint;
  String? categoryDetailsViewType;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['translated_company_title'] = translatedCompanyTitle;
    data['support_name'] = supportName;
    data['support_email'] = supportEmail;
    data['phone'] = phone;
    data['max_serviceable_distance'] = maxServiceableDistance;

    data['translated_address'] = translatedAddress;
    data['translated_short_description'] = translatedShortDescription;
    data['translated_copyright_details'] = translatedCopyrightDetails;
    data['support_hours'] = supportHours;
    data['otp_system'] = isOTPSystemEnable;

    data['demo_mode'] = isDemoModeEnabled ? "1" : "0";
    return data;
  }
}

class AppSetting {
  AppSetting({
    this.customerCurrentVersionAndroidApp,
    this.customerCurrentVersionIosApp,
    this.customerCompulsaryUpdateForceUpdate,
    this.providerCurrentVersionAndroidApp,
    this.providerCurrentVersionIosApp,
    this.providerCompulsaryUpdateForceUpdate,
    this.messageForCustomerApplication,
    this.translatedMessageForCustomerApplication,
    this.customerAppMaintenanceMode,
    this.providerAppAppStoreURL,
    this.providerAppPlayStoreURL,
    this.customerAppAppStoreURL,
    this.customerAppPlayStoreURL,
    this.androidBannerId,
    this.androidInterstitialId,
    this.isAndroidAdEnabled,
    this.iosBannerId,
    this.iosInterstitialId,
    this.isIosAdEnabled,
    this.customerAppScheduleMaintenanceMode,
    this.customerAppMaintenanceModeStartDateTime,
    this.customerAppMaintenanceModeEndDateTime,
  });

  AppSetting.fromJson(final Map<String, dynamic> json) {
    customerCurrentVersionAndroidApp =
        json["customer_current_version_android_app"];
    customerCurrentVersionIosApp = json["customer_current_version_ios_app"];
    customerCompulsaryUpdateForceUpdate =
        json["customer_compulsary_update_force_update"];
    providerCurrentVersionAndroidApp =
        json["provider_current_version_android_app"];
    providerCurrentVersionIosApp = json["provider_current_version_ios_app"];
    providerCompulsaryUpdateForceUpdate =
        json["provider_compulsary_update_force_update"];
    messageForCustomerApplication = json["message_for_customer_application"];
    translatedMessageForCustomerApplication =
        json["translated_message_for_customer_application"];
    customerAppMaintenanceMode = json["customer_app_maintenance_mode"];
    customerAppPlayStoreURL = customerPlayStoreUrl;
    customerAppAppStoreURL = customerAppStoreUrl;
    providerAppPlayStoreURL = providerPlayStoreUrl;
    providerAppAppStoreURL = providerAppStoreUrl;
    //
    isAndroidAdEnabled = enableAds
        ? (json['customer_android_google_ads_status'] ?? '0')
        : '0';
    androidInterstitialId =
        json['customer_android_google_interstitial_id'] ?? "";
    androidBannerId = json['customer_android_google_banner_id'] ?? "";
    isIosAdEnabled = enableAds
        ? (json['customer_ios_google_ads_status'] ?? '0')
        : '0';
    iosInterstitialId = json['customer_ios_google_interstitial_id'] ?? "";
    iosBannerId = json['customer_ios_google_banner_id'] ?? "";
    customerAppScheduleMaintenanceMode =
        json['customer_app_scheduled_maintenance_mode']?.toString() == '1';
    customerAppMaintenanceModeStartDateTime = DateFormat('yyyy-MM-dd HH:mm:ss')
        .tryParse(
          json['customer_app_maintenance_mode_start_datetime']?.toString() ??
              '',
          true,
        );
    customerAppMaintenanceModeEndDateTime = DateFormat('yyyy-MM-dd HH:mm:ss')
        .tryParse(
          json['customer_app_maintenance_mode_end_datetime']?.toString() ?? '',
          true,
        );
  }

  String? customerCurrentVersionAndroidApp;
  String? customerCurrentVersionIosApp;
  String? customerCompulsaryUpdateForceUpdate;
  String? providerCurrentVersionAndroidApp;
  String? providerCurrentVersionIosApp;
  String? providerCompulsaryUpdateForceUpdate;
  String? messageForCustomerApplication;
  String? translatedMessageForCustomerApplication;
  String? customerAppMaintenanceMode;
  String? customerAppAppStoreURL;
  String? customerAppPlayStoreURL;
  String? providerAppAppStoreURL;
  String? providerAppPlayStoreURL;
  String? isAndroidAdEnabled;
  String? androidBannerId;
  String? androidInterstitialId;
  String? isIosAdEnabled;
  String? iosBannerId;
  String? iosInterstitialId;
  bool? customerAppScheduleMaintenanceMode;
  DateTime? customerAppMaintenanceModeStartDateTime;
  DateTime? customerAppMaintenanceModeEndDateTime;
}

class SystemTaxSettings {
  SystemTaxSettings({
    this.taxStatus,
    this.taxName,
    this.tax,
    this.showOnCheckout,
  });

  SystemTaxSettings.fromJson(final Map<String, dynamic> json) {
    taxStatus = json["tax_status"] ?? "off";
    taxName = json["tax_name"] ?? "";
    tax = json["tax"] ?? "0";
    showOnCheckout = json["show_on_checkout"] ?? "0";
  }

  String? taxStatus;
  String? taxName;
  String? tax;
  String? showOnCheckout;
}

class CustomJobSettings {
  final int maxFilesAllowed;
  final int maxFileSizeImages;
  final int maxFileSizeVideo;
  final int maxFileSizeAudio;
  final int maxFileSizeOther;
  final bool allowImageUploads;
  final bool allowVideoUploads;
  final bool allowDocumentUploads;

  CustomJobSettings({
    required this.maxFilesAllowed,
    required this.maxFileSizeImages,
    required this.maxFileSizeVideo,
    required this.maxFileSizeAudio,
    required this.maxFileSizeOther,
    required this.allowImageUploads,
    required this.allowVideoUploads,
    required this.allowDocumentUploads,
  });

  factory CustomJobSettings.fromJson(Map<String, dynamic> json) {
    return CustomJobSettings(
      maxFilesAllowed:
          int.tryParse(json['max_files_allowed']?.toString() ?? '5') ?? 5,
      maxFileSizeImages:
          int.tryParse(json['max_file_size_images']?.toString() ?? '5') ?? 5,
      maxFileSizeVideo:
          int.tryParse(json['max_file_size_video']?.toString() ?? '100') ?? 100,
      maxFileSizeAudio:
          int.tryParse(json['max_file_size_audio']?.toString() ?? '5') ?? 5,
      maxFileSizeOther:
          int.tryParse(json['max_file_size_other']?.toString() ?? '10') ?? 10,
      allowImageUploads: json['allow_image_uploads']?.toString() == '1',
      allowVideoUploads: json['allow_video_uploads']?.toString() == '1',
      allowDocumentUploads: json['allow_document_uploads']?.toString() == '1',
    );
  }
}

class CartSettings {
  final int maxItemsPerProvider;
  final int maxCartsPerUser;
  final int cartReminderIntervalMinutes;
  final int maxCartReminders;

  CartSettings({
    required this.maxItemsPerProvider,
    required this.maxCartsPerUser,
    required this.cartReminderIntervalMinutes,
    required this.maxCartReminders,
  });

  factory CartSettings.fromJson(Map<String, dynamic> json) {
    return CartSettings(
      maxItemsPerProvider:
          int.tryParse(json['max_items_per_provider']?.toString() ?? '5') ?? 5,
      maxCartsPerUser:
          int.tryParse(json['max_carts_per_user']?.toString() ?? '3') ?? 3,
      cartReminderIntervalMinutes:
          int.tryParse(
            json['cart_reminder_interval_minutes']?.toString() ?? '1440',
          ) ??
          1440,
      maxCartReminders:
          int.tryParse(json['max_cart_reminders']?.toString() ?? '3') ?? 3,
    );
  }
}

class LoginSettings {
  bool? isPhoneAuthEnabled;
  bool? isEmailAuthEnabled;
  bool? isPasswordLoginEnabled;
  bool? isSocialLoginEnabled;
  int? minumumPasswordLength;
  bool? requireAtLeastOneUppercase;
  bool? requireAtLeastOneLowercase;
  bool? requireAtLeastOneNumber;
  bool? requireAtLeastOneSpecialCharacter;

  LoginSettings({
    this.isPhoneAuthEnabled,
    this.isEmailAuthEnabled,
    this.isPasswordLoginEnabled,
    this.isSocialLoginEnabled,
    this.minumumPasswordLength,
    this.requireAtLeastOneUppercase,
    this.requireAtLeastOneLowercase,
    this.requireAtLeastOneNumber,
    this.requireAtLeastOneSpecialCharacter,
  });

  LoginSettings.fromJson(final Map<String, dynamic> json) {
    final phoneValue = json["phone_authentication_enabled"]?.toString() ?? "1";
    final emailValue = json["email_authentication_enabled"]?.toString() ?? "1";
    final passwordValue =
        json["customer_password_login_enabled"]?.toString() ?? "1";
    final socialValue =
        json["social_authentication_enabled"]?.toString() ?? "0";

    final minumumPasswordLengthValue =
        json["minimum_password_length"]?.toString() ?? "0";
    final requireAtLeastOneUppercaseValue =
        json["require_at_least_one_uppercase"]?.toString() ?? "0";
    final requireAtLeastOneLowercaseValue =
        json["require_at_least_one_lowercase"]?.toString() ?? "0";
    final requireAtLeastOneNumberValue =
        json["require_at_least_one_number"]?.toString() ?? "0";
    final requireAtLeastOneSpecialCharacterValue =
        json["require_at_least_one_special_character"]?.toString() ?? "0";

    isPhoneAuthEnabled = phoneValue == "1";
    isEmailAuthEnabled = emailValue == "1";
    isPasswordLoginEnabled = passwordValue == "1";
    isSocialLoginEnabled = socialValue == "1";

    minumumPasswordLength = int.tryParse(minumumPasswordLengthValue);
    //we'll not check for validation if it's null, so going with null for 0
    if (minumumPasswordLength == 0) {
      minumumPasswordLength = null;
    }
    requireAtLeastOneUppercase = requireAtLeastOneUppercaseValue == "1";
    requireAtLeastOneLowercase = requireAtLeastOneLowercaseValue == "1";
    requireAtLeastOneNumber = requireAtLeastOneNumberValue == "1";
    requireAtLeastOneSpecialCharacter =
        requireAtLeastOneSpecialCharacterValue == "1";
  }
}
