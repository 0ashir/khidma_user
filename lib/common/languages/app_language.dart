import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
  AppLocalizationDelagate();

  static AppLocalizations? of(context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  Future<bool> load(Map<String, Map<String, String>> localizedData) async {
    _localizedStrings = localizedData[locale.languageCode] ?? {};
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class AppLocalizationDelagate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelagate();

  @override
  bool isSupported(Locale locale) {
    return true; // Dynamic support based on API data
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate old) {
    return false;
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations appLocalizations = AppLocalizations(locale);
    return appLocalizations;
  }
}
