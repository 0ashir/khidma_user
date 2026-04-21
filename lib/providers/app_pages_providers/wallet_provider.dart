import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixit_user/config.dart';
import 'package:fixit_user/models/app_setting_model.dart';
import 'package:fixit_user/providers/app_pages_providers/wallet_bonus_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../screens/app_pages_screens/wallet_balance_screen/layouts/add_money_layout.dart';

class WalletProvider with ChangeNotifier {
  List<WalletList> walletList = [];
  String? wallet;
  UserModel? userModel;
  List<PaymentMethods> paymentList = [];
  SharedPreferences? preferences;
  double balance = 0.0;
  bool isGuest = false;

  TextEditingController moneyCtrl = TextEditingController();
  final FocusNode moneyFocus = FocusNode();

  onTapGateway(val) {
    wallet = val;
    notifyListeners();
    log("WALLL :#$wallet");
  }

  onAddMoney(context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context2) {
        return AddMoneyLayout(buildContext: context);
      },
    ).then((value) async {
      final commonApi = Provider.of<CommonApiProvider>(context, listen: false);
      await commonApi.selfApi(context);
      getWalletList(context);
    });
  }

  getUserDetail(context) async {
    preferences = await SharedPreferences.getInstance();

    isGuest = preferences!.getBool(session.isContinueAsGuest) ?? false;
    //Map user = json.decode(preferences!.getString(session.user)!);
    userModel =
        UserModel.fromJson(json.decode(preferences!.getString(session.user)!));
    if (paymentMethods.isNotEmpty) {
      paymentList = paymentMethods;
    } else {
      final common = Provider.of<CommonApiProvider>(context, listen: false);
      await common.getPaymentMethodList(context);
      paymentList = paymentMethods;
    }
    log("paymentList L${paymentList.length}");
    paymentList.removeWhere((element) => element.slug == "cash");
    wallet = paymentList[0].slug;
    log("paymentList SS${paymentList.length}");
    log("paymentList SS${paymentMethods.length}");
    final walletApi = Provider.of<WalletBonusProvider>(context, listen: false);
    log("messageiuh9iyubghybuu7");
    await walletApi.getWalletBonusList(context);

    if (walletList.isEmpty) {
      getWalletList(context);
    }
    notifyListeners();
  }

  Future<void> getWalletList(context) async {
    try {
      await apiServices
          .getApi(api.wallet, [], isToken: true, isData: true)
          .then((value) async {
        log("WALLLL :${value.data}");
        if (value.isSuccess!) {
          final common = Provider.of<CommonApiProvider>(context, listen: false);
          await common.getPaymentMethodList(context);
          log("WALLLL :${value.data}");
          // balance = double.parse(value.data['balance'].toString());
          walletList = [];
          for (var data in value.data['data']['transactions']) {
            walletList.add(WalletList.fromJson(data));
          }
          final commonApi =
              Provider.of<CommonApiProvider>(context, listen: false);
          await commonApi.selfApi(context);

          notifyListeners();
        } /* else {
          log("WWWWW:::${value.message}");
          /*  flutterAlertMessage(context, msg: value.message); */
        } */
      });
    } catch (e) {
      log("ERRROEEE getProviderById wallet: $e");
      notifyListeners();
    }
  }

  //add to wallet
  addToWallet(context1, context) async {
    FocusScope.of(context).requestFocus(FocusNode());

    try {
      route.pop(context);
      showLoading(context);
      notifyListeners();
      var body = {
        "amount": moneyCtrl.text,
        "payment_method": wallet,
        "type": "wallet",
        "currency_code": currency(context).currency!.code,
      };

      notifyListeners();
      log("checkoutBody: $body");
      await apiServices
          .postApi(api.addMoneyToWallet, body, isData: true, isToken: true)
          .then((value) async {
        hideLoading(context);
        notifyListeners();
        if (value.isSuccess!) {
          moneyCtrl.text = "";
          wallet = paymentList[0].slug;
          notifyListeners();
          route
              .pushNamed(context, routeName.checkoutWebView, arg: value.data)
              .then((e) async {
            log("SSS :$e");
            if (e != null) {
              if (e['isVerify'] == true) {
                await getWalletList(context);
                await getVerifyPayment(value.data['item_id'], context);
              }
            }
          });
          notifyListeners();
        } else {
          SharedPreferences pref = await SharedPreferences.getInstance();

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
            Fluttertoast.showToast(
                msg: value.message, backgroundColor: Colors.red);
          }
        }
      });
    } catch (e) {
      hideLoading(context);
      notifyListeners();
    }
  }

  //verify payment
  getVerifyPayment(data, context) async {
    try {
      await apiServices
          .getApi("${api.verifyPayment}?item_id=$data&type=wallet", {},
              isToken: true, isData: true)
          .then((value) {
        log("VGHDGHSD : ${value.message}");
        if (value.isSuccess!) {
          if (value.data["payment_status"].toString().toLowerCase() ==
              "pending") {
            Fluttertoast.showToast(
                msg: translations!.yourPaymentIsDeclined!,
                backgroundColor: Colors.red);
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //   content:
            //       Text(language(context, translations!.yourPaymentIsDeclined)),
            //   backgroundColor: appColor(context).red,
            // ));
          } else {
            getWalletList(context);
          }
        }
      });
    } catch (e) {
      notifyListeners();
    }
  }
}
