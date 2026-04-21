// ignore_for_file: unused_local_variable

import 'package:fixit_user/config.dart';

class CurrencyProvider with ChangeNotifier {
  CurrencyModel? currency;
  double currencyVal = 1.0;
  /* double.parse(appArray.currencyList[0]["USD"].toString()).roundToDouble()*/
  String priceSymbol = "\$";

  setVal() async {
    // Ensure that the state update happens after the current build cycle
    SharedPreferences pref = await SharedPreferences.getInstance();
    //  log("ERRROEEE getZoneList ${pref.getString(session.zoneIds)} ${zoneList[0].currency?.symbol}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currency != null) {
        priceSymbol = currency!.symbol!;
        currencyVal = double.parse(appArray.currencyList[0]["USD"].toString())
            .roundToDouble();
      }
      notifyListeners(); // Now safe to call after the build phase
    });
  }

  /* log("CCC : $currency");
    if (currency["title"] == appFonts.usDollar) {
      currencyVal =
          double.parse(currency["USD"].toString())
              .roundToDouble();
    } else if (currency["title"] == appFonts.euro) {
      currencyVal =
          double.parse(currency["EUR"].toString())
              .roundToDouble();
    } else if (currency["title"] == appFonts.inr) {
      currencyVal =
          double.parse(currency["INR"].toString())
              .roundToDouble();
    } else {
      currencyVal =
          double.parse(currency["POU"].toString())
              .roundToDouble();
    }
*/
  //  currencyVal =   double.parse(currency["code"].toString());
}
