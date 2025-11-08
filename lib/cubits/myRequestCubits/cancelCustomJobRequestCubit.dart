import 'package:e_demand/app/generalImports.dart';

abstract class CancelCustomJobRequestState {}

class CancelCustomJobRequestInitial extends CancelCustomJobRequestState {}

class CancelCustomJobRequestInProgress extends CancelCustomJobRequestState {}

class CancelCustomJobRequestSuccess extends CancelCustomJobRequestState {
  CancelCustomJobRequestSuccess({
    required this.response,
  });

  final String response;
}

class CancelCustomJobRequestFailure extends CancelCustomJobRequestState {
  CancelCustomJobRequestFailure({required this.errorMessage});

  final String errorMessage;
}

class CancelCustomJobRequestCubit extends Cubit<CancelCustomJobRequestState> {
  CancelCustomJobRequestCubit() : super(CancelCustomJobRequestInitial());

  Future<void> cancelBooking({required String customJobRequestId}) async {
    final MyRequestRepository myRequestRepository = MyRequestRepository();
    try {
      emit(CancelCustomJobRequestInProgress());
      final data = await myRequestRepository.cancelMyBooking(
        customJobRequestId: customJobRequestId,
      );
      emit(CancelCustomJobRequestSuccess(
        response: data['message'],
      ));
    } catch (e) {
      emit(CancelCustomJobRequestFailure(errorMessage: e.toString()));
    }
  }
}
