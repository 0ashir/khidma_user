import 'dart:developer';

import 'package:fixit_user/config.dart';
import 'package:fixit_user/services/environment.dart';
import 'package:webview_flutter/webview_flutter.dart';


class CheckoutWebViewProvider with ChangeNotifier {
  bool isPayment = false, isLoading = true;

  dynamic data;

  WebViewController? controller;

  onReady(context) async {
    dynamic url = ModalRoute.of(context)!.settings.arguments ?? "";
    data = url;
    log("URL : $data");
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(data["url"]))
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.contains(paymentUrl)) {
            handleUrlChanged(context, request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageFinished: (url) {
          log("URL :$url");
        },
        onUrlChange: (change) {
          isLoading = false;
          /* log("change.url! : ${change}");
          if (change.url!.contains("/success")) {
            isPayment = true;
          }*/
          notifyListeners();
        },
        onWebResourceError: (error) {

          log("dfhdjkhfg :$error");
        },
      ));
    notifyListeners();
  }

  // on order success navigate to order success page
  successNavigation(context, {data}) async {
    log("fhdskjfghdhf:$data");
    route.pop(context,
        arg: {"isVerify": data == null ? false : true, "data": data});
  }

  void handleUrlChanged(context, String url) {

    getPaymentTransactionData(context, url);
    if (url.contains('/member-login/')) {
      log("order-login/");
      route.pop(context);
    }
  }

  getPaymentTransactionData(context, api) async {
    try {
      await apiServices.getApi(api, [], isData: true).then((value) {
        if (value.isSuccess!) {
          /* final items = api.split('/success');
          log("items : $items");
          final number = items[0].split('/').last;
          log("number1 : $number");
       */
          log("dsfdf :${value.data}");
          if (value.data['payment_status'] == "COMPLETED") {
            successNavigation(context, data: value.data);
          } else {
            successNavigation(context);
          }
        }
      });
    } catch (e,s) {
      log("ERRROEEE getProviderById checkout: $e======$s");
      notifyListeners();
    }
  }
}
