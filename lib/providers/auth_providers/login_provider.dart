import 'dart:convert';
import 'dart:developer';
import 'package:fixit_user/services/environment.dart';
import 'package:flutter/cupertino.dart';
import 'package:fixit_user/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginProvider with ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  SharedPreferences? pref;
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  bool isPassword = true;

  onLogin(context) {
    FocusManager.instance.primaryFocus?.unfocus();
    /*  route.pushReplacementNamed(context, routeName.dashboard);*/
    // if (formKey.currentState!.validate()) {
    login(context);
    // }
  }

  demoCreds() {
    emailController.text = "user@example.com";
    passwordController.text = "123456789";
    notifyListeners();
  }

  // password see tap
  passwordSeenTap() {
    isPassword = !isPassword;
    notifyListeners();
  }

  // SignIn With Google Method
  Future signInWithGoogle(context) async {
    try {
      showLoading(context);

      final googleSignIn = GoogleSignIn.instance;

      // Optional: if you need to set clientId/serverClientId do it once at app startup:
      await googleSignIn.initialize(

      );

      // Authenticate the user (replaces old signIn() call).
      // You can pass scopeHint if needed.
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      // Get authentication tokens (idToken is what you usually send to your backend)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        log('Google Sign-In succeeded but idToken is null');
        hideLoading(context);
        return;
      }
      /*  final FirebaseAuth auth = FirebaseAuth.instance;
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      User? user = (await auth.signInWithCredential(credential)).user; */
      socialLogin(
        context,
        googleUser.email,
        googleUser.displayName,
      );
      notifyListeners();
    } catch (e) {
      log("kbjhfjuht $e");
      hideLoading(context);
      notifyListeners();
    } finally {
      hideLoading(context);
      notifyListeners();
    }
  }

  socialLogin(context, email, displayName /* User user */) async {
    showLoading(context);
    notifyListeners();
    String token = await getFcmToken();
    var body = {
      "login_type": "google",
      "user": {"email": email, "name": displayName},
      "fcm_token": token
    };

    try {
      await apiServices
          .postApi(api.socialLogin, jsonEncode(body))
          .then((value) async {
        notifyListeners();
        if (value.isSuccess!) {
          pref = await SharedPreferences.getInstance();
          pref!.setBool(session.isContinueAsGuest, false);
          String? token = pref?.getString(session.accessToken);
          log("TOKEN :%sss$token");
          final appDetails =
              Provider.of<AppDetailsProvider>(context, listen: false);
          appDetails.getAppPages();
          final commonApi =
              Provider.of<CommonApiProvider>(context, listen: false);
          await commonApi.selfApi(context);
          commonApi.getDashboardHome(context);
          commonApi.getDashboardHome2(context);
          await Future.delayed(DurationClass.ms150);
          hideLoading(context);
          final locationCtrl =
              Provider.of<LocationProvider>(context, listen: false);
          locationCtrl.getUserCurrentLocation(context);
          locationCtrl.getLocationList(context);
          locationCtrl.getCountryState();
          pref!.remove(session.isContinueAsGuest);
          // final dashCtrl =
          //     Provider.of<DashboardProvider>(context, listen: false);
          // dashCtrl.getJobRequest();

          final cartCtrl = Provider.of<CartProvider>(context, listen: false);
          cartCtrl.onReady(context);
          final notifyCtrl =
              Provider.of<NotificationProvider>(context, listen: false);
          notifyCtrl.getNotificationList(context);
          /*Navigator.popUntil(
              context,
              route.pushReplacementNamed(
                  context, routeName.servicesDetailsScreen));*/
          route.pushReplacementNamed(context, routeName.dashboard);
        } else {
          hideLoading(context);
          notifyListeners();
          Fluttertoast.showToast(
              msg: value.message, backgroundColor: appColor(context).red);
        }
      });
    } catch (e) {
      hideLoading(context);
      notifyListeners();
      log("CATCH ff: $e");
    }
  }

  //login
  login(context) async {
    try {
      pref = await SharedPreferences.getInstance();
      String? token = await getFcmToken();

      log("TOKEN FOR FCM : $token");

      showLoading(context);

      var body = {
        "email": emailController.text,
        "password": passwordController.text,
        "fcm_token": token
      };

      log("body : $body");

      await apiServices
          .postApi(api.login, jsonEncode(body))
          .then((value) async {
        if (value.isSuccess!) {
          isGuest = false;
          notifyListeners();
          pref!.setBool(session.isContinueAsGuest, false);
          log("DDDDDDDDDDDD");
          final commonApi =
              Provider.of<CommonApiProvider>(context, listen: false);
          await commonApi.selfApi(context);

          final userRole = userModel!.role;
          log("USER:::$userRole");
          if (userRole != "user") {
            hideLoading(context);
            log("Unauthorized role detected: $userRole");
            Fluttertoast.showToast(
              msg: "This action is unauthorized for non-user roles.",
              backgroundColor: appColor(context).red,
            );
            return;
          }

          // ✅ All logic continues below (no longer in else block)

          final dashCtrl =
              Provider.of<DashboardProvider>(context, listen: false);
          final review = Provider.of<MyReviewProvider>(context, listen: false);
          final notifyCtrl =
              Provider.of<NotificationProvider>(context, listen: false);

          dashCtrl.getBookingHistory(context);
          review.getMyReview(context);
          notifyCtrl.getNotificationList(context);

          String? token = pref?.getString(session.accessToken);
          log("TOKEN :%sss$token");
          await commonApi.selfApi(context);
          commonApi.getDashboardHome(context);
          commonApi.getDashboardHome2(context);
          hideLoading(context);
          emailController.text = '';
          passwordController.text = '';
          log("message=-=-=-=-=-${pref?.getString(session.booking)}");
          if (pref!.getString(session.booking) != null) {
            log("message=-=-=-=-=-1${pref!.getString(session.booking)}");
            int? lastServiceId = pref!.getInt("lastOpenedServiceId");
            log("lastServiceId::$lastServiceId");
            route.pushReplacementNamed(
              context,
              routeName.servicesDetailsScreen,
              args: {'serviceId': lastServiceId},
            );
          } else {
            route.pushReplacementNamed(context, routeName.dashboard);
          }

          dynamic userData = pref!.getString(session.user);
          if (userData != null) {
            log("message=============> $userData");
            final locationCtrl =
                Provider.of<LocationProvider>(context, listen: false);
            await locationCtrl.getLocationList(context);
            await locationCtrl.getCountryState();

            if (context.mounted) {
              final cartCtrl =
                  Provider.of<CartProvider>(context, listen: false);
              cartCtrl.onReady(context);
            }
            pref!.remove(session.isContinueAsGuest);
          }

          Fluttertoast.showToast(
              msg: value.message, backgroundColor: const Color(0xff5465FF));

          if (!context.mounted) {
            hideLoading(context);
          }

          notifyListeners();
        } else {
          hideLoading(context);
          Fluttertoast.showToast(
            msg: value.message,
            backgroundColor: appColor(context).red,
          );
        }
      });
    } catch (e, s) {
      hideLoading(context);
      notifyListeners();
      log("CATCH login: $e====> $s");
    }
  }

  continueAsGuestTap(context) async {
    pref = await SharedPreferences.getInstance();

    pref!.setBool(session.isContinueAsGuest, true);
    // log("vbvbvb ${pref!.setBool(session.isContinueAsGuest, true)}");
    log("CCC");

    route.pushReplacementNamed(context, routeName.dashboard);
  }

  locationConformation(
    context,
  ) {
    showDialog(
        context: context,
        builder: (context1) {
          return StatefulBuilder(builder: (context2, setState) {
            return Consumer<LocationProvider>(
                builder: (context3, value, child) {
              return AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: Insets.i20),
                  shape: const SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.all(SmoothRadius(
                          cornerRadius: AppRadius.r14, cornerSmoothing: 1))),
                  backgroundColor: appColor(context).whiteBg,
                  content: Stack(alignment: Alignment.topRight, children: [
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      // Gif
                      /* Stack(alignment: Alignment.topCenter, children: [
                        Stack(alignment: Alignment.topCenter, children: [
                          SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Image.asset(eImageAssets.failedBook,
                                          height: Sizes.s165, width: Sizes.s88)
                                      .paddingOnly(
                                          bottom: Insets.i15, top: Insets.i25))
                              .decorated(
                                  color: appColor(context).fieldCardBg,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r10)),
                        ]),
                      ]), */
                      // Sub text
                      const VSpace(Sizes.s15),
                      Text(
                          /* language(context, translations!.logoutDesc) */
                          "We Need Your Location to Enhance Your Experience.",
                          textAlign: TextAlign.center,
                          style: appCss.dmDenseRegular14
                              .textColor(appColor(context).lightText)
                              .textHeight(1.3)),
                      const VSpace(Sizes.s20),
                      ButtonCommon(
                          onTap: () async {
                            final dashCtrl = Provider.of<DashboardProvider>(
                                context,
                                listen: false);
                            final locationCtrl = Provider.of<LocationProvider>(
                                context,
                                listen: false);

                            final review = Provider.of<MyReviewProvider>(
                                context,
                                listen: false);

                            final notifyCtrl =
                                Provider.of<NotificationProvider>(context,
                                    listen: false);
                            await locationCtrl.getZoneId(context);
                            dashCtrl.getBookingHistory(context);
                            // favCtrl.getFavourite();
                            review.getMyReview(context);

                            notifyCtrl.getNotificationList(context);
                            String? token =
                                pref?.getString(session.accessToken);
                            log("TOKEN :%sss$token");
                            final commonApi = Provider.of<CommonApiProvider>(
                                context,
                                listen: false);
                            await commonApi.selfApi(context);

                            commonApi.getDashboardHome(context);
                            commonApi.getDashboardHome2(context);

                            // if (pref!.getString(session.booking) != null) {
                            //
                            //   route.pushReplacementNamed(
                            //       context, routeName.servicesDetailsScreen);
                            //   /*  bookingCtrl.getBookingDetails(context); */
                            // } else {
                            //   route.pushReplacementNamed(
                            //       context, routeName.dashboard);
                            // }
                            /*    route.pushReplacementNamed(context, routeName.dashboard); */
                            dynamic userData = pref!.getString(session.user);

                            if (userData != null) {
                              log("message=============> $userData");
                              final locationCtrl =
                                  Provider.of<LocationProvider>(context,
                                      listen: false);
                              /*locationCtrl.getUserCurrentLocation(context);*/
                              await locationCtrl.getLocationList(context);
                              await locationCtrl.getCountryState();
                              // WidgetsBinding.instance.addPostFrameCallback((_) {
                              //   final dashCtrl =
                              //       Provider.of<DashboardProvider>(context, listen: false);
                              //   dashCtrl.getJobRequest();
                              // });
                              if (context.mounted) {
                                final cartCtrl = Provider.of<CartProvider>(
                                    context,
                                    listen: false);
                                cartCtrl.onReady(context);
                              }
                              pref!.remove(session.isContinueAsGuest);
                            }
                            /* Fluttertoast.showToast(
                              msg: value.message,
                              backgroundColor: appColor(context).primary,
                            ); */
                            if (!context.mounted) {
                              hideLoading(context);
                            }
                            emailController.text = "";
                            passwordController.text = "";
                            notifyListeners();
                          } /* => route.pop(context) */,
                          title: "Current Location",
                          borderColor: appColor(context).primary,
                          color: appColor(context).whiteBg,
                          style: appCss.dmDenseSemiBold16
                              .textColor(appColor(context).primary)),
                      const VSpace(Sizes.s20),
                      ButtonCommon(
                        title: "Manualy",
                        color: appColor(context).primary,
                        onTap: () async {
                          route.pushNamed(
                            context,
                            routeName.currentLocation, /*  arg: true */
                          );
                          /*  route
                              .pushNamed(context, routeName.location)
                              .then((e) {
                            /* animationController!.reset(); */
                            notifyListeners();
                          }).then((e) {
                            final location = Provider.of<LocationProvider>(
                                context,
                                listen: false);
                            location.getLocationList(context);
                          }); */
                        },
                        style: appCss.dmDenseSemiBold16
                            .textColor(appColor(context).whiteColor),
                      )
                      /* Row(children: [
                        Expanded(
                            child: ButtonCommon(
                                onTap: () => route.pop(context),
                                title: "Current Location",
                                borderColor: appColor(context).primary,
                                color: appColor(context).whiteBg,
                                style: appCss.dmDenseSemiBold16
                                    .textColor(appColor(context).primary))),
                        const HSpace(Sizes.s15),
                        Expanded(
                            child: ButtonCommon(
                          title: "Manualy",
                          color: appColor(context).primary,
                          onTap: () async {},
                          style: appCss.dmDenseSemiBold16
                              .textColor(appColor(context).whiteColor),
                        ))
                      ]) */
                    ]).padding(
                        horizontal: Insets.i20,
                        top: Insets.i60,
                        bottom: Insets.i20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Title
                          Text(
                              language(context, translations!.logOut)
                                  .replaceAll(" ", ""),
                              style: appCss.dmDenseExtraBold18
                                  .textColor(appColor(context).darkText)),
                          Icon(CupertinoIcons.multiply,
                                  size: Sizes.s20,
                                  color: appColor(context).darkText)
                              .inkWell(onTap: () => route.pop(context))
                        ]).paddingAll(Insets.i20)
                  ]));
            });
          });
        });
  }
}
