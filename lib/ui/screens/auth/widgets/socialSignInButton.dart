import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.isLoading = false,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  static const double _gap = 12;

  @override
  Widget build(final BuildContext context) => CustomInkWellContainer(
    onTap: isLoading ? null : onTap,
    child: CustomContainer(
      width: double.maxFinite,
      avoideResponsive: true,
      color: context.colors.backgroundPrimary,
      border: Border.all(color: context.colors.borderDefault),
      borderRadius: UiUtils.borderRadiusOf8,
      padding: const EdgeInsets.all(_gap),
      child: isLoading
          ? const CustomSizedBox(
              height: 24,
              child: Center(child: CustomCircularProgressIndicator()),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const CustomSizedBox(width: _gap),
                CustomText(
                  label.translate(context: context),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textPrimary,
                ),
              ],
            ),
    ),
  );
}
