// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:fixit_user/config.dart';

class ToggleButtonsWidget extends StatelessWidget {
  const ToggleButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpertServiceProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          height: Sizes.s50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  textAlign: TextAlign.center,
                  'List View',
                  style: provider.isMapView == false
                      ? appCss.dmDenseMedium14
                          .textColor(appColor(context).whiteBg)
                      : appCss.dmDenseRegular14
                          .textColor(appColor(context).lightText),
                ).padding(vertical: Insets.i9),
              )
                  .inkWell(onTap: () {
                    provider.isMapView = false;
                    provider.notifyListeners();
                  })
                  .decorated(
                      color: provider.isMapView == false
                          ? appColor(context).primary
                          : null,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(Insets.i20),
                        bottomLeft: Radius.circular(Insets.i20),
                      ))
                  .expanded(),
              const SizedBox(width: 5),
              Container(
                child: Text(
                  textAlign: TextAlign.center,
                  'Map View',
                  style: provider.isMapView == true
                      ? appCss.dmDenseMedium14
                          .textColor(appColor(context).whiteBg)
                      : appCss.dmDenseRegular14
                          .textColor(appColor(context).lightText),
                ).padding(vertical: Insets.i9),
              )
                  .inkWell(onTap: () {
                    provider.isMapView = true;
                    provider.notifyListeners();
                  })
                  .decorated(
                      color: provider.isMapView == true
                          ? appColor(context).primary
                          : null,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(Insets.i20),
                        bottomRight: Radius.circular(Insets.i20),
                      ))
                  .expanded(),
            ],
          ).padding(horizontal: Insets.i5),
        )
            .decorated(
                color: appColor(context).fieldCardBg,
                borderRadius: BorderRadius.circular(Insets.i30))
            .padding(horizontal: Insets.i20);
      },
    );
  }
}
