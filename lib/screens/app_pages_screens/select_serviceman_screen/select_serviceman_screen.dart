import 'dart:developer';

import 'package:fixit_user/common_tap.dart';

import '../../../config.dart';

class SelectServiceScreen extends StatelessWidget {
  const SelectServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectServicemanProvider>(
        builder: (context1, value, child) {
      return StatefulWrapper(
          onInit: () => Future.delayed(
              const Duration(milliseconds: 100), () => value.onReady(context)),
          child: WillPopScope(
            onWillPop: () async {
              value.onBack();
              return true;
            },
            child: Scaffold(
                appBar: AppBarCommon(
                  title: translations!.selectServiceman,
                  onTap: () {
                    value.onBack();
                    route.pop(context);
                  },
                ),
                body: Stack(children: [
                  ListView(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          language(
                              context, translations!.includedServiceInPackage),
                          style: appCss.dmDenseMedium14
                              .textColor(appColor(context).darkText)),
                      const VSpace(Sizes.s15),
                      /*  ListView.builder(
                          shrinkWrap: true,
                          itemCount: servicePackageList.length,
                          itemBuilder: (context, index) {
                            return ServicePackageLayout(
                                data: servicePackageList[index],
                                onTap: () {
                                  final providerDetail =
                                      Provider.of<ProviderDetailsProvider>(
                                          context,
                                          listen: false);
                                  providerDetail.selectProviderIndex = 0;
                                  providerDetail.notifyListeners();
                                  print(
                                      "object=======> ${servicePackageList[index].id}");
                                  onBook(context, servicePackageList[index],
                                      isPackage: true,
                                      packageServiceId:
                                          servicePackageList[index].id,
                                      addTap: () => value
                                          .onAdd(servicePackageList[index].id),
                                      minusTap: () => value.onRemoveService(
                                          context, servicePackageList[index]));
                                });
                          }), */
                      // VSpace(Sizes.s120),
                      ...servicePackageList
                          .asMap()
                          .entries
                          .map((e) => ServicePackageLayout(
                              data: e.value,
                              onTap: () {
                                final providerDetail =
                                    Provider.of<ProviderDetailsProvider>(
                                        context,
                                        listen: false);
                                providerDetail.selectProviderIndex = 0;
                                providerDetail.notifyListeners();
                                log("e.value:::${e.value.id}///${e.key}");
                                onBook(context, e.value,
                                    isPackage: true,
                                    packageServiceId: e.key,
                                    addTap: () => value.onAdd(e.key),
                                    minusTap: () =>
                                        value.onRemoveService(context, e.key));
                              }))
                    ],
                  ).paddingDirectional(
                      horizontal: Insets.i20, bottom: Sizes.s80),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ButtonCommon(
                            onTap: value.buttonVisible(context)
                                ? () => value.addToCart(context)
                                : () {},
                            title: translations!.confirmBooking!,
                            color: value.buttonVisible(context)
                                ? appColor(context).primary
                                : appColor(context).stroke,
                            style: appCss.dmDenseMedium16.textColor(
                                value.buttonVisible(context)
                                    ? appColor(context).whiteBg
                                    : appColor(context).lightText))
                        .paddingSymmetric(horizontal: Insets.i20)
                        .paddingOnly(bottom: Insets.i20),
                  )
                ])),
          ));
    });
  }
}
