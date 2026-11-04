import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomJobRequestSuccessScreen extends StatelessWidget {
  const CustomJobRequestSuccessScreen({super.key, required this.requestId});

  final String requestId;

  static Route route(final RouteSettings settings) {
    final arguments = settings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final _) =>
          CustomJobRequestSuccessScreen(requestId: arguments['requestId']),
    );
  }

  @override
  Widget build(final BuildContext context) => PopScope(
    canPop: false,
    child: AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        backgroundColor: context.colors.backgroundSecondary,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          "assets/animation/success.json",
                          height: 124,
                          width: 124,
                        ),
                        const CustomSizedBox(height: 16),
                        CustomText(
                          'requestSubmitted'.translate(context: context),
                          textAlign: TextAlign.center,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                        const CustomSizedBox(height: 8),
                        CustomText(
                          'customJobRequestSuccessMessage'.translate(
                            context: context,
                          ),
                          textAlign: TextAlign.center,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: context.colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomRoundedButton(
                      widthPercentage: 1,
                      height: 48,
                      radius: UiUtils.borderRadiusOf12,
                      backgroundColor: context.colors.backgroundBrand,
                      titleColor: context.colors.textInverseLight,
                      buttonTitle: 'viewRequest'.translate(context: context),
                      showBorder: false,
                      textSize: 16,
                      fontWeight: FontWeight.w500,
                      onTap: () {
                        Navigator.of(
                          context,
                        ).popUntil((final Route route) => route.isFirst);
                        Navigator.of(context).pushNamed(
                          myRequestDetailsScreen,
                          arguments: {
                            'customJobRequestId': requestId,
                            'status': '',
                          },
                        );
                      },
                    ),
                    const CustomSizedBox(height: 12),
                    CustomInkWellContainer(
                      borderRadius: BorderRadius.circular(
                        UiUtils.borderRadiusOf12,
                      ),
                      onTap: () {
                        Navigator.of(
                          context,
                        ).popUntil((final Route route) => route.isFirst);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: CustomText(
                          'backToHome'.translate(context: context),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: context.colors.textBrand,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
