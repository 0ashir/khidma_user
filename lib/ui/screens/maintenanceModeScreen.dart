import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MaintenanceModeScreen extends StatelessWidget {
  const MaintenanceModeScreen({required this.message, final Key? key})
      : super(key: key);
  final String message;

  static Route<MaintenanceModeScreen> route(
          final RouteSettings routeSettings) =>
      CupertinoPageRoute(
        builder: (final _) =>
            MaintenanceModeScreen(message: routeSettings.arguments as String),
      );

  @override
  Widget build(final BuildContext context) =>
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 250,
                    width: context.screenWidth * 0.9,
                    child: Lottie.asset(
                      'assets/animation/maintenance_mode.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomText(
                      'underMaintenance'.translate(context: context),
                      color: context.colorScheme.blackColor,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      fontSize: 20,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomText(
                      (message.isNotEmpty)
                          ? message
                          : 'underMaintenanceSubTitle'
                              .translate(context: context),
                      color: context.colorScheme.blackColor,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
