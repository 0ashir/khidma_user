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
    try {
      translations = Translation.defaultTranslations();
      await apiServices
          .getApi(api.systemLanguage, [], isToken: false)
          .then((value) {
        if (value.isSuccess!) {
          languageList.clear(); // Clear before adding
          for (var item in value.data) {
            SystemLanguage systemLanguage = SystemLanguage.fromJson(item);
            if (!languageList.contains(systemLanguage)) {
              languageList.add(systemLanguage);
            }
          }

          // ✅ Compare with saved locale and set selected index
          String? selectedLocaleCode =
              sharedPreferences.getString("selectedLocale") ?? "en";

          log("message=-=-==-=-=-=-=-=-$selectedLocaleCode");
          int index = languageList.indexWhere((element) =>
              element.appLocale?.split("_")[0] == selectedLocaleCode);
          if (index != -1) {
            selectedIndex = index;
            log("✅ Selected index set to $selectedIndex for locale $selectedLocaleCode");
          } else {
            selectedIndex = 0; // fallback
          }
        }
        notifyListeners();
      });
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
  void changeLocale(newLocale, context) {
    log('[Translation] changeLocale called → newLocale=$newLocale');
    Locale convertedLocale;

    currentLanguage = newLocale.name!;
    convertedLocale = Locale(
        newLocale.appLocale!.split("_")[0], newLocale.appLocale!.split("_")[1]);

    locale = convertedLocale;
    final langCode = locale!.languageCode.toString();
    sharedPreferences.setString('selectedLocale', langCode);
    env.local = langCode;
    log('[Translation] locale set to "$langCode" in SharedPreferences and env.local');
    GoogleTranslationService.clearCache();
    getLanguageTranslate(context, languageCode: langCode);
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
      translations = Translation.defaultTranslations();
      final response = await apiServices.getApi(
          "${api.translate}/${locale!.languageCode}", [],
          isToken: false, isData: true);

      if (response.isSuccess!) {
        isTranslateLoader = false;
        translations = Translation.fromJson(response.data);

        // Override labels whose text has been changed in-app
        // (backend translation endpoint may still return old values)
        _applyLabelOverrides(locale?.languageCode ?? 'en');

        log("Loaded translations: ${response.data}");
        notifyListeners();
      } else {
        isTranslateLoader = false;
        log('Failed to load translations, using defaults');
        translations = Translation.defaultTranslations();
        notifyListeners();
      }
    } catch (e, s) {
      isTranslateLoader = false;
      log('Error Translation: $e==$s');
      translations = Translation.defaultTranslations();
      notifyListeners();
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
        break;
      case 'de':
        translations!.requiredServicemen = 'Benötigte Menge';
        break;
      default:
        translations!.requiredServicemen = 'Quantity Needed';
    }
  }
}
