import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

/// Confirms "Clear All" from the cart list sheet before wiping every
/// provider's cart — Figma node 7705:185177 ("Sort by" / "Remove All
/// Providers?"). Pops `true` when the user confirms, `false`/null otherwise.
class RemoveAllProvidersBottomSheet extends StatelessWidget {
  const RemoveAllProvidersBottomSheet({super.key});

  @override
  Widget build(final BuildContext context) => CustomContainer(
    color: context.colors.component.bottomSheetBackground,
    borderRadiusStyle: BorderRadius.only(
      topLeft: Radius.circular(16.rf(context)),
      topRight: Radius.circular(16.rf(context)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            16.rw(context),
            16.rh(context),
            16.rw(context),
            0,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.colors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                SizedBox(height: 16.rh(context)),
                CustomContainer(
                  width: 64,
                  height: 64,
                  color: context.colors.backgroundBrandSubtle,
                  borderRadius: 32,
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: context.colors.iconBrand,
                    size: 32,
                  ),
                ),
                SizedBox(height: 16.rh(context)),
                CustomText(
                  'removeAllProvidersQuestion'.translate(context: context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.colors.component.cardMainText,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.rh(context)),
                CustomText(
                  'removeAllProvidersWarning'.translate(context: context),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.rh(context)),
              ],
            ),
          ),
        ),
        ClipShadowBottom(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colors.surfacePrimary,
              boxShadow: [
                BoxShadow(
                  color: context.colors.component.cardShadow,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.all(16.rf(context)).copyWith(
              bottom: 16.rf(context) + MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(
                      UiUtils.borderRadiusOf12,
                    ),
                    onTap: () => Navigator.of(context).pop(false),
                    child: CustomContainer(
                      padding: EdgeInsets.symmetric(vertical: 12.rh(context)),
                      color: context.colors.backgroundBrandSubtle,
                      border: Border.all(color: context.colors.borderBrand),
                      borderRadius: UiUtils.borderRadiusOf12,
                      child: Center(
                        child: CustomText(
                          'keepCart'.translate(context: context),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textBrand,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.rw(context)),
                Expanded(
                  child: CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(
                      UiUtils.borderRadiusOf12,
                    ),
                    onTap: () => Navigator.of(context).pop(true),
                    child: CustomContainer(
                      padding: EdgeInsets.symmetric(vertical: 12.rh(context)),
                      color: context.colors.component.buttonPrimaryBg,
                      borderRadius: UiUtils.borderRadiusOf12,
                      child: Center(
                        child: CustomText(
                          'clearCart'.translate(context: context),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: context.colors.component.buttonPrimaryText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
