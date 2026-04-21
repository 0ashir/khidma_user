import 'dart:developer';
import 'package:fixit_user/models/referral_model.dart';
import '../../../config.dart';


class ReferralProvider with ChangeNotifier {
  List<ReferralModel> referralList = [];
  bool isLoading = false;

  Future<void> getReferralList(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      await apiServices
          .getApi(api.referralBonus, [], isToken: true)
          .then((value) {
        if (value.isSuccess!) {
          List data = value.data;
          referralList = data.map((e) => ReferralModel.fromJson(e)).toList();
          log("Referral List fetched: ${referralList.length}");
        }
        isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      isLoading = false;
      log("Error fetching referral list: $e");
      notifyListeners();
    }
  }

  void onReady(BuildContext context) {
    getReferralList(context);
  }
}
