// ignore_for_file: non_constant_identifier_names

import 'package:e_demand/app/generalImports.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthenticationRepository {
  static String? kPhoneNumber;
  static String? verificationId;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isLoggedIn => _auth.currentUser != null;

  Future verifyPhoneNumber(
    final String phoneNumber, {
    Function(dynamic err)? onError,
    VoidCallback? onCodeSent,
  }) async {
    kPhoneNumber = phoneNumber;
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
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
    required final String phoneNumber,
    required final String countryCode,
  }) async {
    kPhoneNumber = phoneNumber;
    final Map<String, dynamic> response = await ApiClient.post(
        url: ApiUrl.resendOTP,
        parameter: {
          ApiParam.mobile: "$countryCode$phoneNumber",
        },
        useAuthToken: false);

    return response;
  }

  static Future<UserDetailsModel> loginUser({
    required final String latitude,
    required final String longitude,
    final String? mobileNumber,
    final String? countryCode,
    required final String uid,
    final String? fcmId,
    required final LogInType loginType,
  }) async {
    try {
      final parameters = <String, dynamic>{
        ApiParam.countryCode: countryCode,
        ApiParam.uid: uid,
        ApiParam.mobile: mobileNumber,
        ApiParam.latitude: latitude,
        ApiParam.longitude: longitude,
        ApiParam.loginType: loginType.name.toString(),
      };
      if (fcmId != null) {
        parameters[ApiParam.fcmId] = fcmId;
        parameters[ApiParam.platform] = Platform.isAndroid ? "android" : "ios";
      }

      parameters.removeWhere((key, value) => value == null || value == "null");

      final Map<String, dynamic> result = await ApiClient.post(
          url: ApiUrl.manageUser, parameter: parameters, useAuthToken: false);

      final UserDetailsModel userDetailsModel =
          UserDetailsModel.fromMap(result["data"]);

      HiveRepository.setUserToken = result["token"];

      final Map<String, dynamic> map = userDetailsModel.toMap();

      final LocationPermission permisison = await Geolocator.checkPermission();

      if (permisison == LocationPermission.denied ||
          permisison == LocationPermission.deniedForever) {
        map.remove("latitude");
        map.remove("longitude");
      }

      await HiveRepository.putAllValue(
          boxName: HiveRepository.userDetailBoxKey, values: map);

      HiveRepository.setLatitude = latitude;
      HiveRepository.setLongitude = longitude;
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
            verificationId: verificationId!, smsCode: code);

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

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
    required final String mobileNumber,
    required final String countryCode,
    required final String otp,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.phone: mobileNumber,
        ApiParam.countryCode: countryCode,
        ApiParam.otp: otp,
      };

      final response = await ApiClient.post(
          parameter: parameter, url: ApiUrl.verifyOTP, useAuthToken: false);
      return {
        "error": response['error'],
        "message": response['message'],
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> isUserExists({
    final String? mobileNumber,
    final String? countryCode,
    required String uid,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.mobile: mobileNumber,
        ApiParam.countryCode: countryCode,
        ApiParam.uid: uid,
      };
      parameter.removeWhere(
        (key, value) => value == null || value == "null",
      );

      final response = await ApiClient.post(
          parameter: parameter, url: ApiUrl.verifyUser, useAuthToken: false);

      return {
        "error": response['error'],
        "message": response['message'],
        "status_code": response['message_code'],
        "authenticationType": response['authentication_mode']
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> deleteUserAccount() async {
    try {
      //delete account from Firebase
      await FirebaseAuth.instance.currentUser?.delete();

      //delete account from database
      final Map<String, dynamic> accountData = await ApiClient.post(
          url: ApiUrl.deleteUserAccount, parameter: {}, useAuthToken: true);

      return {"error": accountData['error'], "message": accountData['message']};
    } catch (e) {
      if (e.toString().contains('firebase_auth/requires-recent-login')) {
        return {"error": true, "message": "pleaseReLoginAgainToDeleteAccount"};
      }
      return {"error": true, "message": e.toString()};
    }
  }

  Future<UserDetailsModel> getUserDetails() async {
    try {
      final Map<String, dynamic> result = await ApiClient.post(
          url: ApiUrl.getUserDetails, parameter: {}, useAuthToken: true);

      final UserDetailsModel userDetailsModel =
          UserDetailsModel.fromMap(result["data"]);

      final Map<String, dynamic> map = userDetailsModel.toMap();

      final latitude = HiveRepository.getLatitude;
      final longitude = HiveRepository.getLongitude;

      await HiveRepository.putAllValue(
          boxName: HiveRepository.userDetailBoxKey, values: map);

      HiveRepository.setLatitude = latitude;
      HiveRepository.setLongitude = longitude;

      return userDetailsModel;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        return {
          "userDetails": null,
          "isError": true,
          "message": e.code.toString(),
        };
      } catch (e) {
        return {
          "userDetails": null,
          "isError": true,
          "message": e.toString(),
        };
      }
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
    } on FirebaseAuthException catch (e) {
      return {
        "userDetails": null,
        "isError": true,
        "message": e.code.toString(),
      };
    } catch (e) {
      return {
        "userDetails": null,
        "isError": true,
        "message": e.toString(),
      };
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
        ApiParam.fcmId: fcmId
      };
      final Map<String, dynamic> response = await ApiClient.post(
          url: ApiUrl.logout, parameter: parameters, useAuthToken: true);
      return response['error'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
