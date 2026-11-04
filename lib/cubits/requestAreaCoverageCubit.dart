//State
import 'package:e_demand/app/generalImports.dart';

@immutable
abstract class RequestAreaCoverageState {}

class RequestAreaCoverageInitial extends RequestAreaCoverageState {}

class RequestAreaCoverageInProgress extends RequestAreaCoverageState {}

class RequestAreaCoverageSuccess extends RequestAreaCoverageState {
  RequestAreaCoverageSuccess({required this.message});

  final String message;
}

class RequestAreaCoverageFailure extends RequestAreaCoverageState {
  RequestAreaCoverageFailure({required this.errorMessage});

  final String errorMessage;
}

//Cubit
class RequestAreaCoverageCubit extends Cubit<RequestAreaCoverageState> {
  RequestAreaCoverageCubit({required this.providerRepository})
    : super(RequestAreaCoverageInitial());

  final ProviderRepository providerRepository;

  void requestAreaCoverage({
    required final String latitude,
    required final String longitude,
    required final String address,
    required final bool isAuthTokenRequired,
  }) {
    emit(RequestAreaCoverageInProgress());

    providerRepository
        .requestAreaCoverage(
          latitude: latitude,
          longitude: longitude,
          address: address,
          isAuthTokenRequired: isAuthTokenRequired,
        )
        .then((final value) {
          emit(RequestAreaCoverageSuccess(message: value['message']));
        })
        .catchError((final e) {
          emit(RequestAreaCoverageFailure(errorMessage: e.toString()));
        });
  }
}
