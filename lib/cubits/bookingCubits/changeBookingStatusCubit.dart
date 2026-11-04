import 'package:e_demand/app/generalImports.dart';

abstract class ChangeBookingStatusState {}

class UpdateBookingStatusInitial extends ChangeBookingStatusState {}

class ChangeBookingStatusInProgress extends ChangeBookingStatusState {
  final String pressedButtonName;
  final String bookingId;

  ChangeBookingStatusInProgress({
    required this.bookingId,
    required this.pressedButtonName,
  });
}

class ChangeBookingStatusSuccess extends ChangeBookingStatusState {
  ChangeBookingStatusSuccess({
    required this.error,
    required this.message,
    required this.bookingData,
  });

  final String message;
  final bool error;
  final BookingDetailModel bookingData;
}

class ChangeBookingStatusFailure extends ChangeBookingStatusState {
  ChangeBookingStatusFailure({required this.errorMessage});

  final dynamic errorMessage;
}

class ChangeBookingStatusCubit extends Cubit<ChangeBookingStatusState> {
  ChangeBookingStatusCubit({required this.bookingRepository})
    : super(UpdateBookingStatusInitial());
  BookingRepository bookingRepository = BookingRepository();

  Future<void> changeBookingStatus({
    required final String bookingStatus,
    required final String bookingId,
    required final String pressedButtonName,
    String? selectedDate,
    String? selectedTime,
    String? cancelReasonId,
    String? additionalInfo,
  }) async {
    emit(
      ChangeBookingStatusInProgress(
        pressedButtonName: pressedButtonName,
        bookingId: bookingId,
      ),
    );

    try {
      final value = await bookingRepository.changeBookingStatus(
        bookingId: bookingId,
        bookingStatus: bookingStatus,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        cancelReasonId: cancelReasonId,
        additionalInfo: additionalInfo,
      );

      final bool isError = value['error'] == true;

      if (isError) {
        _logBookingStatusEvent(
          bookingStatus: bookingStatus,
          bookingId: bookingId,
          pressedButtonName: pressedButtonName,
          result: 'error',
          additionalData: {'message': value['message']?.toString() ?? ''},
        );
        emit(
          ChangeBookingStatusFailure(
            errorMessage: value['message'] ?? 'Something went wrong',
          ),
        );
        return;
      }

      _logBookingStatusEvent(
        bookingStatus: bookingStatus,
        bookingId: bookingId,
        pressedButtonName: pressedButtonName,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
      );

      final BookingDetailModel refreshed = await bookingRepository
          .fetchBookingDetails(id: bookingId);

      emit(
        ChangeBookingStatusSuccess(
          bookingData: refreshed,
          error: false,
          message: value['message'] ?? '',
        ),
      );
    } catch (error) {
      emit(ChangeBookingStatusFailure(errorMessage: error.toString()));
    }
  }
}

void _logBookingStatusEvent({
  required String bookingId,
  required String bookingStatus,
  required String pressedButtonName,
  String? selectedDate,
  String? selectedTime,
  String result = 'success',
  Map<String, Object?> additionalData = const {},
}) {
  final status = bookingStatus.toLowerCase();
  final basePayload = {
    'booking_id': bookingId,
    'pressed_button': pressedButtonName,
    'result': result,
    'status': bookingStatus,
    ...additionalData,
  };

  switch (status) {
    case 'cancelled':
      ClarityService.logAction(ClarityActions.bookingCancelled, basePayload);
      break;
    case 'completed':
      ClarityService.logAction(ClarityActions.bookingCompleted, basePayload);
      break;
    case 'confirmed':
      ClarityService.logAction(ClarityActions.bookingConfirmed, basePayload);
      break;
    case 'rescheduled':
      ClarityService.logAction(ClarityActions.bookingRescheduled, {
        ...basePayload,
        'selected_date': selectedDate ?? '',
        'selected_time': selectedTime ?? '',
      });
      break;
    default:
      ClarityService.logAction(ClarityActions.bookingRequested, basePayload);
  }
}
