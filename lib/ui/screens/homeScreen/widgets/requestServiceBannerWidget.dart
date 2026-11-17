import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/screens/homeScreen/widgets/homeHeader.dart';
import 'package:flutter/material.dart';

/// Compact "Need a different service? Request it ->" row.
class RequestServiceBannerWidget extends StatelessWidget {
  const RequestServiceBannerWidget({super.key, this.title, this.subtitle});

  /// Kept for API compatibility; the compact row uses fixed copy.
  final String? title;
  final String? subtitle;

  void _onTap(final BuildContext context) {
    final authStatus = context.read<AuthenticationCubit>().state;
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
    Navigator.pushNamed(context, requestServiceCategorySelectionScreen);
  }

  @override
  Widget build(final BuildContext context) {
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _onTap(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.backgroundPrimary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.borderDefault),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: context.colors.backgroundBrand,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                size: 18,
                color: context.colors.iconInverseLight,
              ),
            ),
            const CustomSizedBox(width: 10),
            Expanded(
              child: CustomText(
                homeText(
                  context,
                  'needDifferentService',
                  'Need a different service?',
                ),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
                maxLines: 1,
              ),
            ),
            CustomText(
              homeText(context, 'requestIt', 'Request it'),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.colors.textBrand,
            ),
            const CustomSizedBox(width: 4),
            Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: context.colors.iconBrand,
            ),
          ],
        ),
      ),
    );
  }
}
