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

  // Ensure the service passed to onTapBook is always a Services object
  // with List<CategoryModel> categories that include is_car.
  // ServiceDetailsModel uses a different Category class (no id/isCar), so
  // we fetch the full service whenever categories are missing or wrong type.
  // Also fetch when categories exist but none have isCar set — listing API
  // responses embed categories without is_car, so isCar defaults to 0.
  Services serviceToBook;
  final cats = service.categories;
  final catsList = cats;
  final catsHaveCarInfo = catsList is List<CategoryModel> &&
      catsList.isNotEmpty &&
      catsList.any((c) => c.isCar != null && c.isCar! > 0);
  final needsFetch = service is! Services ||
      cats == null ||
      (cats is List && cats.isEmpty) ||
      cats is! List<CategoryModel> ||
      !catsHaveCarInfo;

  if (needsFetch) {
    Services? fetched;
    try {
      final res = await apiServices.getApi(
        "${api.service}?serviceId=${service.id}", [],
        isToken: true,
      );
      if (res.isSuccess == true && res.data is Map) {
        fetched = Services.fromJson(Map<String, dynamic>.from(res.data));
        // Carry over provider info if the API response omitted it
        fetched.userId ??= service.user?.id ?? service.userId;
        fetched.user ??= provider ?? service.user;
      }
    } catch (e) {
      log("onBook: category fetch failed for service ${service.id}: $e");
    }
    serviceToBook = fetched ?? (service is Services ? service : Services(
      id: service.id,
      title: service.title,
      price: service.price,
      duration: service.duration,
      type: service.type?.toString(),
      requiredServicemen: service.requiredServicemen,
      selectedRequiredServiceMan: service.requiredServicemen,
      userId: service.user?.id ?? service.userId,
      user: provider ?? service.user,
    ));
  } else {
    serviceToBook = service;
  }

  final serviceCtrl =
      Provider.of<SelectServicemanProvider>(context, listen: false);
  isOpen = true;
  await serviceCtrl.onTapBook(
    context,
    service: serviceToBook,
    isPackage: isPackage,
    index: packageServiceId,
    providerId: serviceToBook.user?.id ?? serviceToBook.userId,
    providerModel: provider ?? serviceToBook.user,
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
