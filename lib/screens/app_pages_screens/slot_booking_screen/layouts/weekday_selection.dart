import '../../../../../config.dart';

class WeekDaySelectionLayout extends StatelessWidget {
  const WeekDaySelectionLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SlotBookingProvider>(
      builder: (context, value, child) {
        return Container(
          // margin: const EdgeInsets.symmetric(horizontal: Sizes.s20),
          padding: const EdgeInsets.symmetric(
              horizontal: Sizes.s15, vertical: Sizes.s10),
          decoration: ShapeDecoration(
            color: appColor(context).whiteBg,
            shape: SmoothRectangleBorder(
              side: BorderSide(color: appColor(context).stroke),
              borderRadius:
                  SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const HSpace(Sizes.s12),

                    /// Selected weekdays
                    // if (value.newWeekDayList.isNotEmpty)
                    //   Expanded(
                    //     child: Wrap(
                    //       children: value.newWeekDayList
                    //           .asMap()
                    //           .entries
                    //           .map(
                    //             (e) => Container(
                    //               margin: EdgeInsets.only(
                    //                 bottom:
                    //                     value.newWeekDayList.length - 1 != e.key
                    //                         ? Sizes.s8
                    //                         : 0,
                    //                 right: Sizes.s5,
                    //               ),
                    //               padding: const EdgeInsets.symmetric(
                    //                 horizontal: Sizes.s9,
                    //                 vertical: Sizes.s5,
                    //               ),
                    //               decoration: ShapeDecoration(
                    //                 color:
                    //                     const Color.fromRGBO(84, 101, 255, 0.1),
                    //                 shape: SmoothRectangleBorder(
                    //                   borderRadius: SmoothBorderRadius(
                    //                     cornerRadius: 8,
                    //                     cornerSmoothing: 1,
                    //                   ),
                    //                 ),
                    //               ),
                    //               child: Row(
                    //                 mainAxisSize: MainAxisSize.min,
                    //                 children: [
                    //                   SvgPicture.asset(
                    //                     eSvgAssets.cross,
                    //                     height: 16,
                    //                     colorFilter: ColorFilter.mode(
                    //                       appColor(context).primary,
                    //                       BlendMode.srcIn,
                    //                     ),
                    //                   ).inkWell(
                    //                     onTap: () =>
                    //                         value.onChangeWeekDay(e.value),
                    //                   ),
                    //                   const HSpace(Sizes.s2),
                    //                   Text(
                    //                     e.value,
                    //                     style: appCss.dmDenseLight14.textColor(
                    //                       appColor(context).primary,
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           )
                    //           .toList(),
                    //     ),
                    //   ),

                    // /// Placeholder
                    // if (value.newWeekDayList.isEmpty)
                    //   Text(
                    //     language(context, translations!.selectWeekdays),
                    //     style: appCss.dmDenseMedium14
                    //         .textColor(appColor(context).lightText),
                    //   ),
                    Expanded(
                      child: value.newWeekDayList.isEmpty
                          ? Text(
                              language(
                                  context,
                                  translations!.selectWeekdays ??
                                      "Select Weekdays"),
                              style: appCss.dmDenseMedium14
                                  .textColor(appColor(context).lightText),
                            )
                          : Wrap(
                              children: value.newWeekDayList.map((day) {
                                return Container(
                                  margin: const EdgeInsets.only(
                                    right: Sizes.s5,
                                    bottom: Sizes.s8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Sizes.s9,
                                    vertical: Sizes.s5,
                                  ),
                                  decoration: ShapeDecoration(
                                    color:
                                        const Color.fromRGBO(84, 101, 255, 0.1),
                                    shape: SmoothRectangleBorder(
                                      borderRadius: SmoothBorderRadius(
                                        cornerRadius: 8,
                                        cornerSmoothing: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        eSvgAssets.cross,
                                        height: 16,
                                        colorFilter: ColorFilter.mode(
                                          appColor(context).primary,
                                          BlendMode.srcIn,
                                        ),
                                      ).inkWell(
                                        onTap: () => value.onChangeWeekDay(day),
                                      ),
                                      const HSpace(Sizes.s2),
                                      Text(
                                        day,
                                        style: appCss.dmDenseLight14.textColor(
                                          appColor(context).primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                eSvgAssets.dropDown,
                colorFilter: ColorFilter.mode(
                  value.newWeekDayList.isNotEmpty
                      ? appColor(context).darkText
                      : appColor(context).lightText,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ).inkWell(
          onTap: value.isTap! ? null : () => value.onWeekBottomSheet(context),
        );
      },
    );
  }
}
