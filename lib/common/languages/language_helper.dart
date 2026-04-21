import 'package:flutter/material.dart';

class LanguageHelper {
  convertLangNameToLocale(String langNameToConvert) {
    Locale convertedLocale;

    switch (langNameToConvert) {
      case "english":
        convertedLocale = const Locale('en', 'EN');
        break;
      case 'German':
        convertedLocale = const Locale('de', 'DE');
        break;
      case 'arabic':
        convertedLocale = const Locale('ar', 'AE');
        break;
      default:
        convertedLocale = const Locale('en', 'EN');
    }

    return convertedLocale;
  }

  convertLocaleToLangName(String localeToConvert) {
    String langName;
    switch (localeToConvert) {
      case 'en':
        langName = "English";
        break;
    
      case 'de':
        langName = "Español";
        break;
      case 'ru':
        langName = "Русский";
        break;
      default:
        langName = "English";
    }

    return langName;
  }
}