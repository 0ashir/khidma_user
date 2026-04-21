// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:fixit_user/screens/app_pages_screens/expert_service_screen/layout/provider_mapview.dart';
import 'package:fixit_user/screens/app_pages_screens/expert_service_screen/layout/tab_view.dart';

import '../../../config.dart';

class ExpertServiceScreen extends StatefulWidget {
  const ExpertServiceScreen({super.key});

  @override
  State<ExpertServiceScreen> createState() => _ExpertServiceScreenState();
}

class _ExpertServiceScreenState extends State<ExpertServiceScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final dash = Provider.of<DashboardProvider>(context, listen: true);
    return Consumer<ExpertServiceProvider>(builder: (context1, value, child) {
      return StatefulWrapper(
        onInit: () => Future.delayed(DurationClass.ms50)
            .then((_) => value.onReady(context, this)),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBarCommon(title: translations!.expertService),
            body: RefreshIndicator(
                onRefresh: () async {
                  return dash.getHighestRate();
                },
                child: Column(
                  children: [
                    const ToggleButtonsWidget(),
                    const VSpace(Sizes.s16),
                    if (value.isMapView == false)
                      ListView(shrinkWrap: true, children: [
                        SearchTextFieldCommon(
                            controller: value.txtFeaturedSearch,
                            focusNode: value.searchFocus,
                            onChanged: (v) {
                              if (v.isEmpty) {
                                value.getFeaturedPackage();
                              } else if (v.length > 3) {
                                value.getFeaturedPackage();
                              }
                            },
                            suffixIcon: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (value.txtFeaturedSearch.text.isNotEmpty)
                                  Icon(Icons.cancel,
                                          color: appColor(context).darkText)
                                      .inkWell(onTap: () {
                                    value.txtFeaturedSearch.text = "";
                                    value.notifyListeners();
                                    value.getFeaturedPackage();
                                  }),
                              ],
                            ).paddingSymmetric(horizontal: Insets.i20),
                            onFieldSubmitted: (v) =>
                                value.getFeaturedPackage()),
                        const VSpace(Sizes.s20),
                        value.txtFeaturedSearch.text.isEmpty
                            ? FutureBuilder(
                                future: value.fetchData(context),
                                initialData: dash.highestRateList,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.waiting &&
                                      snapshot.data!.isEmpty) {
                                    return const ExpertServiceShimmer(count: 5);
                                  } else {
                                    if (snapshot.error != null) {
                                      return const ExpertServiceShimmer(
                                          count: 5);
                                    } else {
                                      return Column(
                                        children: [
                                          ...dash.highestRateList
                                              .asMap()
                                              .entries
                                              .map((e) => ExpertServiceLayout(
                                                  data: e.value,
                                                  isHome: true,
                                                  onTap: () => route.pushNamed(
                                                      context,
                                                      routeName
                                                          .providerDetailsScreen,
                                                      arg: {'provider': e.value})))
                                        ],
                                      );
                                    }
                                  }
                                  /*return Column(
                                children: [
                                  ...dash.highestRateList.asMap().entries.map((e) =>
                                      ExpertServiceLayout(
                                          data: e.value,
                                          isHome: true,
                                          onTap: () => route.pushNamed(
                                              context, routeName.providerDetailsScreen,
                                              arg: {'provider': e.value})))
                                ],
                              );*/
                                })
                            : value.searchList.isNotEmpty
                                ? Column(
                                    children: [
                                      ...value.searchList
                                          .asMap()
                                          .entries
                                          .map((e) => ExpertServiceLayout(
                                              data: e.value,
                                              isHome: true,
                                              onTap: () {
                                                Provider.of<ProviderDetailsProvider>(
                                                        context,
                                                        listen: false)
                                                    .getProviderById(
                                                        context, e.value.id);

                                                route.pushNamed(
                                                    context,
                                                    routeName
                                                        .providerDetailsScreen,
                                                    arg: {
                                                      'providerId': e.value
                                                    });
                                              }))
                                    ],
                                  )
                                : Column(children: [
                                    Stack(children: [
                                      Image.asset(eImageAssets.noSearch,
                                              height: Sizes.s346)
                                          .paddingOnly(top: Insets.i40),
                                      if (value.animationController != null)
                                        Positioned(
                                            left: 40,
                                            top: 0,
                                            child: RotationTransition(
                                                turns: Tween(
                                                        begin: 0.01, end: -.01)
                                                    .chain(CurveTween(
                                                        curve: Curves.easeIn))
                                                    .animate(value
                                                        .animationController!),
                                                child: Image.asset(
                                                    eImageAssets.mGlass,
                                                    height: Sizes.s190,
                                                    width: Sizes.s178)))
                                    ]),
                                    const VSpace(Sizes.s25),
                                    Text(
                                        language(
                                            context, translations!.noMatching),
                                        style: appCss.dmDenseBold18.textColor(
                                            appColor(context).darkText)),
                                    const VSpace(Sizes.s8),
                                    Text(
                                            language(
                                                context,
                                                translations!
                                                    .attemptYourSearch),
                                            textAlign: TextAlign.center,
                                            style: appCss.dmDenseRegular14
                                                .textColor(appColor(context)
                                                    .lightText))
                                        .paddingSymmetric(
                                            horizontal: Insets.i10)
                                  ])
                      ]).paddingSymmetric(horizontal: Insets.i20),
                    if (value.isMapView == true)
                      const SizedBox(height: 590, child: ProviderMapView()),
                  ],
                ))),
      );
    });
  }
}
