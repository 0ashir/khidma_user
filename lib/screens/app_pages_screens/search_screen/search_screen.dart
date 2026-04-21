import 'package:fixit_user/config.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer2<DashboardProvider, SearchProvider>(
        builder: (context, dash, value, child) {
      return StatefulWrapper(
          onInit: () => Future.delayed(
                const Duration(milliseconds: 150),
                () => value.onAnimate(context, this),
              ),
          child: PopScope(
              canPop: true,
              onPopInvoked: (didPop) => value.onBack(context),
              child: Scaffold(
                  appBar: AppBarCommon(
                    title: translations!.search,
                    onTap: () {
                      route.pop(context);
                      value.onBack(context);
                    },
                  ),
                  body: SingleChildScrollView(child:
                      Consumer<CartProvider>(builder: (context, cart, child) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SearchTextFieldCommon(
                              focusNode: value.searchFocus,
                              controller: value.searchCtrl,
                              onChanged: (v) =>
                                  value.onSearchChanged(v, context),
                              onFieldSubmitted: (v) =>
                                  value.searchService(context),
                              suffixIcon: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (value.searchCtrl.text.isNotEmpty)
                                      Icon(Icons.cancel,
                                              color: appColor(context).darkText)
                                          .inkWell(
                                              onTap: () => value.searchClear()),
                                    const HSpace(Sizes.s5),
                                    FilterIconCommon(
                                        selectedFilter:
                                            value.totalCountFilter(),
                                        onTap: () =>
                                            value.onBottomSheet(context))
                                  ])),
                          const VSpace(Sizes.s25),
                          if (value.searchList.isEmpty &&
                              (value.searchCtrl.text.isEmpty))
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: value.topServices().length,
                                itemBuilder: (context, index) {
                                  final service = value.topServices()[index];
                                  return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      child: Row(children: [
                                        Icon(Icons.trending_up,
                                            color: appColor(context).darkText),
                                        const HSpace(Sizes.s10),
                                        GestureDetector(
                                            onTap: () {
                                              value.searchCtrl.text = service;
                                              value.searchCtrl.selection =
                                                  TextSelection.fromPosition(
                                                      TextPosition(
                                                          offset: value
                                                              .searchCtrl
                                                              .text
                                                              .length));
                                              value.onSearchChanged(service,
                                                  context); // Optional: trigger search
                                            },
                                            child: Text(service,
                                                    overflow: TextOverflow.fade,
                                                    style: appCss
                                                        .dmDenseMedium14
                                                        .textColor(
                                                            appColor(context)
                                                                .darkText))
                                                .width(250)),
                                      ]));
                                }),

                          if (value.recentSearchList.isNotEmpty &&
                              (value.searchCtrl.text.isEmpty &&
                                  value.isSearch!))
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      language(
                                          context, translations!.recentSearch),
                                      style: appCss.dmDenseMedium14.textColor(
                                          appColor(context).lightText),
                                    ),
                                    if (value.recentSearchList.isNotEmpty)
                                      TextButton(
                                        onPressed: () =>
                                            value.clearRecentSearches(),
                                        child: Text(
                                          "Clear",
                                          style: appCss.dmDenseMedium14
                                              .textColor(
                                                  appColor(context).primary),
                                        ),
                                      ),
                                  ],
                                ),
                                const VSpace(Sizes.s15),
                                ...value.recentSearchList
                                    .asMap()
                                    .entries
                                    .map((e) {
                                  return FeaturedServicesLayout(
                                    data: e.value,
                                    // inCart: isInCart(context, e.value.id),
                                    onTap: () => value.onTapFeatures(
                                        context, e.value, e.key),
                                    addTap: () async {
                                      SharedPreferences pref =
                                          await SharedPreferences.getInstance();
                                      if (pref.getBool(
                                              session.isContinueAsGuest) ==
                                          true) {
                                        route.pushNamedAndRemoveUntil(
                                            context, routeName.login);
                                      } else {
                                        value.onFeatured(
                                            context, e.value, e.key,
                                            inCart:
                                                isInCart(context, e.value.id));
                                      }
                                    },
                                  );
                                }),
                              ],
                            ),
                          // Loading or search results
                          if (value.isSearchLoading!)
                            Center(
                                    child: Image.asset(eGifAssets.loader,
                                        height: Sizes.s100))
                                .paddingOnly(top: 200)
                          else if (value.searchList.isNotEmpty)
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      language(
                                          context, translations!.recentSearch),
                                      style: appCss.dmDenseMedium14.textColor(
                                          appColor(context).lightText)),
                                  const VSpace(Sizes.s15),
                                  ...value.searchList.asMap().entries.map((e) {
                                    return FeaturedServicesLayout(
                                        data: e.value,
                                        // inCart: isInCart(context, e.value.id),
                                        onTap: () => value.onTapFeatures(
                                            context, e.value, e.key),
                                        addTap: () async {
                                          SharedPreferences pref =
                                              await SharedPreferences
                                                  .getInstance();
                                          if (pref.getBool(
                                                  session.isContinueAsGuest) ==
                                              true) {
                                            route.pushNamedAndRemoveUntil(
                                                context, routeName.login);
                                          } else {
                                            value.onFeatured(
                                                context, e.value, e.key,
                                                inCart: isInCart(
                                                    context, e.value.id));
                                          }
                                        });
                                  })
                                ])
                          else if (value.searchCtrl.text.isNotEmpty &&
                              value.isSearch!)
                            SingleChildScrollView(
                                child: EmptyLayout(
                                    title: translations!.noMatching,
                                    subtitle: translations!.attemptYourSearch,
                                    isButtonShow: false,
                                    buttonText: translations!.searchAgain,
                                    bTap: () => value.searchClear(),
                                    widget: Stack(children: [
                                      Image.asset(eImageAssets.noSearch,
                                              height: Sizes.s240)
                                          .paddingOnly(top: Insets.i40),
                                      if (value.animationController != null)
                                        Positioned(
                                            left: -10,
                                            top: 30,
                                            child: RotationTransition(
                                                turns: Tween(
                                                        begin: 0.01, end: -0.01)
                                                    .chain(CurveTween(
                                                        curve: Curves.easeIn))
                                                    .animate(value
                                                        .animationController!),
                                                child: Image.asset(
                                                    eImageAssets.mGlass,
                                                    height: Sizes.s80,
                                                    width: Sizes.s178)))
                                    ]))).paddingDirectional(top: Sizes.s50)
                        ]).paddingSymmetric(horizontal: Insets.i20);
                  })))));
    });
  }
}
