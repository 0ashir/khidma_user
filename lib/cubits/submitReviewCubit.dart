import 'package:e_demand/app/generalImports.dart';

abstract class SubmitReviewState {}

class SubmitReviewInitial extends SubmitReviewState {}

class SubmitReviewInProgress extends SubmitReviewState {}

class SubmitReviewSuccess extends SubmitReviewState {
  SubmitReviewSuccess(
      {required this.message, required this.error, required this.data});

  final String message;
  final bool error;
  Map<String, dynamic> data;
}

class SubmitReviewFailure extends SubmitReviewState {
  SubmitReviewFailure({required this.errorMessage});

  final dynamic errorMessage;
}

class SubmitReviewCubit extends Cubit<SubmitReviewState> {
  SubmitReviewCubit({required this.bookingRepository})
      : super(SubmitReviewInitial());
  BookingRepository bookingRepository = BookingRepository();

  Future<void> submitReview({
    required final String serviceId,
    required final String ratingStar,
    required final String reviewComment,
    final String? customJobRequestId,
    final List<XFile?>? reviewImages,
    final List<String>? deletedPastReviewImages,
  }) async {
    try {
      emit(SubmitReviewInProgress());
      await bookingRepository
          .submitReviewToService(
        serviceId: serviceId,
        ratingStar: ratingStar,
        reviewComment: reviewComment,
        reviewImages: reviewImages,
        customJobRequestId: customJobRequestId,
        deletedPastReviewImages: deletedPastReviewImages,
      )
          .then((final value) async {
        if (value['error'] == true) {
          emit(SubmitReviewFailure(errorMessage: value['message']));
        } else {
          //emit success state
          emit(SubmitReviewSuccess(
            message: value['message'],
            error: value['error'],
            data: value["data"] ?? {},
          ));
        }
      });
    } catch (e) {
      emit(SubmitReviewFailure(errorMessage: e.toString()));
    }
  }
}
