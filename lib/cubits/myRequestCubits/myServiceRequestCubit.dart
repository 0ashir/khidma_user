import 'package:e_demand/app/generalImports.dart';

abstract class MyRequestState {}

class MyRequestInitial extends MyRequestState {}

class MyRequestLoading extends MyRequestState {}

class MyRequestFailure extends MyRequestState {
  final String errorMessage;
  MyRequestFailure(this.errorMessage);
}

class MyRequestSSuccess extends MyRequestState {
  MyRequestSSuccess(this.response);
  final Map<String, dynamic> response;
}

class MyRequestCubit extends Cubit<MyRequestState> {
  MyRequestCubit() : super(MyRequestInitial());
  final MyRequestRepository _myRequestRepository = MyRequestRepository();

  Future<void> submitCustomJobRequest({
    required Map<String, dynamic> parameters,
  }) async {
    emit(MyRequestLoading());
    try {
      emit(MyRequestLoading());
      final result = await _myRequestRepository.submitCustomJobRequest(
        parameters: parameters,
      );

      if (result['error'] == false) {
        emit(MyRequestSSuccess(result));
      } else {
        emit(MyRequestFailure(result['message'].toString()));
      }
    } catch (e) {
      emit(MyRequestFailure(e.toString()));
    }
  }
}
