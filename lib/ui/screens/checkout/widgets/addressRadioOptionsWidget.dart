import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AddressRadioOptionsWidget extends StatelessWidget {
  // final String image;
  final String title;
  final String value;
  final String groupValue;
  final Function(Object?)? onChanged;
  final bool? applyAccentColor;
  final String subTitle;

  const AddressRadioOptionsWidget({
    super.key,
    // required this.image,
    required this.title,
    required this.value,
    required this.subTitle,
    required this.groupValue,
    this.onChanged,
    this.applyAccentColor = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged
            ?.call(value); // Trigger the onChanged callback with the new value
      },
      child: CustomContainer(
          padding: const EdgeInsetsDirectional.symmetric(
              vertical: 12, horizontal: 12),
          color: value == groupValue
              ? context.colorScheme.accentColor.withAlpha(5)
              : context.colorScheme.blackColor.withAlpha(5),
          borderRadius: UiUtils.borderRadiusOf10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title.toString()
                          .toLowerCase()
                          .translate(context: context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                    ),
                    CustomText(
                      subTitle,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: context.colorScheme.lightGreyColor,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: value == groupValue
                      ? CustomSvgPicture(
                          svgImage: AppAssets.icCheck,
                          color: context.colorScheme.accentColor)
                      : null,
                ),
              ),
            ],
          )),
    );
  }
}
