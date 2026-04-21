import '../../../config.dart';

class FavouriteListScreen extends StatelessWidget {
  const FavouriteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, FavouriteListProvider>(
        builder: (context1, lang, value, child) {
      return PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          value.onBack(context, false);
          if (didPop) return;
        },
        child: Scaffold(
            appBar: AppBar(
                leadingWidth: 80,
                title: Text(language(context, translations!.favouriteList),
                    style: appCss.dmDenseBold18
                        .textColor(appColor(context).darkText)),
                centerTitle: true,
                leading: CommonArrow(
                        arrow: rtl(context)
                            ? eSvgAssets.arrowRight
                            : eSvgAssets.arrowLeft,
                        onTap: () => value.onBack(context, true))
                    .paddingDirectional(vertical: Insets.i8)),
            body: RefreshIndicator(
              onRefresh: () async {
                // showLoading(context);
                // value.notifyListeners();
                value.getFavourite(context1);
                // hideLoading(context);
                // value.notifyListeners();
              },
              child: ListView(children: [
                Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    height: Sizes.s50,
                    decoration: BoxDecoration(
                        color: appColor(context).fieldCardBg,
                        borderRadius: const BorderRadius.all(
                            Radius.circular(AppRadius.r30))),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: appArray.favouriteTabList
                            .asMap()
                            .entries
                            .map((e) => TapLayout(
                                data: e.value,
                                index: e.key,
                                selectedIndex: value.selectedIndex,
                                onTap: () => value.onChangeList(e.key)))
                            .toList())),
                const VSpace(Sizes.s25),
                Text(
                    language(
                        context,
                        value.selectedIndex == 0
                            ? translations!.providerList
                            : translations!.serviceList),
                    style: appCss.dmDenseRegular14
                        .textColor(appColor(context).lightText)),
                const VSpace(Sizes.s15),
                value.selectedIndex == 0
                    ? SearchTextFieldCommon(
                        onChanged: (v) {
                          if (v.isEmpty) {
                            value.getFavourite(context);
                          } else if (v.length > 3) {
                            value.getFavourite(context);
                          }
                        },
                        onFieldSubmitted: (val) => value.getFavourite(context),
                        controller: value.providerCtrl,
                        focusNode: value.searchFocus)
                    : SearchTextFieldCommon(
                        onChanged: (v) {
                          if (v.isEmpty) {
                            value.getFavourite(context);
                          } else if (v.length > 3) {
                            value.getFavourite(context);
                          }
                        },
                        onFieldSubmitted: (val) => value.getFavourite(context),
                        controller: value.serviceCtrl,
                        focusNode: value.serviceSearchFocus),
                const VSpace(Sizes.s20),
                FavouriteListBody(index: value.selectedIndex)
              ]).paddingAll(Insets.i20),
            )),
      );
    });
  }
}
