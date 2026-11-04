import 'package:e_demand/app/generalImports.dart';

abstract class SaveHandymanReviewState {}

class SaveHandymanReviewInitial extends SaveHandymanReviewState {}

class SaveHandymanReviewInProgress extends SaveHandymanReviewState {}

class SaveHandymanReviewSuccess extends SaveHandymanReviewState {
  SaveHandymanReviewSuccess(this.review);

  final HandymanReviewModel review;
}

class SaveHandymanReviewFailure extends SaveHandymanReviewState {
  SaveHandymanReviewFailure(this.errorMessage);

  final String errorMessage;
}

class SaveHandymanReviewCubit extends Cubit<SaveHandymanReviewState> {
  SaveHandymanReviewCubit() : super(SaveHandymanReviewInitial());

  final HandymanReviewRepository _repository = HandymanReviewRepository();

  Future<void> saveReview({
    String? ratingId,
    required String orderId,
    required String handymanId,
    required String rating,
    required String review,
    List<XFile?>? reviewImages,
    List<String>? deletedPastReviewImages,
  }) async {
    try {
      emit(SaveHandymanReviewInProgress());
      final response = await _repository.saveHandymanReview(
        ratingId: ratingId,
        orderId: orderId,
        handymanId: handymanId,
        rating: rating,
        review: review,
        reviewImages: reviewImages,
        deletedPastReviewImages: deletedPastReviewImages,
      );
      if (response['error'] == true) {
        emit(
          SaveHandymanReviewFailure(response['message']?.toString() ?? ''),
        );
      } else {
        emit(
          SaveHandymanReviewSuccess(
            HandymanReviewModel.fromJson(response['data']),
          ),
        );
      }
    } catch (e) {
      emit(SaveHandymanReviewFailure(e.toString()));
    }
  }
}
