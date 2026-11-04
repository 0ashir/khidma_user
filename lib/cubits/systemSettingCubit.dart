import 'package:e_demand/app/generalImports.dart';

abstract class SystemSettingState {}

class SystemSettingFetchInitial extends SystemSettingState {}

class SystemSettingFetchInProgress extends SystemSettingState {}

class SystemSettingFetchSuccess extends SystemSettingState {
  SystemSettingFetchSuccess({required this.systemSettingDetails});

  final SystemSettingsModel systemSettingDetails;
}

class SystemSettingFetchFailure extends SystemSettingState {
  SystemSettingFetchFailure({required this.errorMessage});

  final dynamic errorMessage;
}

class SystemSettingCubit extends Cubit<SystemSettingState> {
  SystemSettingCubit({
    required this.settingRepository,
    this.countrySettingsCubit,
  }) : super(SystemSettingFetchInitial());
  SettingRepository settingRepository = SettingRepository();

  /// Source of the per-country payment setup (COD / online switches and the
  /// enabled gateways) that overrides the global one from `get_settings`.
  final CountrySettingsCubit? countrySettingsCubit;

  Future<void> getSystemSettings() async {
    emit(SystemSettingFetchInProgress());
    settingRepository
        .getSystemSetting()
        .then((final SystemSettingsModel value) {
          emit(SystemSettingFetchSuccess(systemSettingDetails: value));
        })
        .catchError((final error) {
          emit(SystemSettingFetchFailure(errorMessage: error.toString()));
        });
  }

  AppSetting? get appSetting {
    if (state is SystemSettingFetchSuccess) {
      return (state as SystemSettingFetchSuccess)
          .systemSettingDetails
          .appSetting;
    }
    return null;
  }

  String get systemCurrency => generalSettings?.currency ?? '';

  String get systemCurrencyCountryCode =>
      generalSettings?.countryCurrencyCode ?? '';

  String get systemDecimalPoints => generalSettings?.decimalPoint ?? '0';

  GeneralSettings? get generalSettings {
    if (state is SystemSettingFetchSuccess) {
      return (state as SystemSettingFetchSuccess)
          .systemSettingDetails
          .generalSettings;
    }
    return null;
  }

  LoginSettings? get loginSettings {
    if (state is SystemSettingFetchSuccess) {
      return (state as SystemSettingFetchSuccess)
          .systemSettingDetails
          .loginSettings;
    }
    return null;
  }

  String get systemDistanceUnit => generalSettings?.distanceUnit ?? '';

  String get androidVersion =>
      appSetting?.customerCurrentVersionAndroidApp ?? '1.0.0';

  String get iOSVersion => appSetting?.customerCurrentVersionIosApp ?? '1.0.0';

  /// Payment setup for the customer's country when `get_country_settings` has
  /// loaded, otherwise the global one from `get_settings`.
  PaymentGatewaysSettings? get paymentGatewaysSettings {
    if (state is! SystemSettingFetchSuccess) return null;
    final PaymentGatewaysSettings? global = (state as SystemSettingFetchSuccess)
        .systemSettingDetails
        .paymentGatewaysSettings;
    final CountrySettings? country = countrySettingsCubit?.countrySettings;
    if (global == null || country == null) return global;
    return global.withCountry(country);
  }

  SystemTaxSettings? get systemTaxSettings {
    if (state is SystemSettingFetchSuccess) {
      return (state as SystemSettingFetchSuccess)
          .systemSettingDetails
          .systemTaxSettings;
    }
    return null;
  }

  CartSettings? get cartSettings {
    if (state is SystemSettingFetchSuccess) {
      return (state as SystemSettingFetchSuccess)
          .systemSettingDetails
          .cartSettings;
    }
    return null;
  }

  SystemSettingsModel get systemSettings =>
      (state as SystemSettingFetchSuccess).systemSettingDetails;

  String get messageForCustomerApplication {
    final AppSetting? appSetting = this.appSetting;
    if (appSetting?.translatedMessageForCustomerApplication != null &&
        appSetting!.translatedMessageForCustomerApplication!.isNotEmpty) {
      return appSetting.translatedMessageForCustomerApplication!;
    }
    return appSetting?.messageForCustomerApplication ?? '';
  }

  bool get isOTPSystemEnable => generalSettings?.isOTPSystemEnable == "1";

  bool get isCategoryDetailsViewTypeServices =>
      generalSettings?.categoryDetailsViewType == "services";

  bool get showProviderAddress => generalSettings?.showProviderAddress == "1";

  bool get isOpenStreetMap => systemSettings.mapProvider == "openstreetmap";

  String get getCustomerAppURL => customerStoreUrl(isIOS: Platform.isIOS);

  String get getProviderAppURL => providerStoreUrl(isIOS: Platform.isIOS);

  Map<String, dynamic> get getSupportDetails => {
    "email": generalSettings?.supportEmail ?? '',
    "mobile": generalSettings?.phone ?? '',
    "address": generalSettings?.translatedAddress ?? '',
    "supportHours": generalSettings?.supportHours ?? '',
  };

  List<SocialMediaURL>? get socialMediaLinks => systemSettings.socialMediaURLs;

  CustomJobSettings? get customJobSettings {
    if (state is SystemSettingFetchSuccess) {
      return (state as SystemSettingFetchSuccess)
          .systemSettingDetails
          .customJobSettings;
    }
    return null;
  }

  bool get isDemoModeEnabled => generalSettings?.isDemoModeEnabled ?? false;

  bool get isAdEnabled =>
      appSetting?.isAndroidAdEnabled == "1" ||
      appSetting?.isIosAdEnabled == "1";

  ChatSettings? get chatSettings {
    if (state is SystemSettingFetchSuccess) {
      return (state as SystemSettingFetchSuccess)
          .systemSettingDetails
          .chatSettings;
    }
    return null;
  }

  bool get isChatImageUploadEnabled =>
      chatSettings?.isImageUploadAllowed ?? false;

  bool get isChatFileUploadEnabled =>
      chatSettings?.isFileUploadAllowed ?? false;

  bool get isTaxEnabled => systemTaxSettings?.taxStatus == "on";

  String get taxName => systemTaxSettings?.taxName ?? '';

  String get taxPercentage => systemTaxSettings?.tax ?? '0';

  bool get showTaxOnCheckout => systemTaxSettings?.showOnCheckout == "1";

  bool get isPayLaterAllowedGlobally =>
      paymentGatewaysSettings?.isPayLaterEnable == "1";

  bool get isOnlinePaymentAllowedGlobally =>
      paymentGatewaysSettings?.isOnlinePaymentEnable == "1";

  String get BannerAdId => Platform.isAndroid
      ? appSetting?.androidBannerId ?? ''
      : appSetting?.iosBannerId ?? '';

  String get InterstitialAdId => Platform.isAndroid
      ? appSetting?.androidInterstitialId ?? ''
      : appSetting?.iosInterstitialId ?? '';

  bool isMoreThanOnePaymentGatewayEnabled() {
    final bool paystackEnabled =
        paymentGatewaysSettings?.paystackStatus == "enable";
    final bool razorpayEnabled =
        paymentGatewaysSettings?.razorpayApiStatus == "enable";
    final bool paypalEnabled =
        paymentGatewaysSettings?.paypalStatus == "enable";
    final bool stripeEnabled =
        paymentGatewaysSettings?.stripeStatus == "enable";
    final bool flutterwaveEnabled =
        paymentGatewaysSettings?.isFlutterwaveEnable == "enable";
    final bool isXenditEnabled =
        paymentGatewaysSettings?.isXenditEnabled ?? false;
    final bool isCashfreeEnabled =
        paymentGatewaysSettings?.isCashfreeEnabled ?? false;

    int paymentGatewayCount = 0;
    if (paystackEnabled) {
      paymentGatewayCount++;
    }
    if (razorpayEnabled) {
      paymentGatewayCount++;
    }
    if (paypalEnabled) {
      paymentGatewayCount++;
    }
    if (stripeEnabled) {
      paymentGatewayCount++;
    }
    if (flutterwaveEnabled) {
      paymentGatewayCount++;
    }
    if (isXenditEnabled) {
      paymentGatewayCount++;
    }
    if (isCashfreeEnabled) {
      paymentGatewayCount++;
    }

    return paymentGatewayCount > 1;
  }

  List<Map<String, dynamic>> getEnabledPaymentMethods({
    required bool isPayLaterAllowed,
    bool? isOnlinePaymentAllowed,
  }) {
    if (state is SystemSettingFetchSuccess) {
      final PaymentGatewaysSettings? paymentGatewaySetting =
          paymentGatewaysSettings;

      final List<Map<String, dynamic>> paymentMethods = [
        {
          "title": 'payNow'.translate(
            context: UiUtils.rootNavigatorKey.currentContext!,
          ),
          "description": 'payOnlineNow',
          "optionDescription": "payOnlineNow",
          "image": AppAssets.card,
          "isEnabled":
              (isOnlinePaymentAllowed ?? false) &&
              !isMoreThanOnePaymentGatewayEnabled(),
          "paymentType": getSingleEnabledPaymentMethod(),
        },
        {
          "title": 'Paypal',
          "description": 'payOnlineNowUsingPaypal',
          "optionDescription": "payOnlineNowUsingPaypal",
          "image": AppAssets.paypal,
          "isEnabled":
              paymentGatewaySetting?.paypalStatus == "enable" &&
              isMoreThanOnePaymentGatewayEnabled(),
          "paymentType": "paypal",
        },
        {
          "title": 'Razorpay',
          "description": 'payOnlineNowUsingRazorpay',
          "optionDescription": "payOnlineNowUsingRazorpay",
          "image": AppAssets.razorpay,
          "isEnabled":
              paymentGatewaySetting?.razorpayApiStatus == "enable" &&
              isMoreThanOnePaymentGatewayEnabled(),
          "paymentType": "razorpay",
        },
        {
          "title": 'Paystack',
          "description": 'payOnlineNowUsingPaystack',
          "optionDescription": "payOnlineNowUsingPaystack",
          "image": AppAssets.paystack,
          "isEnabled":
              paymentGatewaySetting?.paystackStatus == "enable" &&
              isMoreThanOnePaymentGatewayEnabled(),
          "paymentType": "paystack",
        },
        {
          "title": 'Stripe',
          "description": 'payOnlineNowUsingStripe',
          "optionDescription": "payOnlineNowUsingStripe",
          "image": AppAssets.stripe,
          "isEnabled":
              paymentGatewaySetting?.stripeStatus == "enable" &&
              isMoreThanOnePaymentGatewayEnabled(),
          "paymentType": "stripe",
        },
        {
          "title": 'Flutterwave',
          "description": 'payOnlineNowUsingFlutterwave',
          "optionDescription": "payOnlineNowUsingFlutterwave",
          "image": AppAssets.flutterwave,
          "isEnabled":
              paymentGatewaySetting?.isFlutterwaveEnable == "enable" &&
              isMoreThanOnePaymentGatewayEnabled(),
          "paymentType": "flutterwave",
        },
        {
          "title": 'Xendit',
          "description": 'payOnlineNowUsingXendit',
          "optionDescription": "payOnlineNowUsingXendit",
          "image": AppAssets.xendit,
          "isEnabled":
              (paymentGatewaySetting?.isXenditEnabled ?? false) &&
              isMoreThanOnePaymentGatewayEnabled(),
          "paymentType": "xendit",
        },
        {
          "title": 'Cashfree',
          "description": 'payOnlineNowUsingCashfree',
          "optionDescription": "payOnlineNowUsingCashfree",
          "image": AppAssets.cashfree,
          "isEnabled":
              (paymentGatewaySetting?.isCashfreeEnabled ?? false) &&
              isMoreThanOnePaymentGatewayEnabled(),
          "paymentType": "cashfree",
        },
        {
          "title": 'payOnService'.translate(
            context: UiUtils.rootNavigatorKey.currentContext!,
          ),
          "description": 'payWithServiceAtYourHome',
          "optionDescription": "payWithServiceAtStore",
          "image": AppAssets.cod,
          // The provider/cart allowing pay-later isn't enough: the country's
          // (or the global) cash on delivery switch must be on too.
          'isEnabled': isPayLaterAllowed && isPayLaterAllowedGlobally,
          "paymentType": "cod",
        },
      ];

      paymentMethods.removeWhere((element) => !element["isEnabled"]);
      return paymentMethods;
    }
    return [];
  }

  String getSingleEnabledPaymentMethod() {
    String selectedPaymentMethod = '';
    if (state is SystemSettingFetchSuccess) {
      final PaymentGatewaysSettings? paymentGatewaySetting =
          paymentGatewaysSettings;
      if (paymentGatewaySetting?.stripeStatus == "enable") {
        selectedPaymentMethod = "stripe";
      } else if (paymentGatewaySetting?.razorpayApiStatus == "enable") {
        selectedPaymentMethod = "razorpay";
      } else if (paymentGatewaySetting?.paystackStatus == "enable") {
        selectedPaymentMethod = "paystack";
      } else if (paymentGatewaySetting?.paypalStatus == "enable") {
        selectedPaymentMethod = "paypal";
      } else if (paymentGatewaySetting?.isFlutterwaveEnable == "enable") {
        selectedPaymentMethod = "flutterwave";
      } else if (paymentGatewaySetting?.isXenditEnabled ?? false) {
        selectedPaymentMethod = "xendit";
      } else if (paymentGatewaySetting?.isCashfreeEnabled ?? false) {
        selectedPaymentMethod = "cashfree";
      }
    }
    return selectedPaymentMethod;
  }
}

enum TypesOfAppURLs {
  customerAppPlaystoreURL,
  customerAppAppstoreURL,
  providerAppPlaystoreURL,
  providerAppAppstoreURL,
}
