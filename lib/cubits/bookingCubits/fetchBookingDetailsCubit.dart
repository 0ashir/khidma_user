import '../../../app/generalImports.dart';

abstract class FetchBookingDetailsState {}

class FetchBookingDetailsInitial extends FetchBookingDetailsState {}

class FetchBookingDetailsInProgress extends FetchBookingDetailsState {}

class FetchBookingDetailsSuccess extends FetchBookingDetailsState {
  final BookingDetailModel booking;

  FetchBookingDetailsSuccess({required this.booking});
}

class FetchBookingDetailsFailure extends FetchBookingDetailsState {
  final String errorMessage;

  FetchBookingDetailsFailure(this.errorMessage);
}

class FetchBookingDetailsCubit extends Cubit<FetchBookingDetailsState> {
  FetchBookingDetailsCubit() : super(FetchBookingDetailsInitial());
  final BookingRepository _bookingsRepository = BookingRepository();

  Future<void> fetchBookingDetails({
    required String bookingId,
  }) async {
    try {
      emit(FetchBookingDetailsInProgress());

      final booking = await _bookingsRepository.fetchBookingDetails(
        id: bookingId,
      );

      emit(FetchBookingDetailsSuccess(booking: booking));
    } catch (e) {
      emit(FetchBookingDetailsFailure(e.toString()));
    }
  }
}
