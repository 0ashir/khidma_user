//Cubit
import 'package:e_demand/app/generalImports.dart';

class HomeScreenCubit extends Cubit<HomeScreenState> {
  HomeScreenCubit(this.homeScreenRepository, this.countrySettingsCubit)
    : super(HomeScreenInitial());
  final HomeScreenRepository homeScreenRepository;
  final CountrySettingsCubit countrySettingsCubit;

  ///This method is used to fetch Home screen data
  Future<void> fetchHomeScreenData() async {
    try {
      emit(HomeScreenDataFetchInProgress());

      // Home data is (re)fetched whenever the location is set or changed, so
      // refresh the country currency alongside it — catalog and cart prices are
      // formatted with it. Fetched in parallel; it never throws (failure state).
      final results = await Future.wait<dynamic>([
        homeScreenRepository.fetchHomeScreenData(
          latitude: HiveRepository.getLatitude ?? "0.0",
          longitude: HiveRepository.getLongitude ?? "0.0",
        ),
        countrySettingsCubit.fetchCountrySettings(),
      ]);
      emit(HomeScreenDataFetchSuccess(homeScreenData: results[0]));
    } catch (e) {
      emit(HomeScreenDataFetchFailure(errorMessage: e.toString()));
    }
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
