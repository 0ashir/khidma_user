import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class RequestServiceBannerWidget extends StatelessWidget {
  const RequestServiceBannerWidget({super.key, this.title, this.subtitle});

  final String? title;
  final String? subtitle;

  @override
  Widget build(final BuildContext context) {
    return CustomContainer(
      color: context.colors.backgroundBrandSubtle,
      borderRadius: 16,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -48,
            right: -64,
            child: CustomContainer(
              width: 128,
              height: 128,
              shape: BoxShape.circle,
              color: context.colors.backgroundBrand.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            bottom: -48,
            left: -48,
            child: CustomContainer(
              width: 96,
              height: 96,
              shape: BoxShape.circle,
              color: context.colors.backgroundBrand.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              spacing: 16,
              children: [
                Column(
                  children: [
                    CustomText(
                      (title != null && title!.isNotEmpty)
                          ? title!
                          : 'cantFindService'.translate(context: context),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                    CustomText(
                      (subtitle != null && subtitle!.isNotEmpty)
                          ? subtitle!
                          : 'cantFindServiceSubtitle'.translate(
                              context: context,
                            ),
                      fontSize: 12,
                      color: context.colors.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                CustomInkWellContainer(
                  borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
                  onTap: () {
                    final authStatus = context
                        .read<AuthenticationCubit>()
                        .state;
                    if (authStatus is UnAuthenticatedState) {
                      UiUtils.showBottomSheet(
                        context: context,
                        enableDrag: true,
                        isScrollControlled: true,
                        useSafeArea: true,
                        child: const LoginRequiredBottomSheet(),
                      );
                      return;
                    }
                    Navigator.pushNamed(
                      context,
                      requestServiceCategorySelectionScreen,
                    );
                  },
                  child: CustomContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: context.colors.backgroundBrand,
                    borderRadius: UiUtils.borderRadiusOf8,
                    child: CustomText(
                      'requestService'.translate(context: context),
                      fontSize: 14,
                      color: context.colors.textInverseLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
