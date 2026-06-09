import 'dart:developer';

import 'package:fixit_user/common_tap.dart';
import 'package:fixit_user/config.dart';
import 'package:fixit_user/screens/app_pages_screens/app_details_screen/layouts/page_detail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDetailsProvider with ChangeNotifier {
  List<PagesModel> pageList = [];

  String appVersion = "";

  Future<void> getAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    notifyListeners();
  }

  onTapWhatsapp(context) {
    wpTap(context, "+971582284378");
  }

  onTapWebsite(context) {
    commonUrlTap(context, "https://khidmaplus.com",
        launchMode: LaunchMode.externalApplication);
  }

  onTapOption(data, context) {
    log("TITLE : $data");
    if (data!.title!.toString().toLowerCase() == translations!.helpSupport) {
      route.pushNamed(context, routeName.helpSupport);
    } else {
      route.push(
          context,
          PageDetail(
            page: data,
          ));
    }
  }

//get page list api
  bool isLoading = false;
  getAppPages() async {
    isLoading = true;
    try {
      await apiServices.getApi(api.page, []).then((value) {
        if (value.isSuccess!) {
          List page = value.data;
          pageList = [];
          page.asMap().forEach((key, value) {
            pageList.add(PagesModel.fromJson(value));
          });
          pageList = pageList.reversed.toList();
          log("pageList:::$pageList");
          isLoading = false;
          notifyListeners();
        }
      });
    } catch (e) {
      isLoading = false;
      log("EEEE getAppPages : $e");
      notifyListeners();
    }
  }
}
