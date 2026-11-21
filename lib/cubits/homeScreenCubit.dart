//Cubit
import 'package:e_demand/app/generalImports.dart';

class HomeScreenCubit extends Cubit<HomeScreenState> {
  HomeScreenCubit(this.homeScreenRepository, this.countrySettingsCubit)
    : super(HomeScreenInitial());
  final HomeScreenRepository homeScreenRepository;
  final CountrySettingsCubit countrySettingsCubit;

  /// Fingerprint of the data on screen; equal fresh data is not re-emitted,
  /// so an unchanged background refresh never rebuilds the page.
  String? _shownFingerprint;
  int _latestRequest = 0;

  ///This method is used to fetch Home screen data.
  ///
  /// Stale-while-revalidate: the last saved home data for this location shows
  /// at once, the server is asked in the background, and the page only
  /// updates when the response differs from what is on screen.
  Future<void> fetchHomeScreenData() async {
    final int request = ++_latestRequest;
    final String latitude = HiveRepository.getLatitude ?? "0.0";
    final String longitude = HiveRepository.getLongitude ?? "0.0";

    final HomeScreenResponse? cached = homeScreenRepository
        .cachedHomeScreenData(latitude: latitude, longitude: longitude);
    if (cached != null) {
      _show(cached);
    } else {
      _shownFingerprint = null;
      emit(HomeScreenDataFetchInProgress());
    }

    try {
      // Home data is (re)fetched whenever the location is set or changed, so
      // refresh the country currency alongside it — catalog and cart prices are
      // formatted with it. Fetched in parallel; it never throws (failure state).
      final results = await Future.wait<dynamic>([
        homeScreenRepository.fetchHomeScreenResponse(
          latitude: latitude,
          longitude: longitude,
        ),
        countrySettingsCubit.fetchCountrySettings(),
      ]);
      if (isClosed || request != _latestRequest) return;
      _show(results[0] as HomeScreenResponse);
    } catch (e) {
      if (isClosed || request != _latestRequest) return;
      // Offline / server error: keep the cached page instead of an error.
      if (cached != null) return;
      emit(HomeScreenDataFetchFailure(errorMessage: e.toString()));
    }
  }

  void _show(final HomeScreenResponse response) {
    if (state is HomeScreenDataFetchSuccess &&
        response.fingerprint == _shownFingerprint) {
      return;
    }
    _shownFingerprint = response.fingerprint;
    emit(HomeScreenDataFetchSuccess(homeScreenData: response.model));
  }
}

//State
abstract class HomeScreenState {}

class HomeScreenInitial extends HomeScreenState {}

class HomeScreenDataFetchInProgress extends HomeScreenState {}

class HomeScreenDataFetchSuccess extends HomeScreenState {
  HomeScreenDataFetchSuccess({required this.homeScreenData});
  final HomeScreenModel homeScreenData;
}

class HomeScreenDataFetchFailure extends HomeScreenState {
  HomeScreenDataFetchFailure({required this.errorMessage});
  final String errorMessage;
}
