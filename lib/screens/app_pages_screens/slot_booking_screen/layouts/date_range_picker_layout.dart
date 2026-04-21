import 'package:fixit_user/screens/app_pages_screens/slot_booking_screen/layouts/custom_table_date_range.dart';
import 'package:flutter/cupertino.dart';
import '../../../../config.dart';

class DateRangePickerLayout extends StatelessWidget {
  final bool isOffer;
  const DateRangePickerLayout({super.key, this.isOffer = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<SlotBookingProvider>(builder: (context1, value, child) {
      return AnimatedSize(
          duration: const Duration(microseconds: 300),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(translations?.selectDateOnly ?? "",
                    style: appCss.dmDenseMedium18
                        .textColor(appColor(context).darkText)),
                const Icon(CupertinoIcons.multiply)
                    .inkWell(onTap: () => route.pop(context))
              ]).paddingSymmetric(horizontal: Insets.i20, vertical: Insets.i15),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                CommonArrow(
                    arrow: eSvgAssets.arrowLeft,
                    onTap: () => value.onLeftArrow()),
                const HSpace(Sizes.s20),
                Text(
                    value.chosenValue != null ? value.chosenValue['title'] : "",
                    style: appCss.dmDenseMedium14
                        .textColor(appColor(context).darkText)),
                const HSpace(Sizes.s20),
                CommonArrow(
                    arrow: eSvgAssets.arrowRight,
                    onTap: () => value.onRightArrow()),
              ]).paddingSymmetric(horizontal: Insets.i10),
              const VSpace(Sizes.s15),
              const CustomTableDateRange(),
              const VSpace(Sizes.s15),
              ButtonCommon(
                      title: "${translations?.selectDateOnly}",
                      onTap: () => value.onSelect(context))
                  .paddingDirectional(horizontal: Insets.i20, bottom: Sizes.s20)
            ]),
          ));
    });
  }
}
