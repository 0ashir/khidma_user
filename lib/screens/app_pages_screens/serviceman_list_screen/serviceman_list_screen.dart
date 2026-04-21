/*
import '../../../config.dart';

class ServicemanListScreen extends StatelessWidget {
  const ServicemanListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicemanListProvider>(builder: (context1, value, child) {
      return StatefulWrapper(
        onInit: () => Future.delayed(DurationClass.ms50)
            .then((_) => value.onReady(context)),
        child: Scaffold(
            appBar: AppBarCommon(title: translations!.servicemenList),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SingleChildScrollView(
                    child: Column(children: [
                  SearchTextFieldCommon(
                      controller: value.controller,
                      focusNode: value.searchFocus,
                      onChanged: (v) {
                        if (v.isEmpty) {
                          value.getServicemenByProviderId(
                              context, value.providerId,
                              val: v);
                        }
                      },
                      onFieldSubmitted: (v) => value.getServicemenByProviderId(
                          context, value.providerId, val: v),
                      suffixIcon: FilterIconCommon(
                          onTap: () => value.onTapFilter(context),
                          selectedFilter: "0")),
                  const VSpace(Sizes.s25),
                  ...value.servicemanList
                      .asMap()
                      .entries
                      .map((e) => ServicemanListLayout(
                          data: e.value,
                          selList: value.selectCategory,
                          index: e.key,
                          onTap: () => value.onCategorySelected(e.value.id)))
                      ,
                ]).paddingSymmetric(horizontal: Insets.i20)),
                ButtonCommon(
                  title: translations!.save,
                  onTap: () => value.onSaveTap(context),
                  margin: Insets.i20,
                )
                    .marginOnly(bottom: Insets.i20)
                    .alignment(Alignment.bottomCenter)
              ],
            )),
      );
    });
  }
}
*/


import '../../../config.dart';

class ServicemanListScreen extends StatefulWidget {
  const ServicemanListScreen({super.key});

  @override
  State<ServicemanListScreen> createState() => _ServicemanListScreenState();
}

class _ServicemanListScreenState extends State<ServicemanListScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final value1 = Provider.of<SlotBookingProvider>(context);
    return Consumer<ServicemanListProvider>(builder: (context1, value, child) {
      return StatefulWrapper(
        onInit: () => Future.delayed(DurationClass.ms50)
            .then((_) => value.onReady(context, this)),
        child: Scaffold(
            appBar: AppBarCommon(
              title: translations!.servicemenList,
              onTap: () {
                value.controller.text = "";
                // value.animationController!.dispose();
                value.notifyListeners();
                route.pop(context);
              },
            ),
            body: Stack(children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchTextFieldCommon(
                        controller: value.controller,
                        focusNode: value.searchFocus,
                        onChanged: (v) {
                          if (v.isEmpty) {
                            value.getServicemenByProviderId(
                                context, value.providerId,
                                val: v);
                          } else if (v.length > 2) {
                            value.getServicemenByProviderId(
                                context, value.providerId,
                                val: v);
                          }
                        },
                        onFieldSubmitted: (v) =>
                            value.getServicemenByProviderId(
                                context, value.providerId, val: v),
                        suffixIcon: FilterIconCommon(
                            onTap: () => value.onTapFilter(context),
                            selectedFilter: "0")),
                    const VSpace(Sizes.s25),
                    if (value1.servicesCart?.selectedRequiredServiceMan != null)
                      Text(
                          language(context,
                              "${value1.servicesCart?.selectedRequiredServiceMan} Required ServiceMan"),
                          style: appCss.dmDenseMedium14
                              .textColor(appColor(context).darkText)),
                    const VSpace(Sizes.s25),
                    value.isLoadingForProvider
                        ? const CircularProgressIndicator()
                            .paddingDirectional(top: 160)
                            .center()
                        : value.servicemanList.isEmpty
                            ? Column(
                                children: [
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
                                          language(context,
                                              translations!.attemptYourSearch),
                                          textAlign: TextAlign.center,
                                          style: appCss.dmDenseRegular14
                                              .textColor(
                                                  appColor(context).lightText))
                                      .paddingSymmetric(horizontal: Insets.i10)
                                ],
                              )
                            : Column(
                                children: [
                                  ...value.servicemanList.asMap().entries.map(
                                      (e) => ServicemanListLayout(
                                          data: e.value,
                                          selList: value.selectCategory,
                                          selectedIndex: value.selectedIndex,
                                          requiredServiceman: int.parse(
                                              value.requiredServiceman ?? "1"),
                                          index: e.key,
                                          onTap: () => value.onCategorySelected(
                                              context,
                                              e.value.id,
                                              e.key,
                                              e.value.name)))
                                ],
                              ).padding(bottom: 80)
                  ],
                ),
              ),
              if (MediaQuery.of(context).viewInsets.bottom == 0 &&
                  value.servicemanList.isNotEmpty)
                ButtonCommon(
                        title: translations!.save!,
                        onTap: () => value.onSaveTap(context))
                    .alignment(Alignment.bottomCenter)
                    .marginOnly(bottom: Sizes.s20)
            ]).paddingSymmetric(horizontal: Insets.i20)),
      );
    });
  }
}
