import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/data/model/chat/reportReasonModel.dart';

abstract class FetchCancelReasonsState {}

class FetchCancelReasonsInitial extends FetchCancelReasonsState {}

class FetchCancelReasonsInProgress extends FetchCancelReasonsState {}

class FetchCancelReasonsSuccess extends FetchCancelReasonsState {
  final List<ReportReasonModel> reasons;
  FetchCancelReasonsSuccess({required this.reasons});
}

class FetchCancelReasonsFailure extends FetchCancelReasonsState {
  final String errorMessage;
  FetchCancelReasonsFailure({required this.errorMessage});
}

class FetchCancelReasonsCubit extends Cubit<FetchCancelReasonsState> {
  FetchCancelReasonsCubit({required this.bookingRepository})
      : super(FetchCancelReasonsInitial());

  final BookingRepository bookingRepository;

  Future<void> fetchCancelReasons() async {
    emit(FetchCancelReasonsInProgress());
    try {
      final reasons = await bookingRepository.getCancelReasons();
      emit(FetchCancelReasonsSuccess(reasons: reasons));
    } catch (e) {
      emit(FetchCancelReasonsFailure(errorMessage: e.toString()));
    }
  }
}
