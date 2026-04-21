import 'package:fixit_user/screens/app_pages_screens/add_new_location/layouts/county_drop_down.dart';
import 'package:fixit_user/screens/app_pages_screens/add_new_location/layouts/state_drop_down.dart';

import '../../../../config.dart';

class LocationTextFieldLayout extends StatelessWidget {
  const LocationTextFieldLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NewLocationProvider>(builder: (context2, value, child) {
      return Consumer<LocationProvider>(
          builder: (context2, locationCtrl, child) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          textCommon.dmSensMediumDark14(context, text: translations!.street),
          const VSpace(Sizes.s8),
          TextFieldCommon(
              validator: (add) => validation.addressValidation(context, add),
              controller: value.streetCtrl,
              hintText:
                  translations!.street ?? language(context, appFonts.street),
              focusNode: value.streetFocus,
              prefixIcon: eSvgAssets.address),
          const VSpace(Sizes.s15),
          textCommon.dmSensMediumDark14(context, text: translations!.country),
          const VSpace(Sizes.s8),
          const CountryDropDown(),
          const VSpace(Sizes.s15),
          textCommon.dmSensMediumDark14(context, text: translations!.state),
          const VSpace(Sizes.s8),
          const StateDropDown(),
          const VSpace(Sizes.s18),
          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  textCommon.dmSensMediumDark14(context,
                      text: translations!.city),
                  const VSpace(Sizes.s8),
                  TextFieldCommon(
                      validator: (city) =>
                          validation.cityValidation(context, city),
                      controller: value.cityCtrl,
                      focusNode: value.cityFocus,
                      hintText: translations!.city ??
                          language(context, appFonts.city),
                      prefixIcon: eSvgAssets.cityLoc)
                ])),
            const HSpace(Sizes.s18),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  textCommon.dmSensMediumDark14(context,
                      text: translations!.zipCode),
                  const VSpace(Sizes.s8),
                  TextFieldCommon(
                      validator: (zip) =>
                          validation.cityValidation(context, zip),
                      controller: value.zipCtrl,
                      focusNode: value.zipFocus,
                      hintText: translations!.zipCode ??
                          language(context, appFonts.zipCode),
                      prefixIcon: eSvgAssets.zipcode)
                ]))
          ]),
          const VSpace(Sizes.s15),
          textCommon.dmSensMediumDark14(context,
              text: translations!.personName),
          const VSpace(Sizes.s8),
          TextFieldCommon(
              controller: value.nameCtrl,
              /* validator:  (zip) => validation.nameValidation(context, zip), */
              focusNode: value.nameFocus,
              hintText: translations!.personName ??
                  language(context, appFonts.personName),
              prefixIcon: eSvgAssets.user)
        ]);
      });
    });
  }
}
