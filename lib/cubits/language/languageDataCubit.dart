import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:e_demand/app/generalImports.dart';

abstract class LanguageDataState {}

class LanguageDataInitial extends LanguageDataState {}

class GetLanguageDataInProgress extends LanguageDataState {}

class GetLanguageDataSuccess extends LanguageDataState {
  final dynamic jsonData;
  final AppLanguage currentLanguage;

  GetLanguageDataSuccess(
      {required this.jsonData, required this.currentLanguage});
}

class GetLanguageDataError extends LanguageDataState {
  final dynamic error;

  GetLanguageDataError(this.error);
}

class LanguageDataCubit extends Cubit<LanguageDataState> {
  LanguageDataCubit() : super(LanguageDataInitial());

  /// Load English language data from local assets as fallback
  Future<Map<String, dynamic>> _loadFallbackEnglishData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/languages/en.json');
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // Return empty map if even local file fails to load
      return {};
    }
  }

  /// Creates fallback English language object
  AppLanguage _createFallbackEnglishLanguage() {
    return const AppLanguage(
      id: 'en_fallback',
      languageCode: 'en',
      languageName: 'English',
      imageURL: 'assets/images/english-au.svg',
      isRtl: '0',
      isDefault: true,
    );
  }

  Future<void> getLanguageData({required AppLanguage languageData}) async {
    try {
      emit(GetLanguageDataInProgress());
      final jsonData = await SettingRepository()
          .getLanguageJsonData(languageData.languageCode);

      // Check if data is empty
      if (jsonData.isEmpty) {
        // Use fallback English from local assets
        final fallbackData = await _loadFallbackEnglishData();
        final fallbackLanguage = _createFallbackEnglishLanguage();
        emit(GetLanguageDataSuccess(
            jsonData: fallbackData, currentLanguage: fallbackLanguage));
      } else {
        emit(GetLanguageDataSuccess(
            jsonData: jsonData, currentLanguage: languageData));
      }
    } catch (e) {
      // On error, load English language data from local assets
      final fallbackData = await _loadFallbackEnglishData();
      final fallbackLanguage = _createFallbackEnglishLanguage();
      emit(GetLanguageDataSuccess(
          jsonData: fallbackData, currentLanguage: fallbackLanguage));
    }
  }

  Future<void> setLanguageData(
      {required AppLanguage languageData, required dynamic jsonData}) async {
    emit(GetLanguageDataSuccess(
        jsonData: jsonData, currentLanguage: languageData));
  }
}
