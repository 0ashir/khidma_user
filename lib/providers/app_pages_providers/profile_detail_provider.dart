import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:fixit_user/config.dart';
import 'package:dio/dio.dart' as dio;
import 'package:fixit_user/screens/app_pages_screens/profile_detail_screen/layouts/selection_option_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileDetailProvider with ChangeNotifier {
  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPhone = TextEditingController();
  String? dialCode;
  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  XFile? imageFile;
  SharedPreferences? preferences;
  UserModel? userModel;

  var selectList = [
    {"image": eSvgAssets.gallery, "title": translations!.chooseFromGallery},
    {"image": eSvgAssets.camera, "title": translations!.openCamera}
  ];

  changeDialCode(CountryCodeCustom country) {
    dialCode = country.dialCode!;
    notifyListeners();
  }

// GET IMAGE FROM GALLERY
  Future getImage(context, source) async {
    PermissionStatus cameraStatus = await Permission.camera.status;
    PermissionStatus galleryStatus = await Permission.photos.status;
    log("Camera Permission Status: ${cameraStatus.isGranted}");
    log("Gallery Permission Status: ${galleryStatus.isGranted}");

    /*  if (cameraStatus.isPermanentlyDenied || galleryStatus.isPermanentlyDenied) {
      log("Permission Permanently Denied - Opening App Settings...");
      await openAppSettings(); // ✅ Open App Settings
      return;
    }

    if (cameraStatus.isDenied || galleryStatus.isDenied) {
      log("Permission Denied - Requesting Again...");
      await openAppSettings();
      return;
    } */
    final ImagePicker picker = ImagePicker();
    imageFile = (await picker.pickImage(source: source))!;
    notifyListeners();
    if (imageFile != null) {
      // updateProfile(context);
      route.pop(context);
    }
  }

  showLayout(context) async {
    showDialog(
      context: context,
      builder: (context1) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: Insets.i20),
          shape: const SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.all(SmoothRadius(
                  cornerRadius: AppRadius.r14, cornerSmoothing: 1))),
          content: Consumer<LanguageProvider>(builder: (context, value, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language(context, translations!.selectOne),
                          style: appCss.dmDenseBold18
                              .textColor(appColor(context).darkText)),
                      const Icon(CupertinoIcons.multiply)
                          .inkWell(onTap: () => route.pop(context))
                    ]),
                const VSpace(Sizes.s20),
                ...appArray.selectList
                    .asMap()
                    .entries
                    .map((e) => SelectOptionLayout(
                        data: e.value,
                        index: e.key,
                        list: appArray.selectList,
                        onTap: () {
                          if (e.key == 0) {
                            getImage(context, ImageSource.gallery);
                          } else {
                            getImage(context, ImageSource.camera);
                          }
                          route.pop(context);
                        }))
              ],
            );
          }),
        );
      },
    );
  }

  bool isUpdateLoader = false;
  updateProfile(
    context,
  ) async {
    isUpdateLoader = true;
    FocusScope.of(context).requestFocus(FocusNode());
    showLoading(context);
    notifyListeners();
    dynamic mimeTypeData;
    if (imageFile != null) {
      mimeTypeData = lookupMimeType(imageFile!.path, headerBytes: [0xFF, 0xD8])!
          .split('/');
    }

    var body = {
      "name": txtName.text,
      "email": txtEmail.text,
      "code": dialCode,
      "phone": txtPhone.text,
      "_method": "PUT",
      if (imageFile != null)
        'profile_image': await dio.MultipartFile.fromFile(
            imageFile!.path.toString(),
            filename: imageFile!.name.toString(),
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1])),
    };

    log("message=======> $body");
    dio.FormData formData = dio.FormData.fromMap(body);

    try {
      await apiServices
          .postApi(api.updateProfile, formData, isToken: true)
          .then((value) async {
        hideLoading(context);

        notifyListeners();
        if (value.isSuccess!) {
          route.pop(context);

          final commonApi =
              Provider.of<CommonApiProvider>(context, listen: false);
          await commonApi.selfApi(context);
          isUpdateLoader = false;
        } else {
          isUpdateLoader = false;
          log("value.message :${value.message}");
          Fluttertoast.showToast(
              msg: value.message, backgroundColor: appColor(context).red);
        }
      });
    } catch (e, s) {
      isUpdateLoader = false;
      log("EEEE :$e====> $s");
      hideLoading(context);
      notifyListeners();
    }
  }

  onInitData(context) async {
    preferences = await SharedPreferences.getInstance();
    bool isGuest = preferences!.getBool(session.isContinueAsGuest) ?? false;

    //Map user = json.decode(preferences!.getString(session.user)!);
    if (!isGuest) {
      showLoading(context);
      var user = Provider.of<ProfileProvider>(context, listen: false);
      user.getUserDetail(context);
      notifyListeners();
      userModel = UserModel.fromJson(
          json.decode(preferences!.getString(session.user)!));

      log("userModel :$userModel");
      txtName.text = userModel!.name ?? "";
      txtEmail.text = userModel!.email ?? "";
      txtPhone.text = userModel!.phone.toString() ?? "";
      dialCode =
          userModel!.code ?? "+${appSettingModel?.general?.countryCode ?? 1}";
      log("message===============> $dialCode");
      if (userModel!.code != null) {
        int index = countriesEnglish.indexWhere((element) =>
            element['dial_code'] ==
            "${userModel!.code.toString().contains("+") ? "" : "+"}${userModel!.code!}");
        log("index :$index");

        log("index :${userModel!.code.toString().contains("+") ? "" : "+"}${userModel!.code!}");
        if (index >= 0) {
          dialCode = countriesEnglish[index]['dial_code'];
          notifyListeners();
        }
        log("dialCode :$dialCode");
      } else {
        dialCode = "+${appSettingModel?.general?.countryCode ?? 1}";
      }
      await Future.delayed(Durations.short3);
      hideLoading(context);
      notifyListeners();
    }

    notifyListeners();
  }
}
