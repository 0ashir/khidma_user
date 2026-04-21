import 'dart:developer';
import 'package:fixit_user/models/wallet_bonus_model.dart';
import '../../../config.dart';

class WalletBonusProvider with ChangeNotifier {
  List<WalletBonus> walletBonusList = [];
  bool isLoading = false;

  Future<void> getWalletBonusList(BuildContext context) async {
    try {
      log("sgpkodioprsbgpdrf");
      isLoading = true;
      notifyListeners();

      await apiServices
          .getApi(api.walletBonus, [], isToken: true)
          .then((value) {
        if (value.isSuccess!) {
          List data = value.data;
          walletBonusList = data.map((e) => WalletBonus.fromJson(e)).toList();
          log("wallet bonus List fetched: $walletBonusList");
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
    getWalletBonusList(context);
  }
}
