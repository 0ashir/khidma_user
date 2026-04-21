import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixit_user/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/environment.dart';

class NewLocationProvider with ChangeNotifier {
  int selectIndex = 0;
  List categoryList = [
    translations!.home,
    translations!.work,
    translations!.other,
  ];
  PrimaryAddress? address;
  bool isCheck = false, isEdit = false;
  GlobalKey<FormState> locationFormKey = GlobalKey<FormState>();

  String dialCode = "+${appSettingModel?.general?.countryCode ?? 1}";
  TextEditingController streetCtrl = TextEditingController();
  TextEditingController countryCtrl = TextEditingController();
  TextEditingController stateCtrl = TextEditingController();
  TextEditingController cityCtrl = TextEditingController();
  TextEditingController zipCtrl = TextEditingController();
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController numberCtrl = TextEditingController();

  final FocusNode nameFocus = FocusNode();
  final FocusNode numberFocus = FocusNode();
  final FocusNode zipFocus = FocusNode();
  final FocusNode cityFocus = FocusNode();
  final FocusNode stateFocus = FocusNode();
  final FocusNode countryFocus = FocusNode();
  final FocusNode streetFocus = FocusNode();
  bool isLogin = false;

  int? countryValue, stateValue;
  CountryStateModel? country;
  StateModel? state;

  getOnInitData(context) {
    dynamic data = ModalRoute.of(context)!.settings.arguments;

    final locationCtrl = Provider.of<LocationProvider>(context, listen: false);

    log("GHFDGFH $data");
    if (data == true) isLogin = data;
    if (data != null) {
      var arg = data['data'];
      address = arg;
      isEdit = true;
      log("STATEID :${address!.countryId!}");
      nameCtrl.text = address!.alternativeName ?? "";
      numberCtrl.text = address!.alternativePhone!.toString();
      if (address!.latitude.toString() != position!.latitude.toString() &&
          address!.longitude.toString() != position!.longitude.toString()) {
        streetCtrl.text = locationCtrl.place!.street!;
        cityCtrl.text = locationCtrl.place!.locality!;
        zipCtrl.text = locationCtrl.place!.postalCode!;
      } else {
        zipCtrl.text = address!.postalCode!;
        streetCtrl.text = address!.address!;
        cityCtrl.text = address!.city!;
      }

      countryValue = address!.countryId!;
      int index = locationCtrl.countryStateList
          .indexWhere((element) => element.id == countryValue);
      country = locationCtrl.countryStateList[index];
      locationCtrl.stateList = locationCtrl.countryStateList[index].state!;
      stateValue = address!.stateId!;
      locationCtrl.notifyListeners();

      selectIndex = categoryList.indexWhere((element) =>
          element.toString().toLowerCase() == address!.type!.toLowerCase());
      state = locationCtrl.stateList[stateValue!];
      isCheck = address!.isPrimary == 1 ? true : false;
      log("DIAOCLODE1 :${address!.code}");
      int dialCodeIndex = countriesEnglish.indexWhere((element) =>
          element['dial_code'] ==
          "${address!.code != null ? address!.code!.contains("+") ? "" : "+" : "+"}${address!.code}");
      log("index :$index");
      if (index >= 0) {
        dialCode = countriesEnglish[dialCodeIndex]['dial_code'];
        notifyListeners();
      }
      log("DIAOCLODE :$dialCode");
    } else {
      nameCtrl.text = "";

      numberCtrl.text = "";
      zipCtrl.text = locationCtrl.place!.postalCode!;
      streetCtrl.text = "";

      cityCtrl.text = locationCtrl.place!.locality!;
      isEdit = false;
      int ind = locationCtrl.countryStateList.indexWhere((element) =>
          element.name!.toLowerCase() ==
          locationCtrl.place!.country!.toLowerCase());
      log("DDD :$ind");

      if (ind >= 0) {
        country = locationCtrl.countryStateList[ind];
        countryValue = locationCtrl.countryStateList[ind].id;

        locationCtrl.stateList = locationCtrl.countryStateList[ind].state!;
      }
      int stateIndex = locationCtrl.stateList.indexWhere((element) =>
          element.name!.toLowerCase() ==
          locationCtrl.place!.administrativeArea!.toLowerCase());
      log("stateIndex :$stateIndex");
      if (stateIndex >= 0) {
        state = locationCtrl.stateList[stateIndex];
        stateValue = locationCtrl.stateList[stateIndex].id;
      }
      notifyListeners();

      streetCtrl.text = locationCtrl.place!.street!;
      /* countryValue = locationCtrl.countryStateList[0].id!;
      int index = locationCtrl.countryStateList
          .indexWhere((element) => element.id == countryValue);
      country = locationCtrl.countryStateList[0];
      locationCtrl.stateList = locationCtrl.countryStateList[index].state!;
      stateValue = locationCtrl.stateList[0].id!;
      state = locationCtrl.stateList[0];*/
      notifyListeners();
      log("COUNTREY :$countryValue");
      log("COUNTREY :$stateValue");
    }

    notifyListeners();
  }

  isCheckBoxCheck(value) {
    isCheck = value;
    notifyListeners();
  }

  onBack() {
    streetCtrl.text = "";
    stateCtrl.text = "";
    countryCtrl.text = "";
    dialCode = "+${appSettingModel?.general?.countryCode ?? 1}";
    cityCtrl.text = "";
    zipCtrl.text = "";
    nameCtrl.text = "";
    numberCtrl.text = "";
    notifyListeners();
  }

  changeDialCode(CountryCodeCustom country) {
    dialCode = country.dialCode!;
    notifyListeners();
  }

  onCategory(index) {
    selectIndex = index;
    notifyListeners();
  }

  onChangeCountry(context, val, CountryStateModel c) {
    countryValue = val;
    state = null;
    stateValue = null;

    final locationCtrl = Provider.of<LocationProvider>(context, listen: false);
    country = c;
    int index = locationCtrl.countryStateList
        .indexWhere((element) => element.id == countryValue);
    if (index >= 0) {
      locationCtrl.stateList = locationCtrl.countryStateList[index].state!;
      /*   stateValue = locationCtrl.stateList[0].id!;
      state = locationCtrl.stateList[stateValue!]*/
    }

    locationCtrl.notifyListeners();
    notifyListeners();
  }

  onChangeState(context, val, StateModel c) {
    stateValue = val;
    state = c;
    notifyListeners();
  }

  onAddLocation(context) {
    FocusScope.of(context).requestFocus(FocusNode());
    if (locationFormKey.currentState!.validate()) {
      if (isEdit) {
        editAddress(context);
      } else {
        log("ADDDD");
        if (country != null) {
          if (state != null) {
            addAddress(context);
          } else {
            Fluttertoast.showToast(
                msg: language(context, translations!.selectCountry));
          }
        } else {
          Fluttertoast.showToast(
              msg: language(context, translations!.selectCountry));
        }
      }
    }
  }

  SharedPreferences? pref;
  //add Address
  bool isLoading = false;
  addAddress(context) async {
    isLoading = true;
    notifyListeners();
    try {
      final locationCtrl =
          Provider.of<LocationProvider>(context, listen: false);
      log("countryValue :$countryValue");
      log("countryValue :${locationCtrl.countryStateList.length}");
      showLoading(context);
      notifyListeners();
      var body = {
        "latitude": position!.latitude,
        "longitude": position!.longitude,
        "type": categoryList[selectIndex].toString().toLowerCase(),
        "address": streetCtrl.text,
        "country_id": countryValue,
        "state_id": stateValue,
        "city": cityCtrl.text,
        "postal_code": zipCtrl.text,
        "alternative_name": nameCtrl.text,
        "alternative_phone": numberCtrl.text,
        "code": dialCode,
        "status": "1",
        "is_primary": isCheck ? true : false
      };

      log("body : $body");
      await apiServices
          .postApi('$apiUrl/address', body, isToken: true)
          .then((value) async {
        if (value.isSuccess!) {
          await locationCtrl.getLocationList(context);
          await route.pushNamed(
              context,
              routeName
                  .myLocation); /* .then((e) {
            /*  animationController!.reset(); */
            notifyListeners();
          }).then((e) {
            locationCtrl.getLocationList(context);
          }); */
          /*  await locationCtrl.getLocationList(context); */
          final locationProvider =
              Provider.of<LocationProvider>(context, listen: false);
          if (isLogin == true) {
            log("message=-=-=-=-=-=-=-=-=-=-");
            locationProvider.getZoneId(context,
                isLocation: true,
                lan: position!.longitude.toString(),
                lat: position!.latitude.toString());

            final dashCtrl =
                Provider.of<DashboardProvider>(context, listen: false);
            /* final locationCtrl =
                Provider.of<LocationProvider>(context, listen: false); */

            final review =
                Provider.of<MyReviewProvider>(context, listen: false);

            final notifyCtrl =
                Provider.of<NotificationProvider>(context, listen: false);
            /*  await locationCtrl.getZoneId(); */
            dashCtrl.getBookingHistory(context);
            // favCtrl.getFavourite();
            review.getMyReview(context);

            notifyCtrl.getNotificationList(context);
            String? token = pref?.getString(session.accessToken);
            log("TOKEN :%sss$token");
            final commonApi =
                Provider.of<CommonApiProvider>(context, listen: false);
            await commonApi.selfApi(context);

            commonApi.getDashboardHome(context);
            commonApi.getDashboardHome2(context);
            // Navigator.popUntil(
            //     context,
            //     route.pushReplacementNamed(
            //         context, routeName.servicesDetailsScreen));

            if (pref!.getString(session.booking) != null) {
              //
              route.pushReplacementNamed(
                  context, routeName.servicesDetailsScreen);
              /*  bookingCtrl.getBookingDetails(context); */
            } else {
              route.pushReplacementNamed(context, routeName.dashboard);
            }
            /*    route.pushReplacementNamed(context, routeName.dashboard); */
            dynamic userData = pref!.getString(session.user);
            // log("message=============> $userData");
            if (userData != null) {
              log("message=============> $userData");
              final locationCtrl =
                  Provider.of<LocationProvider>(context, listen: false);
              /*locationCtrl.getUserCurrentLocation(context);*/
              await locationCtrl.getLocationList(context);
              await locationCtrl.getCountryState();
              // WidgetsBinding.instance.addPostFrameCallback((_) {
              //   final dashCtrl =
              //       Provider.of<DashboardProvider>(context, listen: false);
              //   dashCtrl.getJobRequest();
              // });
              if (context.mounted) {
                final cartCtrl =
                    Provider.of<CartProvider>(context, listen: false);
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

            notifyListeners();
          }

          hideLoading(context);
          log("VVVV : ${value.isSuccess}");
          notifyListeners();
          isLoading = false;
          notifyListeners();
          route.pop(context);
          route.pop(context);
        } else {
          SharedPreferences pref = await SharedPreferences.getInstance();
          isLoading = false;
          notifyListeners();
          hideLoading(context);
          if (value.message.toLowerCase() == "unauthenticated.") {
            userModel = null;
            setPrimaryAddress = null;
            userPrimaryAddress = null;
            final dash = Provider.of<DashboardProvider>(context, listen: false);
            dash.selectIndex = 0;
            dash.notifyListeners();
            pref.remove(session.user);
            pref.remove(session.accessToken);
            pref.remove(session.isContinueAsGuest);
            pref.remove(session.isLogin);
            pref.remove(session.cart);
            pref.remove(session.recentSearch);

            final auth = FirebaseAuth.instance.currentUser;
            if (auth != null) {
              FirebaseAuth.instance.signOut();
              /*  GoogleSignIn().disconnect(); */
              final googleSignIn = GoogleSignIn.instance;

              googleSignIn.disconnect();
            }
            notifyListeners();
            route.pushAndRemoveUntil(context);
          } else {
            log("VVVV : ${value.isSuccess}");
            notifyListeners();
            Fluttertoast.showToast(
                backgroundColor: appColor(context).red, msg: value.message);
          }
        }
      });
    } catch (e, s) {
      isLoading = false;

      hideLoading(context);
      notifyListeners();
      log("CATCH addAddress: $e-==--==--=-=-=-$s");
    }
  }

  //edit Address
  editAddress(context) async {
    isLoading = true;
    notifyListeners();
    final locationCtrl = Provider.of<LocationProvider>(context, listen: false);

    showLoading(context);

    var body = {
      "latitude": position!.latitude,
      "longitude": position!.longitude,
      "type": categoryList[selectIndex].toString().toLowerCase(),
      "address": streetCtrl.text,
      "country_id": countryValue,
      "state_id": stateValue,
      "city": cityCtrl.text,
      "postal_code": zipCtrl.text,
      "alternative_name": nameCtrl.text,
      "alternative_phone": numberCtrl.text,
      "code": dialCode.toString() ?? '',
      "is_primary": isCheck ? true : false
    };
    log("ADDRESS ED :${"${api.address}/${address!.id}"}");
    log("body : $body");
    try {
      await apiServices
          .putApi("${api.address}/${address!.id}", body, isToken: true)
          .then((value) {
        hideLoading(context);
        log("VVVV : ${value.isSuccess}");
        notifyListeners();
        if (value.isSuccess!) {
          isLoading = false;
          notifyListeners();
          route.pop(context);
          route.pop(context);
        } else {
          isLoading = false;
          notifyListeners();
          Fluttertoast.showToast(
              backgroundColor: appColor(context).red, msg: value.message);
        }
      });
    } catch (e) {
      isLoading = false;
      notifyListeners();
      // hideLoading(context);
      notifyListeners();
      log("CATCH editAddress: $e");
    }
  }
}
