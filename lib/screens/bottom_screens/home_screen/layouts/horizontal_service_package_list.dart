import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';

import '../../../../config.dart';

class HorizontalServicePackageList extends StatelessWidget {
  final List<ServicePackageModel>? servicePackagesList;
  final Animation<double>? rotationAnimation;
  const HorizontalServicePackageList(
      {super.key, this.servicePackagesList, this.rotationAnimation});

  @override
  Widget build(BuildContext context) {
    var serviceCtrl = Provider.of<ServicesPackageDetailsProvider>(context);

    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: servicePackagesList!
                    .asMap()
                    .entries
                    .map((e) => ServicePackageList(
                        rotationAnimation: rotationAnimation,
                        data: e.value,
                        onTap: () {
                          log("Navigating to PackageDetailsScreen with serviceId: ${e.value.id}");
                          if (e.value.id != null && e.value.id! > 0) {
                            route.pushNamed(
                              context,
                              routeName.packageDetailsScreen,
                              arg: {"packageId": e.value.id},
                            );
                          } else {
                            log("Invalid serviceId for package: ${e.value.title}");
                            Fluttertoast.showToast(
                                msg: "Unable to load package details");
                          }
                        }))
                    .toList())
            .paddingSymmetric(horizontal: Insets.i20));
  }
}
