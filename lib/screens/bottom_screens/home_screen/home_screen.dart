import 'package:flutter/services.dart';
import 'package:upgrader/upgrader.dart';
import '../../../config.dart';
import 'layouts/home_body.dart';
import 'new_york_layout.dart/new_york_body.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer3<DashboardProvider, CommonApiProvider,
            CategoriesDetailsProvider>(
        builder: (context3, dash, common, categoriesDetailsProvider, child) {
      return Consumer<HomeScreenProvider>(builder: (context1, value, child) {
        return Consumer<LocationProvider>(
            builder: (context2, locationCtrl, child) {
          return UpgradeAlert(
              showIgnore: false,
              showLater: false,
              child: Stack(
                children: [
                  StatefulWrapper(
                      onInit: () => Future.delayed(
                          const Duration(milliseconds: 100),
                          () => value.onAnimate(this, context)),
                      child: common.isLoadingDashboard /*  value.isSkeleton */
                          /*  ? const /* BerlinSkeleton() */ /* TokyoSkeleton() */ /* DubaiSkeleton() */ /*  TorontoSkeleton() */ /* NewYorkSkeleton() */ HomeSkeleton() */
                          ? appSettingModel?.general?.defaultHomeScreen ==
                                  "tokyo"
                              ? const TokyoSkeleton()
                              : appSettingModel?.general?.defaultHomeScreen ==
                                      "new_york"
                                  ? const NewYorkSkeleton()
                                  : appSettingModel?.general?.defaultHomeScreen ==
                                          "toronto"
                                      ? const TorontoSkeleton()
                                      : appSettingModel?.general?.defaultHomeScreen ==
                                              "berlin"
                                          ? const BerlinSkeleton()
                                          : appSettingModel?.general?.defaultHomeScreen ==
                                                  "dubai"
                                              ? const DubaiSkeleton()
                                              : const NewYorkSkeleton() /* const HomeSkeleton() */
                          : RefreshIndicator(
                              onRefresh: () async {
                                return dash.onRefresh(context);
                              },
                              child: Scaffold(
                                  appBar: appSettingModel?.general?.defaultHomeScreen ==
                                          "tokyo"
                                      ? null
                                      : appSettingModel?.general?.defaultHomeScreen ==
                                              "dubai"
                                          ? null
                                          : appSettingModel?.general
                                                      ?.defaultHomeScreen ==
                                                  "berlin"
                                              ? null
                                              : appSettingModel?.general
                                                          ?.defaultHomeScreen ==
                                                      "toronto"
                                                  ? AppBar(
                                                      leadingWidth:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      leading: TorontoAppbar(
                                                          location: street ?? ""))
                                                  : AppBar(
                                                      leadingWidth: MediaQuery.of(context).size.width,
                                                      leading: /* TorontoAppbar(
                                          location: street ??
                                              "") */
                                                          HomeAppBar(location: street ?? "")),
                                  body: appSettingModel?.general?.defaultHomeScreen == "tokyo"
                                      ? AnnotatedRegion<SystemUiOverlayStyle>(
                                          value: SystemUiOverlayStyle.light
                                              .copyWith(
                                                  statusBarColor:
                                                      Theme.of(context)
                                                          .primaryColor),
                                          child: const SafeArea(
                                            child: TokyoBody(),
                                          ),
                                        )
                                      : appSettingModel?.general?.defaultHomeScreen == "new_york"
                                          ? const SafeArea(child: NewYorkBody())
                                          : appSettingModel?.general?.defaultHomeScreen == "toronto"
                                              ? const SafeArea(child: TorontoBody())
                                              : appSettingModel?.general?.defaultHomeScreen == "berlin"
                                                  ? AnnotatedRegion<SystemUiOverlayStyle>(
                                                      value: SystemUiOverlayStyle
                                                          .light
                                                          .copyWith(
                                                              statusBarColor: Theme
                                                                      .of(context)
                                                                  .primaryColor),
                                                      child: const SafeArea(
                                                        child: BerlinBody(),
                                                      ),
                                                    )
                                                  : appSettingModel?.general?.defaultHomeScreen == "dubai"
                                                      ? const SafeArea(child: DubaiBody())
                                                      : const SafeArea(child: HomeBody())))),
                  if (common.isLoading || categoriesDetailsProvider.isLoading)
                    Container(
                      color: isDark(context)
                          ? Colors.black.withValues(alpha: .3)
                          : appColor(context).darkText.withValues(alpha: 0.2),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                          child: Image.asset(
                        eGifAssets.loader,
                        height: Sizes.s100,
                      )),
                    )
                ],
              ));
        });
      });
    });
  }
}
