import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/scheduler.dart';

import '../../config.dart';
import '../../models/blog_details.dart';

class LatestBLogDetailsProvider with ChangeNotifier {
  BlogDetails? data;
  double widget1Opacity = 0.0;
  bool? isBlogList = false;
  var dio = Dio();

  Future<void> getBlogDetails(context, {dynamic id}) async {
    isBlogList = true;
    log("id::$id");
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? lang = pref.getString("selectedLocale");
      var response = await dio.get(
        "${api.blog}/$id",
        data: [],
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Accept-Language': lang,
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        isBlogList = false;
        BlogDetails dddd = BlogDetails.fromJson(response.data);

        data = dddd;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    } catch (e, s) {
      isBlogList = false;
      log("EEEE getBlog : $e DATA////$s");
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  onReady(context) {
    // final args = ModalRoute.of(context)?.settings.arguments as Map?;
    // if (args != null && args['blogId'] != null) {
    //   getBlogDetails(context,id: args['blogId']);
    // }
  }

  onBack(context, isBack) {
    data = null;
    notifyListeners();
    if (isBack) {
      route.pop(context);
    }
  }
}
