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
          url: ApiUrl.getSystemSettings, parameter: {}, useAuthToken: true);

      return SystemSettingsModel.fromJson(Map.from(response['data']));
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ///This method is used to fetch language list
  Future<LanguageListModel> getLanguageList() async {
    try {
      final response =
          await ApiClient.get(url: ApiUrl.getLanguageList, useAuthToken: false);

      return LanguageListModel.fromJson(response);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ///This method is used to fetch language JSON data
  Future<Map<String, dynamic>> getLanguageJsonData(String languageCode) async {
    try {
      final response = await ApiClient.post(
          url: ApiUrl.getLanguageJsonData,
          parameter: {
            ApiParam.languageCode: languageCode,
            ApiParam.platform: 'customer_app'
          },
          useAuthToken: false);

      return response['data'] ?? {};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
