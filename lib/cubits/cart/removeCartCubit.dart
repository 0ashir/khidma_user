import 'package:e_demand/app/generalImports.dart';

@immutable
abstract class RemoveCartState {}

class RemoveCartInitial extends RemoveCartState {}

class RemoveCartInProgress extends RemoveCartState {}

class RemoveCartSuccess extends RemoveCartState {
  RemoveCartSuccess(
      {required this.error,
      required this.cartDetails,
      required this.successMessage});

  final String successMessage;
  final Cart? cartDetails;
  final bool error;
}

class RemoveCartFailure extends RemoveCartState {
  RemoveCartFailure({required this.errorMessage});

  final String errorMessage;
}

class RemoveCartCubit extends Cubit<RemoveCartState> {
  RemoveCartCubit() : super(RemoveCartInitial());
  CartRepository cartRepository = CartRepository();

  Future<void> removeCart({required final String providerId}) async {
    try {
      emit(RemoveCartInProgress());

      await cartRepository
          .removeCart(useAuthToken: true, providerId: providerId)
          .then((final value) {
        emit(
          RemoveCartSuccess(
            error: value["error"],
            successMessage: value['message'],
            cartDetails: value['cartData'],
          ),
        );
      }).catchError((final onError) {
        emit(RemoveCartFailure(errorMessage: onError.toString()));
      });
    } catch (e) {
      emit(RemoveCartFailure(errorMessage: e.toString()));
    }
  }
}
