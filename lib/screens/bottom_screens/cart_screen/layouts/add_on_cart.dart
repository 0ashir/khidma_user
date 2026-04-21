import 'package:fixit_user/screens/app_pages_screens/services_details_screen/layouts/add_on_service_card.dart';

import '../../../../config.dart';

class AddOnServiceCart extends StatelessWidget {
  final Services? data;
  const AddOnServiceCart({
    super.key,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height / 2.8,
        width: MediaQuery.of(context).size.width,
        decoration: ShapeDecoration(
            shape: const SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.only(
                    topLeft: SmoothRadius(
                        cornerRadius: AppRadius.r20, cornerSmoothing: 1),
                    topRight: SmoothRadius(
                        cornerRadius: AppRadius.r20, cornerSmoothing: 0.4))),
            color: appColor(context).whiteBg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language(context, translations!.addOns),
                    style: appCss.dmDenseMedium14
                        .textColor(appColor(context).darkText))
                .paddingSymmetric(horizontal: Sizes.s20, vertical: Sizes.s10),
            const VSpace(Sizes.s10),
            ...data!.selectedAdditionalServices!.asMap().entries.map((e) =>
                AddOnServiceCard(
                    isIconShow: false,
                    additionalServices: e.value,
                    index: e.key,
                    additionalServicesLength:
                        data!.selectedAdditionalServices!.length - 1))
          ],
        ));
  }
}
