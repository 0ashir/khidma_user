import 'dart:developer';
import '../config.dart';

String apiUrl = "https://admin.khidmaplus.com/api";
String paymentUrl = "https://admin.khidmaplus.com/";
String playstoreUrl = "https://play.google.com/store/apps/details?id=com.khdamat.provider&pcampaignid=web_share";
String userAppPlayStoreUrl = "https://apps.apple.com/us/app/khidma-plus-home-services/id6755617892";
String googleMapKey = "AIzaSyDNbeNlSQb8NyHK-z-JlVQWicssGnzyJms";
String googleSignInKey = "Enter your google signin key here";
late SharedPreferences sharedPreferences;
String local = appSettingModel!.general!.defaultLanguage!.locale!;

// Initialize SharedPreferences and Locale
Future<void> initializeAppSettings() async {
  sharedPreferences = await SharedPreferences.getInstance();
  local =
      sharedPreferences.getString('selectedLocale') ??
      appSettingModel?.general?.defaultLanguage?.locale ??
      "en";
  log("set language:: $local");
}

// Headers Token Function
Map<String, String>? headersToken(String? token) => {
  'Accept': 'application/json',
  'Content-Type': 'application/json',
  "Accept-Lang": local,
  "Authorization": "Bearer $token",
};

// Default Headers
Map<String, String>? get headers => {
  'Accept': 'application/json',
  'Content-Type': 'application/json',
  "Accept-Lang": local,
};
