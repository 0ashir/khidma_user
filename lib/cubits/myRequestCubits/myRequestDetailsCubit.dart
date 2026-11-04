import 'package:e_demand/app/generalImports.dart';

abstract class MyRequestDetailsState {}

class MyRequestDetailsInitial extends MyRequestDetailsState {}

class MyRequestDetailsInProgress extends MyRequestDetailsState {}

class MyRequestDetailsSuccess extends MyRequestDetailsState {
  MyRequestDetailsSuccess({
    required this.requestCustomJob,
    this.bidders = const [],
    this.selectedSortBy,
    this.isSortingBidders = false,
  });

  final CustomJob requestCustomJob;
  final List<BidProvider> bidders;
  final String? selectedSortBy;
  final bool isSortingBidders;

  MyRequestDetailsSuccess copyWith({
    final CustomJob? requestCustomJob,
    final List<BidProvider>? bidders,
    final String? selectedSortBy,
    final bool? isSortingBidders,
  }) => MyRequestDetailsSuccess(
    requestCustomJob: requestCustomJob ?? this.requestCustomJob,
    bidders: bidders ?? this.bidders,
    selectedSortBy: selectedSortBy ?? this.selectedSortBy,
    isSortingBidders: isSortingBidders ?? this.isSortingBidders,
  );
}

class MyRequestDetailsFailure extends MyRequestDetailsState {
  MyRequestDetailsFailure({required this.errorMessage});

  final String errorMessage;
}

class MyRequestDetailsCubit extends Cubit<MyRequestDetailsState> {
  MyRequestDetailsCubit() : super(MyRequestDetailsInitial());

  Future<void> fetchRequestDetails({
    required String customJobRequestId,
    String? sortBy,
  }) async {
    final MyRequestRepository myRequestRepository = MyRequestRepository();
    try {
      emit(MyRequestDetailsInProgress());
      // Fetch both details and providers in parallel
      final results = await Future.wait([
        myRequestRepository.fetchCustomJobRequestDetails(
          id: customJobRequestId,
        ),
        myRequestRepository
            .fetchCustomJobRequestProviders(
              customJobRequestId: customJobRequestId,
              sortBy: sortBy,
            )
            .catchError((_) => <BidProvider>[]),
      ]);
      emit(
        MyRequestDetailsSuccess(
          requestCustomJob: results[0] as CustomJob,
          bidders: results[1] as List<BidProvider>,
          selectedSortBy: sortBy,
        ),
      );
    } catch (e) {
      emit(MyRequestDetailsFailure(errorMessage: e.toString()));
    }
  }

  Future<void> sortBidders({
    required String customJobRequestId,
    required String sortBy,
  }) async {
    if (state is! MyRequestDetailsSuccess) return;
    final currentState = state as MyRequestDetailsSuccess;
    emit(currentState.copyWith(isSortingBidders: true, selectedSortBy: sortBy));
    try {
      final providers = await MyRequestRepository()
          .fetchCustomJobRequestProviders(
            customJobRequestId: customJobRequestId,
            sortBy: sortBy,
          );
      emit(
        currentState.copyWith(
          bidders: providers,
          selectedSortBy: sortBy,
          isSortingBidders: false,
        ),
      );
    } catch (_) {
      emit(currentState.copyWith(isSortingBidders: false));
    }
  }

  void markCancelled({String? cancelReason}) {
    if (state is! MyRequestDetailsSuccess) return;
    final currentState = state as MyRequestDetailsSuccess;
    final updatedJob = currentState.requestCustomJob
      ..status = 'cancelled'
      ..cancelReason = cancelReason;
    emit(currentState.copyWith(requestCustomJob: updatedJob));
  }
}
