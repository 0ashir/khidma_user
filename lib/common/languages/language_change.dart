import 'dart:developer';
import 'package:fixit_user/common/languages/language_helper.dart';
import 'package:fixit_user/config.dart';
import 'package:fixit_user/services/environment.dart' as env;
import 'package:fixit_user/services/google_translation_service.dart';
import '../../models/system_language_model.dart';
import '../../models/translation_model.dart';

class LanguageProvider with ChangeNotifier {
  String currentLanguage = '';
  Locale? locale;
  int? selectedIndex;
  List<SystemLanguage> languageList = [];
  final SharedPreferences sharedPreferences;
  LanguageProvider(this.sharedPreferences, context) {
    var selectedLocale = sharedPreferences.getString("selectedLocale");

    if (selectedLocale != null) {
      locale = Locale(selectedLocale);
    } else {
      selectedLocale =
          appSettingModel?.general?.defaultLanguage?.name ?? "English";
      locale =
          Locale(appSettingModel?.general?.defaultLanguage?.locale ?? "en");

      log("messagedfiuhgiodjeiof $selectedLocale -=-=-=-=-= $locale");
    }

    setVal(selectedLocale, context);
    getLanguage();
    getLanguageTranslate(context);
  }
  getLanguage() async {
    // Fetches the list of available languages only — does NOT touch translations.
    try {
      final value = await apiServices.getApi(api.systemLanguage, [], isToken: false);
      if (value.isSuccess == true) {
        languageList.clear();
        for (var item in value.data) {
          SystemLanguage systemLanguage = SystemLanguage.fromJson(item);
          if (!languageList.contains(systemLanguage)) {
            languageList.add(systemLanguage);
          }
        }
        String? selectedLocaleCode =
            sharedPreferences.getString("selectedLocale") ?? "en";
        int index = languageList.indexWhere(
            (element) => element.appLocale?.split("_")[0] == selectedLocaleCode);
        selectedIndex = index != -1 ? index : 0;
        log("✅ Language list loaded. selectedIndex=$selectedIndex");
      }
      notifyListeners();
    } catch (e, s) {
      debugPrint("EEEE NOTI LANGUAGE $e-=-=-=-$s");
    }
  }

  // getLanguage() async {
  //   try {
  //     translations = Translation.defaultTranslations();
  //     await apiServices
  //         .getApi(api.systemLanguage, [], isToken: false)
  //         .then((value) {
  //       if (value.isSuccess!) {
  //         // log("VALue :%${value.data}");
  //         for (var item in value.data) {
  //           SystemLanguage systemLanguage = SystemLanguage.fromJson(item);
  //           if (!languageList.contains(systemLanguage)) {
  //             languageList.add(systemLanguage);
  //           }
  //         }
  //       }
  //       notifyListeners();
  //     });
  //   } catch (e) {
  //     debugPrint("EEEE NOTI LANGUAGE $e");
  //   }
  // }

  LanguageHelper languageHelper = LanguageHelper();
  bool isLoader = false;
  // Awaits the full translation fetch so screens rebuild exactly once with the
  // correct language — no English flash, no stale rebuild before data arrives.
  Future<void> changeLocale(newLocale, context) async {
    currentLanguage = newLocale.name!;
    locale = Locale(
        newLocale.appLocale!.split("_")[0], newLocale.appLocale!.split("_")[1]);
    final langCode = locale!.languageCode.toString();
    sharedPreferences.setString('selectedLocale', langCode);
    env.local = langCode;
    log('🌐 [changeLocale] switching to $langCode');
    GoogleTranslationService.clearCache();
    await getLanguageTranslate(context, languageCode: langCode);
    notifyListeners();
  }

  getLocal() {
    var selectedLocale = sharedPreferences.getString("selectedLocale");
    return selectedLocale;
  }

  bool? isTranslateLoader = false;
  //translateText api
  getLanguageTranslate(context,
      {bool? isSelectLanguage = false, String? languageCode}) async {
    isTranslateLoader = true;
    notifyListeners();
    try {
      // Do NOT reset translations before the await — keep whatever language
      // is currently shown so there is no English flash while data loads.
      final response = await apiServices.getApi(
          "${api.translate}/${locale!.languageCode}", [],
          isToken: false, isData: true);

      if (response.isSuccess == true && response.data != null) {
        translations = Translation.fromJson(response.data);
        _applyLabelOverrides(locale?.languageCode ?? 'en');
        log('🌐 [Translation] DONE — loaded for ${locale?.languageCode}');
      } else {
        log('🌐 [Translation] FAILED — keeping existing. message=${response.message}');
        translations ??= Translation.defaultTranslations();
      }
    } catch (e, s) {
      log('🌐 [Translation] ERROR — $e');
      translations ??= Translation.defaultTranslations();
    } finally {
      isTranslateLoader = false;
      notifyListeners();
    }
  }
  // getLanguageTranslate() async {
  //   log("locale!.languageCode ${locale!.languageCode}");
  //   isLoader = true;
  //   try {
  //     log("locale!.languageCode::${api.translate}/${locale!.languageCode}");
  //     translations = Translation.defaultTranslations();
  //     final response = await apiServices.getApi(
  //         "${api.translate}/${locale!.languageCode}", [],
  //         isToken: false, isData: true);
  //     log("response.isSuccess::${response.isSuccess}///${response}");
  //     if (response.isSuccess!) {
  //       isLoader = false;
  //       translations =
  //           Translation.fromJson(response.data); // Directly pass the map
  //       log("Loaded translations: ${translations!.skip}");
  //       notifyListeners();
  //     } else {
  //       Fluttertoast.showToast(
  //           msg: response.message, backgroundColor: Colors.red);
  //       // translations = Translation.defaultTranslations();
  //     }
  //   } catch (e) {
  //     isLoader = false;
  //     log('Error Translation: $e');
  //     translations = Translation.defaultTranslations();
  //   } finally {
  //     notifyListeners();
  //   }
  // }

  defineCurrentLanguage(context) {
    String? definedCurrentLanguage;
    if (currentLanguage.isNotEmpty) {
      log("definedCurrentLanguage:::$definedCurrentLanguage");
      definedCurrentLanguage = currentLanguage;
    } else {
      log("locale from currentData: ${Localizations.localeOf(context).toString()}");
      definedCurrentLanguage = languageHelper
          .convertLocaleToLangName(Localizations.localeOf(context).toString());
    }

    return definedCurrentLanguage;
  }

  setVal(value, context) {
    notifyListeners();
    int index = languageList.indexWhere((element) => element.locale == value);
    if (index >= 0) {
      SystemLanguage systemLanguage = languageList[index];
      changeLocale(systemLanguage, context);
    }
  }

  setIndex(index) {
    log("asdjhajkdhaks ajay ");
    selectedIndex = index;
    sharedPreferences.setInt("index", selectedIndex!);
    log("selectedIndex::$selectedIndex");
    notifyListeners();
  }

  /// Patches specific translation keys that have been renamed in-app but
  /// whose backend values may still return the old text.
  void _applyLabelOverrides(String langCode) {
    if (translations == null) return;
    switch (langCode) {
      case 'ar':
        translations!.requiredServicemen = 'كم العدد المطلوب';
        translations!.zipCode = 'رقم المبنى';
        break;
      case 'de':
        translations!.requiredServicemen = 'Benötigte Menge';
        translations!.zipCode = 'Gebäudenummer';
        break;
      default:
        translations!.requiredServicemen = 'Quantity Needed';
        translations!.zipCode = 'Building Number';
    }
  }
}
