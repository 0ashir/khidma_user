//Cubit
import 'package:e_demand/app/generalImports.dart';

class ValidatePromocodeCubit extends Cubit<ValidatePromoCodeState> {
  ValidatePromocodeCubit({required this.cartRepository})
    : super(ValidatePromoCodeInitial());
  CartRepository cartRepository;

  Future<void> validatePromoCodes({
    required final String totalAmount,
    required final String promoCodeID,
    final String? providerId,
  }) async {
    emit(ValidatePromoCodeInProgress(promoCodeID: promoCodeID));

    try {
      final value = await cartRepository.validatePromocode(
        promocodeId: promoCodeID,
        totalAmount: totalAmount,
        providerId: providerId,
      );
      ClarityService.logAction(ClarityActions.promoCodeApplied);
      ClarityService.setTag('promo_code', promoCodeID);
      emit(
        ValidatePromoCodeSuccess(
          error: value['error'],
          message: value['message'],
          discountAmount: value['discountAmount'] ?? '0',
          totalOrderAmount: value['finalOrderAmount'] ?? totalAmount,
          promoCodeId: promoCodeID,
        ),
      );
    } on ApiException catch (e) {
      // The backend responds with error:true + a human-readable message for
      // ordinary rejections (min amount not met, expired, already used) —
      // ApiClient throws for every error:true, but this is not an
      // unexpected failure, so it's routed through the same Success(error:
      // true) path the UI already handles, not the generic Failure path.
      ClarityService.logAction(ClarityActions.promoCodeFailed, {
        'promo_code_id': promoCodeID,
      });
      emit(
        ValidatePromoCodeSuccess(
          error: true,
          message: e.errorMessage,
          discountAmount: '0',
          totalOrderAmount: totalAmount,
          promoCodeId: promoCodeID,
        ),
      );
    } catch (e) {
      ClarityService.logAction(ClarityActions.promoCodeFailed, {
        'promo_code_id': promoCodeID,
      });
      emit(ValidatePromoCodeFailure(errorMessage: e.toString()));
    }
  }
}

//State

abstract class ValidatePromoCodeState {}

class ValidatePromoCodeInitial extends ValidatePromoCodeState {}

class ValidatePromoCodeInProgress extends ValidatePromoCodeState {
  ValidatePromoCodeInProgress({required this.promoCodeID});
  final String promoCodeID;
}

class ValidatePromoCodeSuccess extends ValidatePromoCodeState {
  ValidatePromoCodeSuccess({
    required this.error,
    required this.message,
    required this.totalOrderAmount,
    required this.discountAmount,
    required this.promoCodeId,
  });
  final bool error;
  final String message;
  final String totalOrderAmount;
  final String discountAmount;
  final String promoCodeId;
}

class ValidatePromoCodeFailure extends ValidatePromoCodeState {
  ValidatePromoCodeFailure({required this.errorMessage});
  final String errorMessage;
}
