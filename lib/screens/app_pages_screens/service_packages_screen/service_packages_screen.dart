import 'dart:developer';

import '../../../config.dart';

class ServicePackagesScreen extends StatefulWidget {
  const ServicePackagesScreen({super.key});

  @override
  State<ServicePackagesScreen> createState() => _ServicePackagesScreenState();
}

class _ServicePackagesScreenState extends State<ServicePackagesScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.delayed(DurationClass.ms50, () {
      final provider =
          Provider.of<ServicePackageAllListProvider>(context, listen: false);
      provider.onAnimate(this);
      provider.fetchData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dash = Provider.of<DashboardProvider>(context, listen: true);

    return Consumer<ServicePackageAllListProvider>(
      builder: (context1, value, child) {
        return WillPopScope(
          onWillPop: () async {
            value.animationController?.dispose();
            return true;
          },
          child: Scaffold(
            appBar: AppBarCommon(
              title: translations!.servicePackage,
              onTap: () {
                value.animationController?.dispose();
                route.pop(context);
              },
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.only(
                right: rtl(context) ? 0 : Sizes.s5,
                left: rtl(context) ? Sizes.s5 : 0,
              ),
              child: Column(
                children: [
                  dash.servicePackagesList.isEmpty
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: Sizes.s20,
                            mainAxisExtent: Sizes.s150,
                          ),
                          itemCount: 8,
                          itemBuilder: (context, index) =>
                              const PackageShimmer(isFullWidth: true),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dash.servicePackagesList.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: Sizes.s20,
                          ),
                          itemBuilder: (context, index) => ServicePackageList(
                            rotationAnimation: value.rotationAnimation,
                            data: dash.servicePackagesList[index],
                            isViewAll: true,
                            onTap: () {
                              route.pushNamed(
                                context,
                                routeName.packageDetailsScreen,
                                arg: {
                                  "packageId":
                                      dash.servicePackagesList[index].id,
                                },
                              );
                              log("Tapped package: ${dash.servicePackagesList[index]}");
                            },
                          ),
                        ).paddingOnly(bottom: Insets.i20),
                ],
              ).paddingOnly(left: Insets.i20),
            ),
          ),
        );
      },
    );
  }
}
