import 'package:e_demand/app/generalImports.dart';

abstract class CountrySettingsState {}

class CountrySettingsInitial extends CountrySettingsState {}

class CountrySettingsFetchInProgress extends CountrySettingsState {}

class CountrySettingsFetchSuccess extends CountrySettingsState {
  CountrySettingsFetchSuccess({required this.countrySettings});

  final CountrySettings countrySettings;
}

class CountrySettingsFetchFailure extends CountrySettingsState {
  CountrySettingsFetchFailure({required this.errorMessage});

  final String errorMessage;
}

class CountrySettingsCubit extends Cubit<CountrySettingsState> {
  CountrySettingsCubit(this.settingRepository)
    : super(CountrySettingsInitial());

  final SettingRepository settingRepository;
  int _latestRequest = 0;

  /// Fetches the settings for the given coordinates, defaulting to the
  /// customer's saved location.
  Future<void> fetchCountrySettings({
    final String? latitude,
    final String? longitude,
  }) async {
    if (isClosed) return;
    final request = ++_latestRequest;
    emit(CountrySettingsFetchInProgress());
    try {
      final CountrySettings settings = await settingRepository
          .getCountrySettings(
            latitude: latitude ?? HiveRepository.getLatitude ?? '',
            longitude: longitude ?? HiveRepository.getLongitude ?? '',
          );
      if (isClosed || request != _latestRequest) return;
      // formatDate / localeFormatTime / formatDateAndTime read this map.
      dateAndTimeSetting["dateFormat"] = settings.intlDateFormat;
      dateAndTimeSetting["use24HourFormat"] = settings.use24HourFormat;
      emit(CountrySettingsFetchSuccess(countrySettings: settings));
    } catch (e) {
      if (isClosed || request != _latestRequest) return;
      emit(CountrySettingsFetchFailure(errorMessage: e.toString()));
    }
  }

  CountrySettings? get countrySettings => state is CountrySettingsFetchSuccess
      ? (state as CountrySettingsFetchSuccess).countrySettings
      : null;
}
