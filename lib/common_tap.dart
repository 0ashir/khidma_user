import 'dart:developer';
import 'dart:io';

import 'package:fixit_user/utils/toast_utils.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart';

//
const mail = 'mailto:';
const call = 'tel:';
const googleMapLink = 'https://www.google.com/maps/search/?api=1&query=';
const wpLink = 'whatsapp://send?phone=';
bool isOpen = false;

onBook(context, service,
    {GestureTapCallback? addTap,
    minusTap,
    ProviderModel? provider,
    providerId,
    isPackage = false,
    packageServiceId}) async {
  final cart = Provider.of<CartProvider>(context, listen: false);
  bool hasScheduledService = cart.cartList.any((element) =>
      element.isPackage == false && element.serviceList?.type == 'scheduled');

  if (hasScheduledService) {
    // Fluttertoast.showToast(

    //     msg: language(context, "Scheduled booking already in cart."));
    showErrorToast(context,
        "Your cart has a scheduled booking. Please remove it to add another item.");

    return;
  }
  SharedPreferences preferences = await SharedPreferences.getInstance();
  bool isGuest = preferences.getBool(session.isContinueAsGuest) ?? false;

  if (isGuest) {
    route.pushNamed(context, routeName.login);
    return;
  }

  final serviceCtrl =
      Provider.of<SelectServicemanProvider>(context, listen: false);
  isOpen = true;
  await serviceCtrl.onTapBook(
    context,
    service: service,
    isPackage: isPackage,
    index: packageServiceId,
    providerId: service.user?.id ?? service.userId,
    providerModel: provider,
    selectProviderIndex: 0,
  );
  isOpen = false;
}

mailTap(context, String url) {
  if (url.isNotEmpty) {
    commonUrlTap(context, '$mail$url',
        launchMode: LaunchMode.externalApplication);
  }
}

commonUrlTap(context, String address,
    {LaunchMode launchMode = LaunchMode.inAppWebView}) async {
  try {
    await launchUrl(Uri.parse(address), mode: launchMode);
  } catch (e) {
    String errorMessage = 'Unknown error occurred';

    if (e is PlatformException) {
      errorMessage = e.message ?? 'Platform error occurred';
    } else if (e is Exception) {
      errorMessage = e.toString();
    }

    // Show the error message as a toast without returning anything
    Fluttertoast.showToast(msg: errorMessage);
  }
}

launchCall(context, String? url) {
  if (url != null) {
    if (Platform.isIOS) {
      commonUrlTap(context, '$call//$url',
          launchMode: LaunchMode.externalApplication);
    } else {
      commonUrlTap(context, '$call$url',
          launchMode: LaunchMode.externalApplication);
    }
  }
}

launchMap(context, String? url) {
  commonUrlTap(context, googleMapLink + url!,
      launchMode: LaunchMode.externalApplication);
}

wpTap(BuildContext context, String? phoneNumber) {
  if (phoneNumber == null || phoneNumber.isEmpty) {
    log('Error: phone number is null or empty');
    return;
  }
  final url = 'whatsapp://send?phone=$phoneNumber';
  log("url:::$url");
  commonUrlTap(context, url, launchMode: LaunchMode.externalApplication);
}

showBookingStatus(context, BookingModel? bookingModel) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return BookingStatusDialog(
          bookingModel: bookingModel,
        );
      });
}
