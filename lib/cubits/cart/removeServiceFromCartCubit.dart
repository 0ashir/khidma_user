import 'package:e_demand/app/generalImports.dart';

@immutable
abstract class RemoveServiceFromCartState {}

class RemoveServiceFromCartInitial extends RemoveServiceFromCartState {}

class RemoveServiceFromCartInProgress extends RemoveServiceFromCartState {}

class RemoveServiceFromCartSuccess extends RemoveServiceFromCartState {
  RemoveServiceFromCartSuccess({
    required this.error,
    required this.cartDetails,
    required this.successMessage,
  });

  final String successMessage;
  final Cart? cartDetails;
  final bool error;
}

class RemoveServiceFromCartFailure extends RemoveServiceFromCartState {
  RemoveServiceFromCartFailure({required this.errorMessage});

  final String errorMessage;
}

class RemoveServiceFromCartCubit extends Cubit<RemoveServiceFromCartState> {
  RemoveServiceFromCartCubit(this.cartRepository)
    : super(RemoveServiceFromCartInitial());
  CartRepository cartRepository;

  Future<void> removeServiceFromCart({
    required final int serviceId,
    required final String providerId,
  }) async {
    try {
      emit(RemoveServiceFromCartInProgress());

      await cartRepository
          .removeServiceFromCart(
            useAuthToken: true,
            serviceId: serviceId,
            providerId: providerId,
          )
          .then((final value) {
            if (!(value['error'] as bool)) {
              ClarityService.logAction(ClarityActions.cartItemRemoved, {
                'service_id': serviceId,
                'provider_id': providerId,
              });
            }
            emit(
              RemoveServiceFromCartSuccess(
                error: value["error"],
                successMessage: value['message'],
                cartDetails: value['cartData'],
              ),
            );
          })
          .catchError((final onError) {
            ClarityService.logAction(ClarityActions.cartItemRemoved, {
              'service_id': serviceId,
              'result': 'error',
              'message': onError.toString(),
            });
            emit(
              RemoveServiceFromCartFailure(errorMessage: onError.toString()),
            );
          });
    } catch (e) {
      ClarityService.logAction(ClarityActions.cartItemRemoved, {
        'service_id': serviceId,
        'result': 'error',
        'message': e.toString(),
      });
      emit(RemoveServiceFromCartFailure(errorMessage: e.toString()));
    }
  }
}
