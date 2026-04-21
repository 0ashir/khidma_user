import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fixit_user/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../firebase/firebase_api.dart';
import '../../models/status_booking_model.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/environment.dart';

class CompletedServiceProvider with ChangeNotifier {
  List<StatusBookingModel> bookingList = [];
  BookingModel? booking;
  double valDownload = 0.0;
  String? localPath;
  String progress = "";
  bool isDownloading = false;
  double uploadProgress = 0.0;
  double perc = 0.0;
  bool isLoading = false;

  onReady(BuildContext context) async {
    dynamic arg = ModalRoute.of(context)!.settings.arguments;
    isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    try {
      if (arg['bookingId'] != null) {
        // Case 1: Fetch data from API using bookingId
        await getBookingDetailBy(context, id: arg['bookingId']);
      } else if (arg["booking"] != null) {
        // Case 2: Use passed BookingModel without API call
        booking = arg["booking"] as BookingModel;
        log("Using passed booking: id=${booking!.id}, serviceTitle=${booking!.service?.title}, media=${booking!.service?.media?.map((m) => m.originalUrl).toList()}");
        isLoading = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      } else {
        log("No bookingId or booking provided in arguments");
        Fluttertoast.showToast(msg: "Invalid booking data");
        isLoading = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      }
    } catch (e) {
      log("Error in onReady: $e");
      Fluttertoast.showToast(msg: "Error loading booking details");
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  /*onReady(context) {
    dynamic arg = ModalRoute.of(context)!.settings.arguments;
    if (arg['bookingId'] != null) {
      getBookingDetailBy(context, id: arg['bookingId']);
    } else {
      booking = arg['booking'];
      notifyListeners();
      getBookingDetailBy(context);
    }
  }
*/
  //booking detail by id
  getBookingDetailBy(context, {id}) async {
    isLoading = true;
    try {
      await apiServices
          .getApi("${api.booking}/${id ?? booking!.id}", [],
              isToken: true, isData: true)
          .then((value) {
        hideLoading(context);
        if (value.isSuccess!) {
          isLoading = false;
          debugPrint("BOOKING DATA : ${value.data['data']}");
          booking = BookingModel.fromJson(value.data['data']);
          notifyListeners();
        } else {
          Fluttertoast.showToast(msg: value.message);
        }
      });
      log("STATYS L $booking");
    } catch (e) {
      isLoading = false;
      hideLoading(context);
      notifyListeners();
    }
  }

  Future<void> requestPermissionAndDownload(BuildContext context) async {
    bool granted = true;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        final result = await Permission.storage.request();
        granted = result.isGranted;
        if (!granted) {
          Fluttertoast.showToast(msg: "Storage permission denied");
          return;
        }
      }
    }

    download(context);
  }

  Future<void> download(BuildContext context) async {
    valDownload = 0.0;
    isDownloading = true;
    notifyListeners();

    try {
      Directory? directory;

      if (Platform.isAndroid) {
        // Save to Android public Download folder
        directory = Directory("/storage/emulated/0/Download");
      } else {
        // Save to app's documents folder on iOS
        directory = await getApplicationDocumentsDirectory();
      }

      // Ensure the directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      String filePath = "${directory.path}/${booking!.bookingNumber}.pdf";

      var dio = Dio();
      dio.interceptors.add(LogInterceptor());

      final response = await dio.get(
        "$paymentUrl${booking!.invoiceUrl!}",
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: const Duration(seconds: 0),
        ),
        onReceiveProgress: showDownloadProgress,
      );

      log("URL Name For Call: ${response.realUri}");

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.data);

        isDownloading = false;
        progress = "";
        notifyListeners();

        if (Platform.isIOS) {
          await OpenFile.open(filePath);
        }

        await FirebaseApi().sendNotification(
            title: "Invoice Download Complete",
            msg: "Invoice ${booking!.bookingNumber} downloaded successfully.",
            token: userModel!.fcmToken);

        Fluttertoast.showToast(
            msg: language(
                context, translations?.invoiceDownload ?? "Invoice Downloaded"),
            backgroundColor: appColor(context).primary);
      } else {
        throw Exception("Download failed with status: ${response.statusCode}");
      }
    } catch (e) {
      isDownloading = false;
      log("Download error: $e");
      notifyListeners();

      // Fluttertoast.showToast(
      //     msg: "Download failed: ${e.toString()}", backgroundColor: Colors.red);
    }
  }

  // download(context) async {
  //   valDownload = 0.0;
  //   notifyListeners();
  //   isDownloading = true;
  //
  //   try {
  //     final androidInfo = await DeviceInfoPlugin().androidInfo;
  //     late final Map<Permission, PermissionStatus> status;
  //
  //     if (Platform.isAndroid) {
  //       if (androidInfo.version.sdkInt <= 32) {
  //         status = await [Permission.storage].request();
  //       } else {
  //         status = await [Permission.photos].request();
  //       }
  //     } else {
  //       status = await [Permission.photosAddOnly].request();
  //     }
  //
  //     var allAccept = true;
  //     status.forEach((permission, status) {
  //       if (status != PermissionStatus.granted) {
  //         allAccept = false;
  //       }
  //     });
  //
  //     Directory directory = Directory('/storage/emulated/0/Download');
  //     if (!await directory.exists()) {
  //       await directory.create(recursive: true);
  //     }
  //     String savePath = '${directory.path}/${booking!.bookingNumber}.pdf';
  //     log("dkjahgsdj ${paymentUrl}${booking!.invoiceUrl}");
  //
  //     var dio = Dio();
  //     dio.interceptors.add(LogInterceptor());
  //     try {
  //       var response = await dio.get(
  //         "${paymentUrl}${booking!.invoiceUrl!}",
  //         onReceiveProgress: showDownloadProgress,
  //         //Received data with List<int>
  //         options: Options(
  //           responseType: ResponseType.bytes,
  //           followRedirects: false,
  //           receiveTimeout: const Duration(seconds: 0),
  //         ),
  //       );
  //       var file = File(savePath);
  //       log("response.statusCode::${response.statusCode}//${file}");
  //       if (response.statusCode == 200) {
  //         await file.writeAsBytes(response.data);
  //         isDownloading = false;
  //         progress = "";
  //         notifyListeners();
  //
  //         // ✅ Final download complete notification
  //         await FirebaseApi().sendNotification(
  //           title: "Invoice Download Complete",
  //           msg: "Invoice ${booking!.bookingNumber} downloaded successfully.",
  //           token: userModel!.fcmToken,
  //         );
  //
  //         Fluttertoast.showToast(
  //           msg: language(
  //               context, translations?.invoiceDownload ?? "Invoice Downloaded"),
  //           backgroundColor: appColor(context).primary,
  //         );
  //       }
  //     } catch (e) {
  //       debugPrint(e.toString());
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  //booking payment
  bookingPayment(context, isCash) async {
    try {
      showLoading(context);
      notifyListeners();
      var body = {
        "booking_id": booking!.id,
        "payment_method": booking!.paymentMethod,
        "currency_code": currency(context).currency!.code,
        "type": booking!.extraCharges == null || booking!.extraCharges!.isEmpty
            ? "booking"
            : "extra_charge"
      };

      log("checkoutBody: $body");
      await apiServices
          .postApi(api.extraPaymentCharge, body, isData: true, isToken: true)
          .then((value) async {
        hideLoading(context);
        notifyListeners();
        log("booking/payment :${value.data} //${value.message} // ${value.isSuccess}");
        if (value.isSuccess!) {
          if (isCash) {
            updateStatus(context, translations!.completed);
          } else {
            route
                .pushNamed(context, routeName.checkoutWebView, arg: value.data)
                .then((e) async {
              log("SSS :$e");
              if (e != null) {
                log("value.data[sss :${value.data}");
                if (e['isVerify'] == true) {
                  log("value.data[sdsafdsfs :${value.data}");
                  log("value.data[ :${value.data}");
                  await getVerifyPayment(value.data['item_id'], context);
                } else {
                  log("value.data[sss :${value.message}");
                  Fluttertoast.showToast(
                      msg: "Payment Failed",
                      backgroundColor: appColor(context).red);
                }
              } else {
                log("value.data[sss s:${value.data}");
                Fluttertoast.showToast(
                    msg: "Payment Failed",
                    backgroundColor: appColor(context).red);
              }
            });
          }
          notifyListeners();
        } else {
          Fluttertoast.showToast(msg: value.message);
        }
      });
    } catch (e) {
      hideLoading(context);
      Fluttertoast.showToast(msg: e.toString());
      notifyListeners();
    }
  }

  //update status
  updateStatus(context, status, {isCancel = false, sync}) async {
    log("NOCHANGE");
    try {
      showLoading(context);

      notifyListeners();
      dynamic data;
      data = {"booking_status": status};
      log("ON L$data");
      await apiServices
          .putApi("${api.booking}/${booking!.id}", data,
              isToken: true, isData: true)
          .then((value) {
        hideLoading(context);
        notifyListeners();
        if (value.isSuccess!) {
          debugPrint("STATYS YYYY:  ${value.data}");
          booking = BookingModel.fromJson(value.data);
          getBookingDetailBy(context);

          notifyListeners();
          if (status == translations!.completed) {
            completeSuccess(
              context,
            );
          }
        }
      });
      hideLoading(context);
      notifyListeners();
    } catch (e) {
      hideLoading(context);
      notifyListeners();
    }
  }

  completeSuccess(context) {
    showCupertinoDialog(
      context: context,
      builder: (context1) {
        return AlertDialogCommon(
          title: translations!.successfullyComplete,
          height: Sizes.s140,
          image: eGifAssets.successGif,
          subtext: language(context, translations!.areYouSureComplete),
          bText1: language(context, translations!.viewBillDetails),
          b1OnTap: () {
            route.pop(context);
            notifyListeners();
            /* route.pushNamedAndRemoveUntil(context, routeName.dashboard);
            final dash =
            Provider.of<DashboardProvider>(context, listen: false);
            dash.selectIndex = 1;
            dash.notifyListeners();*/
          },
        );
      },
    );
  }

  paySuccess(context) {
    if (booking!.paymentMethod == "cash") {
      bookingPayment(context, true);
    } else {
      bookingPayment(context, false);
    }
  }

//verify payment
  getVerifyPayment(data, context) async {
    try {
      await apiServices
          .getApi(
              "${api.verifyPayment}?item_id=${data['item_id']}&type=booking",
              [],
              isToken: true,
              isData: true)
          .then((value) {
        if (value.isSuccess!) {
          if (value.data["payment_status"].toString().toLowerCase() ==
              "pending") {
            Fluttertoast.showToast(
                backgroundColor: appColor(context).red,
                msg: language(context, translations!.yourPaymentIsDeclined));

            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //   content:
            //       Text(language(context, translations!.yourPaymentIsDeclined)),
            //   backgroundColor: appColor(context).red,
            // ));
          } else {
            log("CCCCC");
            updateStatus(context, translations!.completed);
            getBookingDetailBy(context);
          }
        }
      });
    } catch (e) {
      notifyListeners();
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      valDownload = (received / total * 100);
      debugPrint("${valDownload.toStringAsFixed(0)}%");

      // FirebaseApi().sendNotification(
      //   title: "Invoice Download",
      //   msg: "${valDownload.toStringAsFixed(0)}% Invoice Downloaded",
      //   token: userModel!.fcmToken,
      // );
    }
    notifyListeners();
  }
}
