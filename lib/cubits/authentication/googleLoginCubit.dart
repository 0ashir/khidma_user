import 'package:e_demand/app/generalImports.dart';

abstract class GoogleLoginState {}

class GoogleLoginInitialState extends GoogleLoginState {}

class GoogleLoginInProgressState extends GoogleLoginState {}

class GoogleLoginSuccessState extends GoogleLoginState {
  final User? userDetails;
  final String message;

  GoogleLoginSuccessState({
    required this.message,
    this.userDetails,
  });
}

class GoogleLoginFailureState extends GoogleLoginState {
  String errorMessage;

  GoogleLoginFailureState({required this.errorMessage});
}

class GoogleLoginCubit extends Cubit<GoogleLoginState> {
  GoogleLoginCubit() : super(GoogleLoginInitialState());
  AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();

  Future<void> loginWithGoogle() async {
  debugPrint("[GoogleLogin] Starting loginWithGoogle");
  emit(GoogleLoginInProgressState());
  try {
    debugPrint("[GoogleLogin] Calling _authenticationRepository.signInWithGoogle()");

    final Map<String, dynamic> response =
        await _authenticationRepository.signInWithGoogle();

    debugPrint("[GoogleLogin] Response received: $response");

    if (!response["isError"]) {
      debugPrint("[GoogleLogin] Login successful, parsing userDetails");

      final userDetails = response["userDetails"] as User?;
      debugPrint("[GoogleLogin] userDetails: $userDetails");

      emit(
        GoogleLoginSuccessState(
          message: response["message"],
          userDetails: userDetails,
        ),
      );
      debugPrint("[GoogleLogin] Emitted GoogleLoginSuccessState");

      await FirebaseAnalytics.instance.logLogin(
        loginMethod: 'signInWithGoogle',
      );
      debugPrint("[GoogleLogin] Firebase Analytics login logged");
    } else {
      debugPrint("[GoogleLogin] Login failed: ${response["message"]}");
      emit(GoogleLoginFailureState(errorMessage: response["message"]));
    }
  } catch (e, stackTrace) {
    debugPrint("[GoogleLogin] Exception caught: $e");
    debugPrint("[GoogleLogin] StackTrace: $stackTrace");

    emit(
      GoogleLoginFailureState(errorMessage: e.toString()),
    );
  }
}

}
