import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/authentication/logoutCubit.dart';
import 'package:flutter/material.dart';

class ErrorContainer extends StatelessWidget {
  const ErrorContainer({
    required this.errorMessage,
    final Key? key,
    this.errorMessageColor,
    this.buttonName,
    this.errorMessageFontSize,
    this.onTapRetry,
    this.showErrorImage,
    this.retryButtonBackgroundColor,
    this.retryButtonTextColor,
    this.subErrorMessage,
    this.showRetryButton = true,
    this.loginSource,
  }) : super(key: key);
  final String errorMessage;
  final String? buttonName;
  final bool? showErrorImage;
  final Color? errorMessageColor;
  final double? errorMessageFontSize;
  final Function? onTapRetry;
  final bool showRetryButton;
  final Color? retryButtonBackgroundColor;
  final Color? retryButtonTextColor;
  final String? subErrorMessage;
  final String? loginSource;

  @override
  Widget build(final BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showErrorImage != false)
            if (errorMessage == "noInternetFound".translate(context: context))
              CustomSizedBox(
                height: context.screenHeight * 0.35,
                child: CustomSvgPicture(
                  svgImage: AppAssets.noConnection,
                  colorMapper: IllustrationBrandColorMapper(
                    primaryColor: context.colors.iconBrand,
                    primaryLightColor: context.colors.backgroundBrandSubtle,
                  ),
                ),
              )
            else
              CustomSizedBox(
                height: context.screenHeight * 0.25,
                child: CustomSvgPicture(
                  svgImage: AppAssets.somethingWentWrong,
                  colorMapper: IllustrationBrandColorMapper(
                    primaryColor: context.colors.iconBrand,
                    primaryLightColor: context.colors.backgroundBrandSubtle,
                  ),
                ),
              ),
          const CustomSizedBox(height: 24),
          CustomText(
            (errorMessage == "noInternetFound"
                    ? "noInternetFoundTitle"
                    : errorMessage == "somethingWentWrong"
                    ? "somethingWentWrongTitle"
                    : errorMessage)
                .translate(context: context),
            textAlign: TextAlign.center,
            color: context.colors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 32 / 24,
          ),
          const CustomSizedBox(height: 8),
          CustomText(
            subErrorMessage?.translate(context: context) ?? '',
            textAlign: TextAlign.center,
            color: context.colors.textSecondary,
            fontSize: errorMessageFontSize ?? 14,
            height: 20 / 14,
          ),
          const CustomSizedBox(height: 24),
          if (showRetryButton)
            CustomRoundedButton(
              height: 40,
              widthPercentage: 0.6,
              backgroundColor:
                  retryButtonBackgroundColor ?? context.colors.backgroundBrand,
              onTap: () {
                if (UiUtils.authenticationError) {
                  //logout and redirect to login screen
                  context.read<LogoutCubit>().logout(context);
                  Navigator.pushNamed(
                    context,
                    loginRoute,
                    arguments: {'source': 'profileScreen'},
                  );
                  UiUtils.authenticationError = false;
                } else {
                  onTapRetry?.call();
                }
              },
              titleColor:
                  retryButtonTextColor ?? context.colors.textInverseLight,
              buttonTitle: UiUtils.authenticationError
                  ? 'goToLogin'.translate(context: context)
                  : (buttonName ?? 'retry').translate(context: context),
              showBorder: false,
            ),
        ],
      ),
    ),
  );
}
