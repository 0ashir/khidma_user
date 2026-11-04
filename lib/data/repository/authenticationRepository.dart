// ignore_for_file: non_constant_identifier_names

import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/screens/map/utils/map_utils.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthenticationRepository {
  static String? verificationId;
  static String? _loginProof;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isLoggedIn => _auth.currentUser != null;

  Future verifyPhoneNumber(
    final String phoneNumber, {
    Function(dynamic err)? onError,
    VoidCallback? onCodeSent,
  }) async {
    // Firebase needs E.164; the backend returns calling codes without "+".
    final String digits = phoneNumber.replaceAll(RegExp('[^0-9]'), '');
    await _auth.verifyPhoneNumber(
      phoneNumber: '+$digits',
      verificationCompleted: (final PhoneAuthCredential complete) {},
      verificationFailed: (final FirebaseAuthException err) {
        onError?.call(err);
      },
      codeSent: (final String verification, final int? forceResendingToken) {
        verificationId = verification;
        // this is force resending token
        HiveRepository.setResendToken = forceResendingToken;

        if (onCodeSent != null) {
          onCodeSent();
        }
      },
      forceResendingToken: HiveRepository.getResendToken,
      codeAutoRetrievalTimeout: (final String timeout) {},
    );
  }

  Future resendOTPUsingSMSGateway({
    final String? phoneNumber,
    final String? countryCode,
    final String? email,
  }) async {
    final Map<String, dynamic> parameter = <String, dynamic>{};

    if (email != null && email.isNotEmpty) {
      // Email OTP
      parameter[ApiParam.email] = email;
    } else if (phoneNumber != null && countryCode != null) {
      // Phone OTP
      parameter[ApiParam.countryCode] = countryCode;
      parameter[ApiParam.mobile] = phoneNumber;
    }

    final Map<String, dynamic> response = await ApiClient.post(
      url: ApiUrl.resendOTP,
      parameter: parameter,
      useAuthToken: false,
    );

    return response;
  }

  static Future<UserDetailsModel> loginUser({
    final String? userName,
    required final String latitude,
    required final String longitude,
    final String? mobileNumber,
    final String? countryCode,
    required final String uid,
    final String? fcmId,
    required final LogInType loginType,
    final String? email,
    final String? password,
  }) async {
    try {
      final parameters = <String, dynamic>{
        ApiParam.username: userName,
        ApiParam.countryCode: countryCode,
        ApiParam.uid: uid,
        ApiParam.mobile: mobileNumber,
        ApiParam.email: email,
        ApiParam.password: password,
        ApiParam.latitude: latitude,
        ApiParam.longitude: longitude,
        ApiParam.loginType: loginType.apiValue,
      };
      parameters['firebase_id_token'] = await FirebaseAuth.instance.currentUser?.getIdToken();
      parameters['login_proof'] = _loginProof;
      if (fcmId != null) {
        parameters[ApiParam.fcmId] = fcmId;
        parameters[ApiParam.platform] = Platform.isAndroid ? "android" : "ios";
      }

      // Add language_code parameter
      final currentLanguage = HiveRepository.getCurrentLanguage();
      if (currentLanguage != null && currentLanguage.languageCode.isNotEmpty) {
        parameters[ApiParam.languageCode] = currentLanguage.languageCode;
      }

      parameters.removeWhere((key, value) => value == null || value == "null");

      final Map<String, dynamic> result = await ApiClient.post(
        url: ApiUrl.manageUser,
        parameter: parameters,
        useAuthToken: false,
      );

      final UserDetailsModel userDetailsModel = UserDetailsModel.fromMap(
        result["data"],
      );

      HiveRepository.setUserToken = result["token"];

      final Map<String, dynamic> map = userDetailsModel.toMap();

      final LocationPermission permisison = await Geolocator.checkPermission();

      if (permisison == LocationPermission.denied ||
          permisison == LocationPermission.deniedForever) {
        map.remove("latitude");
        map.remove("longitude");
      }

      await HiveRepository.putAllValue(
        boxName: HiveRepository.userDetailBoxKey,
        values: map,
      );

      HiveRepository.setLatitude = latitude;
      HiveRepository.setLongitude = longitude;

      final newAddress = await MapUtils.createAddressFromCoordinates(
        double.tryParse(latitude) ?? 0.0,
        double.tryParse(longitude) ?? 0.0,
      );
      HiveRepository.setLocationName = newAddress['lineOneAddress'];
      HiveRepository.setLocationArea = newAddress['lineTwoAddress'];
      return userDetailsModel;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<UserCredential> verifyOtpUsingFirebase({
    required final String code,
  }) async {
    try {
      if (verificationId != null) {
        final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId!,
          smsCode: code,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );

        return userCredential;
      }
      throw ApiException("somethingWentWrong");
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> verifyOTPUsingSMSGateway({
    final String? mobileNumber,
    final String? countryCode,
    final String? email,
    required final String otp,
    bool passwordUpdate = false,
    required final LogInType loginType,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.otp: otp,
        ApiParam.loginType: loginType.apiValue,
      };

      // Add email or mobile number
      if (email != null && email.isNotEmpty) {
        parameter[ApiParam.email] = email;
      } else if (mobileNumber != null && countryCode != null) {
        parameter[ApiParam.phone] = mobileNumber;
        parameter[ApiParam.countryCode] = countryCode;
      }

      // Add password_update parameter if true
      if (passwordUpdate) {
        parameter[ApiParam.passwordUpdate] = '1';
      }

      final response = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.verifyOTP,
        useAuthToken: false,
      );
      _loginProof = response['error'] == false ? response['login_proof'] as String? : null;
      return {
        "error": response['error'],
        "message": response['message'],
        "reset_token": response['reset_token'],
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> isUserExists({
    final String? mobileNumber,
    final String? countryCode,
    final String? email,
    required String uid,
    bool isForForgotPassword = false,
    required final LogInType loginType,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.mobile: mobileNumber,
        ApiParam.countryCode: countryCode,
        ApiParam.email: email,
        ApiParam.uid: uid,
        ApiParam.passwordUpdate: isForForgotPassword ? '1' : '0',
        ApiParam.loginType: loginType.apiValue,
      };
      parameter.removeWhere((key, value) => value == null || value == "null");

      final response = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.verifyUser,
        useAuthToken: false,
      );

      return {
        "error": response['error'],
        "message": response['message'],
        "status_code": response['message_code'],
        "authenticationType": response['authentication_mode'],
        "has_password": response['has_password'],
        "data": response['data'],
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> deleteUserAccount({String? password}) async {
    try {
      //delete account from Firebase
      await FirebaseAuth.instance.currentUser?.delete();

      //delete account from database
      final Map<String, dynamic> accountData = await ApiClient.post(
        url: ApiUrl.deleteUserAccount,
        parameter: {
          if (password != null && password.isNotEmpty)
            ApiParam.password: password,
        },
        useAuthToken: true,
      );

      return {"error": accountData['error'], "message": accountData['message']};
    } catch (e) {
      if (e.toString().contains('firebase_auth/requires-recent-login')) {
        return {
          "error": true,
          "message": "pleaseReLoginAgainToDeleteAccount".translate(
            context: UiUtils.rootNavigatorKey.currentContext!,
          ),
        };
      }
      return {"error": true, "message": e.toString()};
    }
  }

  Future<UserDetailsModel> getUserDetails() async {
    try {
      final Map<String, dynamic> result = await ApiClient.post(
        url: ApiUrl.getUserDetails,
        parameter: {},
        useAuthToken: true,
      );

      final UserDetailsModel userDetailsModel = UserDetailsModel.fromMap(
        result["data"],
      );

      final Map<String, dynamic> map = userDetailsModel.toMap();

      final latitude = HiveRepository.getLatitude;
      final longitude = HiveRepository.getLongitude;

      await HiveRepository.putAllValue(
        boxName: HiveRepository.userDetailBoxKey,
        values: map,
      );

      HiveRepository.setLatitude = latitude;
      HiveRepository.setLongitude = longitude;

      final newAddress = await MapUtils.createAddressFromCoordinates(
        double.tryParse(latitude ?? "") ?? 0.0,
        double.tryParse(longitude ?? "") ?? 0.0,
      );
      HiveRepository.setLocationName = newAddress['lineOneAddress'];
      HiveRepository.setLocationArea = newAddress['lineTwoAddress'];

      return userDetailsModel;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  static bool _isGoogleSignInInitialized = false;

  Future<Map<String, dynamic>> signInWithGoogle() async {
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn.instance;

    final GoogleSignInAccount googleSignInAccount;
    try {
      if (!_isGoogleSignInInitialized) {
        await googleSignIn.initialize();
        _isGoogleSignInInitialized = true;
      }
      await googleSignIn.signOut();
      googleSignInAccount = await googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      // user dismissed the sheet: same as before, not an error
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return {
          "userDetails": null,
          "isError": false,
          "message": "userLoggedInSuccessfully",
        };
      }
      return {"userDetails": null, "isError": true, "message": e.code.name};
    } catch (e) {
      return {"userDetails": null, "isError": true, "message": e.toString()};
    }

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAccount.authentication.idToken,
    );

    try {
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      return {
        "userDetails": null,
        "isError": true,
        "message": e.code.toString(),
      };
    } catch (e) {
      return {"userDetails": null, "isError": true, "message": e.toString()};
    }

    return {
      "userDetails": user,
      "isError": false,
      "message": "userLoggedInSuccessfully",
    };
  }

  Future<Map<String, dynamic>> signInWithApple() async {
    UserCredential userCredential;

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // nonce: nonce,
      );

      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      userCredential = await _auth.signInWithCredential(oAuthCredential);

      if (userCredential.additionalUserInfo!.isNewUser) {
        final user = userCredential.user!;
        String displayName = '';
        if (userCredential.user!.displayName?.trim().isEmpty ?? true) {
          if (userCredential.additionalUserInfo?.username?.trim().isNotEmpty ??
              false) {
            displayName = userCredential.additionalUserInfo?.username ?? '';
          } else {
            final givenName = credential.givenName ?? '';
            final familyName = credential.familyName ?? '';
            displayName = '$givenName $familyName';
          }
        } else {
          displayName = userCredential.user!.displayName!;
        }
        await user.updateDisplayName(displayName);
        await user.reload();
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      // Handle user cancellation and show custom message
      if (e.code == AuthorizationErrorCode.canceled) {
        return {
          "userDetails": null,
          "isError": true,
          // Custom key to translate in UI
          "message": "appleLoginCancelledByUser".translate(
            context: UiUtils.rootNavigatorKey.currentContext!,
          ),
        };
      }

      // Other Apple-specific errors
      return {"userDetails": null, "isError": true, "message": e.code.name};
    } on FirebaseAuthException catch (e) {
      return {
        "userDetails": null,
        "isError": true,
        "message": e.code.toString(),
      };
    } catch (e) {
      return {"userDetails": null, "isError": true, "message": e.toString()};
    }

    return {
      "userDetails": FirebaseAuth.instance.currentUser,
      "isError": false,
      "message": "userLoggedInSuccessfully",
    };
  }

  Future<bool> logoutUser({required String? fcmId}) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        ApiParam.fcmId: fcmId,
      };
      final Map<String, dynamic> response = await ApiClient.post(
        url: ApiUrl.logout,
        parameter: parameters,
        useAuthToken: true,
      );
      return response['error'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Password Authentication Methods

  Future<Map<String, dynamic>> changePassword({
    String? currentPassword,
    required final String newPassword,
    required final LogInType loginType,
    String? resetToken,
    String? phoneNumber,
    String? countryCode,
  }) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        ApiParam.newPassword: newPassword,
        ApiParam.confirmPassword: newPassword,
        ApiParam.loginType: loginType.apiValue,
      };

      // For logged-in users changing password
      if (currentPassword != null) {
        parameters[ApiParam.oldPassword] = currentPassword;
      }

      // For forgot password or first-time password set with SMS gateway (has reset_token)
      if (resetToken != null) {
        parameters[ApiParam.resetToken] = resetToken;
      }

      parameters['firebase_id_token'] = await FirebaseAuth.instance.currentUser?.getIdToken();

      // For Firebase authentication - send phone number and country code instead of reset_token
      if (phoneNumber != null && countryCode != null) {
        parameters[ApiParam.mobile] = phoneNumber;
        parameters[ApiParam.countryCode] = countryCode;
      }

      final Map<String, dynamic> result = await ApiClient.post(
        url: ApiUrl.changePassword,
        parameter: parameters,
        useAuthToken: currentPassword != null,
      );

      return {"error": result['error'], "message": result['message']};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
