import 'package:e_demand/app/generalImports.dart';

abstract class CancelCustomJobRequestState {}

class CancelCustomJobRequestInitial extends CancelCustomJobRequestState {}

class CancelCustomJobRequestInProgress extends CancelCustomJobRequestState {}

class CancelCustomJobRequestSuccess extends CancelCustomJobRequestState {
  CancelCustomJobRequestSuccess({
    required this.response,
    this.cancelReasonText,
  });

  final String response;
  final String? cancelReasonText;
}

class CancelCustomJobRequestFailure extends CancelCustomJobRequestState {
  CancelCustomJobRequestFailure({required this.errorMessage});

  final String errorMessage;
}

class CancelCustomJobRequestCubit extends Cubit<CancelCustomJobRequestState> {
  CancelCustomJobRequestCubit() : super(CancelCustomJobRequestInitial());

  Future<void> cancelBooking({
    required String customJobRequestId,
    String? cancelReasonId,
    String? cancelReasonText,
    String? additionalInfo,
  }) async {
    final MyRequestRepository myRequestRepository = MyRequestRepository();
    try {
      emit(CancelCustomJobRequestInProgress());
      final data = await myRequestRepository.cancelMyBooking(
        customJobRequestId: customJobRequestId,
        cancelReasonId: cancelReasonId,
        additionalInfo: additionalInfo,
      );
      ClarityService.logAction(ClarityActions.customJobRequestCancelled, {
        'custom_job_request_id': customJobRequestId,
        'message': data['message']?.toString() ?? '',
      });
      emit(
        CancelCustomJobRequestSuccess(
          response: data['message']?.toString() ?? '',
          cancelReasonText: cancelReasonText,
        ),
      );
    } catch (e) {
      ClarityService.logAction(ClarityActions.customJobRequestCancelled, {
        'custom_job_request_id': customJobRequestId,
        'status': 'error',
        'message': e.toString(),
      });
      emit(CancelCustomJobRequestFailure(errorMessage: e.toString()));
    }
  }
}
