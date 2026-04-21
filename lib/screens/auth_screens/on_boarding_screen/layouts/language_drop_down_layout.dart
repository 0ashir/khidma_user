import '../../../../config.dart';

class LanguageDropDownLayout extends StatelessWidget {
  const LanguageDropDownLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<OnBoardingProvider, LanguageProvider>(
        builder: (context, onBoardingCtrl, langProvider, child) {
      // log("languageCtrl.currentLanguage::${langProvider.currentLanguage}");
      //og("Language List: ${langProvider.sharedPreferences.getString("selectedLocale")}");
      String? val = langProvider.sharedPreferences.getString("selectedLocale");
      final currentLanguage =
          langProvider.languageList.any((element) => element.locale == val)
              ? langProvider.languageList
                  .firstWhere((element) => element.locale == val)
                  .name
              : null;

      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          /* SizedBox(
            width: Sizes.s100,
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                child: DropdownButton(
                  value: currentLanguage,
                  borderRadius:
                      const BorderRadius.all(Radius.circular(AppRadius.r8)),
                  style: appCss.dmDenseMedium16
                      .textColor(appColor(context).lightText),
                  icon: SvgPicture.asset(eSvgAssets.dropDown,
                      colorFilter: ColorFilter.mode(
                          appColor(context).darkText, BlendMode.srcIn)),
                  isDense: true,
                  isExpanded: true,
                  hint: Text(langProvider.sharedPreferences
                          .getString("selectedLocale")
                          .toString() /* ??
                      "Select Language" */
                      ),
                  items: langProvider.languageList.map((e) {
                    return DropdownMenuItem(
                      value: e.name, // Use the 'title' as value
                      child: Text(e.name.toString()),
                    );
                  }).toList(),
                  onChanged: (val) async {
                    int index = langProvider.languageList
                        .indexWhere((element) => element.name == val);
                    if (index != -1) {
                      // Only proceed if a matching language is found
                      SystemLanguage systemLanguage =
                          langProvider.languageList[index];
                      langProvider.currentLanguage = val.toString();
                      langProvider.changeLocale(systemLanguage);
                      langProvider.setIndex(index);
                      log("langProvider.currentLanguage: ${langProvider.currentLanguage}");
                    } else {
                      log("Error: Selected value '$val' not found in languageList.");
                      // Optionally, handle this case (e.g., reset the dropdown)
                    }
                  },
                ),
              ),
            ).paddingAll(Insets.i7).decorated(
                  color: appColor(context).whiteBg,
                  borderRadius: BorderRadius.circular(AppRadius.r6),
                  boxShadow: isDark(context)
                      ? []
                      : [
                          BoxShadow(
                            color: appColor(context).fieldCardBg,
                            blurRadius: AppRadius.r10,
                            spreadRadius: AppRadius.r5,
                          )
                        ],
                  border: Border.all(color: appColor(context).fieldCardBg),
                ),
          ), */
          /*  if (onBoardingCtrl.selectIndex != appArray.onBoardingList.length - 1) */
          Text(language(context, translations!.skip),
                  style: appCss.dmDenseMedium14
                      .textColor(appColor(context).lightText))
              .inkWell(onTap: () {
            final loc = Provider.of<LocationProvider>(context, listen: false);
            loc.getZoneId(context, isLocation: false);
            onBoardingCtrl.onSkip(context);
          })
        ],
      );
    });
  }
}
