import 'package:e_demand/app/generalImports.dart';

class SettingRepository {
  String getCurrentLanguageCode() => 'en';

  Future<void> setCurrentLanguageCode(final String value) async {}

  Future<void> setTheme(final String theme) async {
    //add in hive
  }

  ///This method is used to fetch system settings
  Future<SystemSettingsModel> getSystemSetting() async {
    try {
      final response = await ApiClient.post(
        url: ApiUrl.getSystemSettings,
        parameter: {},
        useAuthToken: true,
      );

      return SystemSettingsModel.fromJson(Map.from(response['data']));
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ///This method is used to fetch the currency and date/time formats of the
  ///country covering the given coordinates (public endpoint)
  String _countrySettingsCacheKey(
    final String latitude,
    final String longitude,
  ) => ApiResponseCache.keyFor(ApiUrl.getCountrySettings, {
    ApiParam.latitude: latitude,
    ApiParam.longitude: longitude,
  });

  /// Last saved country settings for these coordinates (shown instantly by
  /// cached screens until the fresh ones arrive).
  CountrySettings? cachedCountrySettings({
    required final String latitude,
    required final String longitude,
  }) {
    final Map<String, dynamic>? data = ApiResponseCache.read(
      _countrySettingsCacheKey(latitude, longitude),
    );
    if (data == null) return null;
    try {
      return CountrySettings.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<CountrySettings> getCountrySettings({
    required final String latitude,
    required final String longitude,
  }) async {
    try {
      final response = await ApiClient.post(
        url: ApiUrl.getCountrySettings,
        parameter: {ApiParam.latitude: latitude, ApiParam.longitude: longitude},
        // The token is optional, but `payment_gateways` is only returned for a
        // logged-in customer. Skipped for guests: an empty bearer is invalid.
        useAuthToken: HiveRepository.getUserToken.isNotEmpty,
      );

      final Map<String, dynamic> data = Map<String, dynamic>.from(
        response['data'],
      );
      final CountrySettings settings = CountrySettings.fromJson(data);
      ApiResponseCache.write(
        _countrySettingsCacheKey(latitude, longitude),
        data,
      );
      return settings;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ///This method is used to fetch the admin's theme colour palette
  ///(seed colours + expanded 50…950 stops per hue) for [ThemePaletteCubit].
  Future<Map<String, dynamic>> getThemeColors() async {
    try {
      final response = await ApiClient.get(
        url: ApiUrl.getThemeColors,
        useAuthToken: false,
      );

      return Map<String, dynamic>.from(response['data']);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ///This method is used to fetch language list
  Future<LanguageListModel> getLanguageList() async {
    try {
      final response = await ApiClient.get(
        url: ApiUrl.getLanguageList,
        useAuthToken: false,
        queryParameters: {'platform': 'customer_app'},
      );

      return LanguageListModel.fromJson(response);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ///This method is used to fetch language JSON data
  Future<Map<String, dynamic>> getLanguageJsonData(String languageCode) async {
    try {
      final parameters = <String, dynamic>{
        ApiParam.languageCode: languageCode,
        ApiParam.platform: 'customer_app',
      };

      // Add fcm_token parameter
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          parameters[ApiParam.fcmToken] = fcmToken;
        }
      } catch (e) {
        // If FCM token retrieval fails, continue without it
        // This is not a critical error for language data fetching
      }

      final response = await ApiClient.post(
        url: ApiUrl.getLanguageJsonData,
        parameter: parameters,
        useAuthToken: false,
      );

      return response['data'] ?? {};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
