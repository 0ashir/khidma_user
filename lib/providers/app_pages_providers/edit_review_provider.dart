import 'dart:developer';

import 'package:fixit_user/config.dart';
import 'package:fluttertoast/fluttertoast.dart';


class EditReviewProvider with ChangeNotifier {
  int selectedIndex = 3;
  TextEditingController editReviewController = TextEditingController();
  final FocusNode reviewFocus = FocusNode();
  Reviews? review;

  onTapEmoji(index) {
    selectedIndex = index;
    notifyListeners();
  }

  getReview(context) {
    dynamic data = ModalRoute.of(context)!.settings.arguments;
    review = data;
    editReviewController.text = review!.description!;

    selectedIndex = review!.rating == 0
        ? 0
        : review!.rating == 1
            ? 1
            : review!.rating == 2
                ? 2
                : review!.rating == 3
                    ? 3
                    : 4;
    notifyListeners();
  }

  bool israteServiceLoader = false;
  rateService(context) async {
    try {
      israteServiceLoader = true;
      FocusScope.of(context).requestFocus(FocusNode());
      showLoading(context);
      notifyListeners();
      dynamic body = {
        "description": editReviewController.text,
        "rating": selectedIndex == 0
            ? 1
            : selectedIndex == 1
                ? 2
                : selectedIndex == 2
                    ? 3
                    : selectedIndex == 3
                        ? 4
                        : 5
      };

      await apiServices
          .putApi("${api.review}/${review!.id}", body, isToken: true)
          .then((value) async {
        hideLoading(context);

        notifyListeners();
        if (value.isSuccess!) {
          israteServiceLoader = false;
          showDialog(
              context: context,
              builder: (context1) {
                return AlertDialogCommon(
                  title: translations!.reviewSubmitted,
                  image: eImageAssets.review,
                  subtext: translations!.yourReview,
                  bText1: translations!.okay,
                  height: Sizes.s145,
                  b1OnTap: () {
                    route.pop(context);
                    route.pop(context);
                  },
                );
              });
        } else {
          israteServiceLoader = false;
          log("value.message :${value.message}");
          Fluttertoast.showToast(
              msg: value.message, backgroundColor: appColor(context).red);
        }
      });
    } catch (e) {
      israteServiceLoader = false;
      log("EEEE :$e");
      hideLoading(context);
      notifyListeners();
    }
  }
}
