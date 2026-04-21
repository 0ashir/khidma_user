import '../../../config.dart';

class AddNewLocation extends StatefulWidget {
  const AddNewLocation({super.key});

  @override
  State<AddNewLocation> createState() => _AddNewLocationState();
}

class _AddNewLocationState extends State<AddNewLocation>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer<NewLocationProvider>(builder: (context1, value, child) {
      return Consumer<LocationProvider>(
          builder: (context2, locationCtrl, child) {
        return StatefulWrapper(
            onInit: () => Future.delayed(const Duration(milliseconds: 150),
                () => value.getOnInitData(context)),
            child: Scaffold(
                appBar: NewLocationAppBar(sync: this),
                body: SingleChildScrollView(
                    child: Form(
                  key: value.locationFormKey,
                  child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        textCommon.dmSensMediumDark14(context,
                            text: translations!.selectCategory),
                        const VSpace(Sizes.s20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: value.categoryList
                                .asMap()
                                .entries
                                .map((e) => SelectCategory(
                                    onTap: () => value.onCategory(e.key),
                                    data: e.value,
                                    index: e.key,
                                    selectedIndex: value.selectIndex))
                                .toList()),
                        const LocationTextFieldLayout()
                            .paddingSymmetric(vertical: Insets.i15),
                        textCommon.dmSensMediumDark14(context,
                            text: translations!.phoneNumber),
                        const VSpace(Sizes.s8),
                        RegisterWidgetClass().phoneTextBox(
                            context,
                            hPadding: 00,
                            dialCode: value.dialCode,
                            value.numberCtrl,
                            value.numberFocus,
                            isValidator: false,
                            onChanged: (CountryCodeCustom? code) =>
                                value.changeDialCode(code!),
                            onFieldSubmitted: (values) {
                              FocusScope.of(context).requestFocus(FocusNode());
                            }),
                        const VSpace(Sizes.s16),
                        Row(children: [
                          CheckBoxCommon(
                              isCheck: value.isCheck,
                              onTap: () =>
                                  value.isCheckBoxCheck(!value.isCheck)),
                          const HSpace(Sizes.s10),
                          Text(language(context, translations!.setAsPrimary),
                              style: appCss.dmDenseMedium14.textColor(
                                  !value.isCheck
                                      ? appColor(context)
                                          .primary
                                          .withValues(alpha: 0.5)
                                      : appColor(context).primary))
                        ]),
                        const VSpace(Sizes.s35),
                        ButtonCommon(
                            isLoading: value.isLoading,
                            title: value.isEdit
                                ? translations!.updateLocation ??
                                    language(context, appFonts.updateLocation)
                                : translations!.addLocation ??
                                    language(context, appFonts.addLocation),
                            onTap: () => value.onAddLocation(context))
                      ])
                      .paddingAll(Insets.i20)
                      .boxShapeExtension(
                          color: appColor(context).fieldCardBg,
                          radius: AppRadius.r12)
                      .padding(horizontal: Insets.i20, vertical: Insets.i20),
                ))));
      });
    });
  }
}
