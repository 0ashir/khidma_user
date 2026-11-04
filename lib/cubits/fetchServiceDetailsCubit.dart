import 'package:e_demand/app/generalImports.dart';

//state
abstract class ServiceDetailsState {}

class ServiceDetailsInitial extends ServiceDetailsState {}

class ServiceDetailsFetchInProgress extends ServiceDetailsState {}

class ServiceDetailsFetchSuccess extends ServiceDetailsState {
  ServiceDetailsFetchSuccess({required this.serviceDetails});

  final ServiceDetailsModel serviceDetails;
}

class ServiceDetailsFetchFailure extends ServiceDetailsState {
  ServiceDetailsFetchFailure({required this.errorMessage});

  final String errorMessage;
}

class ServiceDetailsCubit extends Cubit<ServiceDetailsState> {
  final ServiceRepository serviceRepository;

  ServiceDetailsCubit({required this.serviceRepository})
    : super(ServiceDetailsInitial());

  Future<void> fetchServiceDetails({
    final String? id,
    final String? slug,
  }) async {
    emit(ServiceDetailsFetchInProgress());
    await serviceRepository
        .getServiceDetails(id: id, slug: slug)
        .then(
          (final value) =>
              emit(ServiceDetailsFetchSuccess(serviceDetails: value)),
        )
        .catchError(
          (final e) =>
              emit(ServiceDetailsFetchFailure(errorMessage: e.toString())),
        );
  }
}
