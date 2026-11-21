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

  /// Coordinates the current settings belong to.
  String? _settingsLocation;

  /// Fetches the settings for the given coordinates, defaulting to the
  /// customer's saved location.
  Future<void> fetchCountrySettings({
    final String? latitude,
    final String? longitude,
  }) async {
    if (isClosed) return;
    final request = ++_latestRequest;
    final String lat = latitude ?? HiveRepository.getLatitude ?? '';
    final String lng = longitude ?? HiveRepository.getLongitude ?? '';
    // Prices are formatted with these settings, so never drop to "no
    // settings" while refreshing: keep the current ones, or show the last
    // saved ones for this location until the fresh ones arrive.
    final String location = '$lat,$lng';
    final bool sameLocation = location == _settingsLocation;
    if (state is! CountrySettingsFetchSuccess || !sameLocation) {
      _settingsLocation = location;
      final CountrySettings? cached = settingRepository.cachedCountrySettings(
        latitude: lat,
        longitude: lng,
      );
      if (cached != null) {
        _apply(cached);
      } else {
        emit(CountrySettingsFetchInProgress());
      }
    }
    try {
      final CountrySettings settings = await settingRepository
          .getCountrySettings(latitude: lat, longitude: lng);
      if (isClosed || request != _latestRequest) return;
      _apply(settings);
    } catch (e) {
      if (isClosed || request != _latestRequest) return;
      // A failed refresh keeps the settings already in use for this place.
      if (state is CountrySettingsFetchSuccess &&
          _settingsLocation == '$lat,$lng') {
        return;
      }
      emit(CountrySettingsFetchFailure(errorMessage: e.toString()));
    }
  }

  void _apply(final CountrySettings settings) {
    // formatDate / localeFormatTime / formatDateAndTime read this map.
    dateAndTimeSetting["dateFormat"] = settings.intlDateFormat;
    dateAndTimeSetting["use24HourFormat"] = settings.use24HourFormat;
    emit(CountrySettingsFetchSuccess(countrySettings: settings));
  }

  CountrySettings? get countrySettings => state is CountrySettingsFetchSuccess
      ? (state as CountrySettingsFetchSuccess).countrySettings
      : null;
}
