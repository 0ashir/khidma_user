import 'package:flutter/cupertino.dart';
import '../../../../../config.dart';

class WeekBottomSheet extends StatelessWidget {
  const WeekBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Consumer<SlotBookingProvider>(builder: (context1, value, child) {
        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.95,
              minChildSize: 0.3,
              expand: false,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Stack(children: [
                  ListView(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language(context, translations!.selectWeekdays),
                              style: appCss.dmDenseMedium18
                                  .textColor(appColor(context).darkText)),
                          const Icon(CupertinoIcons.multiply)
                              .inkWell(onTap: () => route.pop(context))
                        ]).paddingSymmetric(horizontal: Insets.i20),
                    const VSpace(Sizes.s15),
                    ...appArray.weekdayList.asMap().entries.map((e) {
                      bool isSelected = value.newWeekDayList.contains(e.value);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                Image.asset(eImageAssets.noImageFound1,
                                    height: Sizes.s20, width: Sizes.s20),
                                VerticalDivider(
                                        indent: 4,
                                        endIndent: 4,
                                        width: 1,
                                        color: appColor(context).stroke)
                                    .paddingSymmetric(horizontal: Insets.i12),
                                Text(e.value,
                                    style: appCss.dmDenseMedium14
                                        .textColor(appColor(context).darkText)),
                              ],
                            ),
                          ),
                          CheckBoxCommon(
                              isCheck: isSelected,
                              onTap: () => value.onChangeWeekDay(e.value))
                        ],
                      )
                          .paddingSymmetric(
                              vertical: Insets.i12, horizontal: Insets.i15)
                          .boxBorderExtension(context,
                              isShadow: true, bColor: const Color(0xFFF5F6F7))
                          .padding(horizontal: Insets.i20, bottom: Insets.i12)
                          .inkWell(onTap: () => value.onChangeWeekDay(e.value));
                    })
                  ])
                      .paddingSymmetric(vertical: Insets.i20)
                      .marginOnly(bottom: Insets.i80),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: BottomSheetButtonCommon(
                              textOne: translations!.clearAll,
                              textTwo: translations!.apply,
                              applyTap: () {
                                route.pop(context);
                              },
                              clearTap: () {
                                value.newWeekDayList.clear();
                                value.notifyListeners();
                                route.pop(context);
                              })
                          .padding(horizontal: Sizes.s20, bottom: Sizes.s20)
                          .backgroundColor(appColor(context).whiteBg))
                ]).bottomSheetExtension(context);
              }),
        );
      });
    });
  }
}
