import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthAppBar({super.key, this.onBackTap});

  final VoidCallback? onBackTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(final BuildContext context) => AppBar(
    backgroundColor: context.colors.backgroundSecondary,
    surfaceTintColor: context.colors.backgroundSecondary,
    elevation: 0,
    systemOverlayStyle: UiUtils.getSystemUiOverlayStyle(context: context),
    leading: CustomInkWellContainer(
      onTap: () {
        if (onBackTap != null) {
          onBackTap!();
        } else {
          Navigator.pop(context);
        }
      },
      borderRadius: BorderRadius.circular(999),
      child: CustomContainer(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(8),
        color: context.colors.backgroundPrimary,
        shape: BoxShape.circle,
        child: Center(
          child: CustomSvgPicture(
            width: 24,
            height: 24,
            svgImage: Directionality.of(context) == TextDirection.rtl
                ? AppAssets.rightArrow
                : AppAssets.leftArrow,
            color: context.colors.iconPrimary,
          ),
        ),
      ),
    ),
  );
}
