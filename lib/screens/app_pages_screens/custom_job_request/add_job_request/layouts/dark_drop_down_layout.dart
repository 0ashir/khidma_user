import 'dart:developer';

import '../../../../../config.dart';

class DarkDropDownLayout extends StatelessWidget {
  final String? icon, hintText, val;
  final List? categoryList,
      durationList,
      reviewLowHighList,
      bookingFrequencyList;
  final ValueChanged? onChanged;
  final bool? isIcon, isField, isBig, isListIcon, isOnlyText;

  const DarkDropDownLayout(
      {super.key,
      this.icon,
      this.hintText,
      this.val,
      this.onChanged,
      this.isField = false,
      this.isIcon = false,
      this.isBig = false,
      this.categoryList,
      this.isListIcon = false,
      this.isOnlyText = false,
      this.durationList,
      this.bookingFrequencyList,
      this.reviewLowHighList});

  @override
  Widget build(BuildContext context) {
    log("categoryList :$val");
    return DropdownButtonHideUnderline(
            child: ButtonTheme(
                child: DropdownButtonFormField(
                    value: val,
                    hint: Text(language(context, hintText ?? ""),
                        style: appCss.dmDenseRegular14
                            .textColor(appColor(context).lightText)),
                    decoration: InputDecoration(
                        prefixIcon: isIcon == true
                            ? SvgPicture.asset(icon!,
                                fit: BoxFit.scaleDown,
                                colorFilter: ColorFilter.mode(
                                    appColor(context).darkText,
                                    BlendMode.srcIn))
                            : null,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        disabledBorder: noneDecoration(),
                        focusedBorder: noneDecoration(),
                        enabledBorder: noneDecoration(),
                        border: noneDecoration()),
                    padding: EdgeInsets.zero,
                    borderRadius:
                        const BorderRadius.all(Radius.circular(AppRadius.r8)),
                    style: appCss.dmDenseMedium14
                        .textColor(appColor(context).darkText),
                    icon: SvgPicture.asset(eSvgAssets.dropDown,
                        colorFilter: ColorFilter.mode(
                            val == null
                                ? appColor(context).lightText
                                : appColor(context).darkText,
                            BlendMode.srcIn)),
                    isDense: true,
                    isExpanded: true,
                    items: reviewLowHighList != null &&
                            reviewLowHighList!.isNotEmpty
                        ? reviewLowHighList!.asMap().entries.map((e) {
                            return DropdownMenuItem(
                                value: e.value['id'],
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isListIcon == true)
                                      SizedBox(
                                              height: Sizes.s13,
                                              width: Sizes.s13,
                                              child: SvgPicture.asset(
                                                e.value["image"],
                                                fit: BoxFit.scaleDown,
                                              ))
                                          .paddingAll(Insets.i4)
                                          .decorated(
                                              color:
                                                  appColor(context).fieldCardBg,
                                              shape: BoxShape.circle),
                                    if (isListIcon == true)
                                      const HSpace(Sizes.s12),
                                    Text(
                                        capitalizeFirstLetter(language(
                                            context, e.value['title'])),
                                        style: appCss.dmDenseRegular14
                                            .textColor(
                                                appColor(context).darkText)),
                                  ],
                                ));
                          }).toList()
                        : durationList != null
                            ? durationList!.asMap().entries.map((e) {
                                return DropdownMenuItem(
                                    value: e.value,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isListIcon == true)
                                          SizedBox(
                                                  height: Sizes.s13,
                                                  width: Sizes.s13,
                                                  child: SvgPicture.asset(
                                                    e.value["image"],
                                                    fit: BoxFit.scaleDown,
                                                  ))
                                              .paddingAll(Insets.i4)
                                              .decorated(
                                                  color: appColor(context)
                                                      .fieldCardBg,
                                                  shape: BoxShape.circle),
                                        if (isListIcon == true)
                                          const HSpace(Sizes.s12),
                                        Text(
                                            capitalizeFirstLetter(
                                                language(context, e.value)),
                                            style: appCss.dmDenseRegular14
                                                .textColor(appColor(context)
                                                    .darkText)),
                                      ],
                                    ));
                              }).toList()
                            : bookingFrequencyList != null
                                ? bookingFrequencyList!
                                    .asMap()
                                    .entries
                                    .map((e) {
                                    return DropdownMenuItem(
                                        value: e.value,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isListIcon == true)
                                              SizedBox(
                                                      height: Sizes.s13,
                                                      width: Sizes.s13,
                                                      child: SvgPicture.asset(
                                                        e.value["image"],
                                                        fit: BoxFit.scaleDown,
                                                      ))
                                                  .paddingAll(Insets.i4)
                                                  .decorated(
                                                      color: appColor(context)
                                                          .fieldCardBg,
                                                      shape: BoxShape.circle),
                                            if (isListIcon == true)
                                              const HSpace(Sizes.s12),
                                            Text(
                                                capitalizeFirstLetter(
                                                    language(context, e.value)),
                                                style: appCss.dmDenseRegular14
                                                    .textColor(appColor(context)
                                                        .darkText)),
                                          ],
                                        ));
                                  }).toList()
                                : categoryList!.asMap().entries.map((e) {
                                    return DropdownMenuItem(
                                        value: e.value,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isListIcon == true)
                                              SizedBox(
                                                      height: Sizes.s13,
                                                      width: Sizes.s13,
                                                      child: SvgPicture.asset(
                                                        e.value["image"],
                                                        fit: BoxFit.scaleDown,
                                                      ))
                                                  .paddingAll(Insets.i4)
                                                  .decorated(
                                                      color: appColor(context)
                                                          .fieldCardBg,
                                                      shape: BoxShape.circle),
                                            if (isListIcon == true)
                                              const HSpace(Sizes.s12),
                                            Text(
                                                capitalizeFirstLetter(language(
                                                    context,
                                                    e.value ?? e.value)),
                                                style: appCss.dmDenseRegular14
                                                    .textColor(appColor(context)
                                                        .darkText)),
                                          ],
                                        ));
                                  }).toList(),
                    onChanged: onChanged)))
        .padding(
            vertical: isBig == true
                ? Insets.i14
                : isOnlyText == true
                    ? Insets.i6
                    : 0,
            left: isIcon == false
                ? rtl(context)
                    ? Insets.i15
                    : Insets.i10
                : rtl(context)
                    ? Insets.i15
                    : Insets.i2,
            right: rtl(context) ? 10 : Insets.i10)
        .decorated(
            color: isField == true
                ? appColor(context).fieldCardBg
                : appColor(context).whiteBg,
            borderRadius: BorderRadius.circular(AppRadius.r8));
  }
}

OutlineInputBorder noneDecoration() => const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadius.r8)),
    borderSide: BorderSide.none);
