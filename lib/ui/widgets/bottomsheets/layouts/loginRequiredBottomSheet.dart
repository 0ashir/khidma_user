import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class LoginRequiredBottomSheet extends StatelessWidget {
  const LoginRequiredBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.backgroundPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.colors.borderDefault,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const CustomSizedBox(height: 16),
                CustomContainer(
                  width: 64,
                  height: 64,
                  color: context.colors.backgroundBrandSubtle,
                  borderRadius: 32,
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    Icons.info,
                    color: context.colors.textBrand,
                    size: 32,
                  ),
                ),
                const CustomSizedBox(height: 16),
                CustomText(
                  'loginRequired'.translate(context: context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                const CustomSizedBox(height: 8),
                CustomText(
                  'pleaseLogin'.translate(context: context),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const CustomSizedBox(height: 16),
          ClipShadowBottom(
            child: CustomContainer(
              width: double.infinity,
              color: context.colors.backgroundPrimary,
              padding: const EdgeInsets.all(16),
              boxShadow: [
                BoxShadow(
                  color: context.colors.overlayFooterShadow,
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: CustomInkWellContainer(
                        borderRadius: BorderRadius.circular(
                          UiUtils.borderRadiusOf12,
                        ),
                        onTap: () => Navigator.of(context).pop(),
                        child: CustomContainer(
                          height: 48,
                          color: context.colors.backgroundBrandSubtle,
                          border: Border.all(color: context.colors.borderBrand),
                          borderRadius: UiUtils.borderRadiusOf12,
                          child: Center(
                            child: CustomText(
                              'close'.translate(context: context),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: context.colors.textBrand,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const CustomSizedBox(width: 12),
                    Expanded(
                      child: CustomInkWellContainer(
                        borderRadius: BorderRadius.circular(
                          UiUtils.borderRadiusOf12,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(
                            context,
                            loginRoute,
                            arguments: {'source': 'dialog'},
                          );
                        },
                        child: CustomContainer(
                          height: 48,
                          color: context.colors.backgroundBrand,
                          borderRadius: UiUtils.borderRadiusOf12,
                          child: Center(
                            child: CustomText(
                              'logIn'.translate(context: context),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: context.colors.textInverseLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
