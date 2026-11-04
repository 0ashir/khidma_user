import 'package:e_demand/app/generalImports.dart';

abstract class DeleteHandymanReviewState {}

class DeleteHandymanReviewInitial extends DeleteHandymanReviewState {}

class DeleteHandymanReviewInProgress extends DeleteHandymanReviewState {}

class DeleteHandymanReviewSuccess extends DeleteHandymanReviewState {
  DeleteHandymanReviewSuccess(this.handymanId);

  final String handymanId;
}

class DeleteHandymanReviewFailure extends DeleteHandymanReviewState {
  DeleteHandymanReviewFailure(this.errorMessage);

  final String errorMessage;
}

class DeleteHandymanReviewCubit extends Cubit<DeleteHandymanReviewState> {
  DeleteHandymanReviewCubit() : super(DeleteHandymanReviewInitial());

  final HandymanReviewRepository _repository = HandymanReviewRepository();

  Future<void> deleteReview({
    required String ratingId,
    required String handymanId,
  }) async {
    try {
      emit(DeleteHandymanReviewInProgress());
      await _repository.deleteHandymanReview(ratingId: ratingId);
      emit(DeleteHandymanReviewSuccess(handymanId));
    } catch (e) {
      emit(DeleteHandymanReviewFailure(e.toString()));
    }
  }
}
