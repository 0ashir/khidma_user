import 'package:fixit_user/providers/app_pages_providers/job_request_providers/add_job_request_provider.dart';
import 'package:flutter/services.dart';

import '../../../../../config.dart';
import 'common_description_box.dart';
import 'dark_drop_down_layout.dart';

class FormCategoryLayout extends StatelessWidget {
  const FormCategoryLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final value = Provider.of<AddJobRequestProvider>(context);
    return Column(children: [
      /* ContainerWithTextLayout(title: language(context, translations!.categories))
          .paddingOnly(top: Insets.i24, bottom: Insets.i12),
      const CategorySelectionLayout(),*/
      ContainerWithTextLayout(
              title: language(context, translations!.description))
          .paddingOnly(top: Insets.i24, bottom: Insets.i12),
      CommonDescriptionBox(
          focusNode: value.descriptionFocus, description: value.description),
      ContainerWithTextLayout(title: language(context, translations!.duration))
          .paddingOnly(top: Insets.i24, bottom: Insets.i12),
      Row(children: [
        Expanded(
            flex: 1,
            child: TextFieldCommon(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final text = newValue.text;
                    if (text.isEmpty) {
                      return newValue;
                    }
                    if (text.length == 2) {
                      final number = int.tryParse(text);
                      if (number != null && number >= 10 && number <= 99) {
                        return newValue;
                      }
                      return oldValue;
                    }
                    if (text.length == 1 && RegExp(r'[1-9]').hasMatch(text)) {
                      return newValue;
                    }
                    return oldValue;
                  }),
                ],
                focusNode: value.durationFocus,
                controller: value.duration,
                hintText: translations!.addServiceTime!,
                prefixIcon: eSvgAssets.timer)),
        const HSpace(Sizes.s6),
        Expanded(
            child: DarkDropDownLayout(
                isBig: true,
                val: value.durationValue,
                hintText: translations!.hour,
                isIcon: false,
                durationList: appArray.durationList,
                onChanged: (val) => value.onChangeDuration(val)))
      ]).paddingSymmetric(horizontal: Insets.i20),
      ContainerWithTextLayout(
              title: language(context, translations!.minRequiredServiceman))
          .paddingOnly(top: Insets.i24, bottom: Insets.i12),
      TextFieldCommon(
              keyboardType: TextInputType.number,
              focusNode: value.minRequiredFocus,
              controller: value.minRequired,
              hintText: translations!.addNoOfServiceman!,
              prefixIcon: eSvgAssets.tagUser)
          .paddingSymmetric(horizontal: Insets.i20)
    ]);
  }
}
