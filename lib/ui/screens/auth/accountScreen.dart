import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({final Key? key}) : super(key: key);

  static Route route(final RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (final _) => const AccountScreen());
  }

  Widget _buildRow({
    required final BuildContext context,
    required final String icon,
    required final String title,
    required final VoidCallback onTap,
    final Color? iconColor,
    final Color? titleColor,
    final Color? iconBackgroundColor,
  }) => CustomInkWellContainer(
    onTap: onTap,
    child: Row(
      children: [
        CustomContainer(
          color: iconBackgroundColor ?? context.colors.backgroundSecondary,
          borderRadius: 24,
          padding: const EdgeInsets.all(8),
          child: CustomSvgPicture(
            avoideResponsive: true,
            svgImage: icon,
            color: iconColor ?? context.colors.iconPrimary,
            height: 20,
            width: 20,
          ),
        ),
        const CustomSizedBox(width: 12),
        Expanded(
          child: CustomText(
            title,
            color: titleColor ?? context.colors.textPrimary,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        CustomSvgPicture(
          svgImage:
              Directionality.of(
                context,
              ).toString().contains(TextDirection.RTL.value.toLowerCase())
              ? AppAssets.backArrow
              : AppAssets.backArrowLtr,
          height: 24,
          width: 24,
          color: iconColor ?? context.colors.iconPrimary,
          avoideResponsive: true,
        ),
      ],
    ),
  );

  @override
  Widget build(final BuildContext context) {
    final bool canChangePassword =
        (context
                .watch<SystemSettingCubit>()
                .loginSettings
                ?.isPasswordLoginEnabled ??
            false) &&
        (context
                .watch<UserDetailsCubit>()
                .getUserDetails()
                .loginType
                ?.hasPassword ??
            false);

    return AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        backgroundColor: context.colors.backgroundSecondary,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'account'.translate(context: context),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(
            16,
          ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (canChangePassword) ...[
                CustomContainer(
                  color: context.colors.surfacePrimary,
                  borderRadius: UiUtils.borderRadiusOf12,
                  padding: const EdgeInsets.all(12),
                  child: _buildRow(
                    context: context,
                    icon: AppAssets.drChangePassword,
                    title: 'changePassword'.translate(context: context),
                    onTap: () {
                      Navigator.pushNamed(context, changePasswordRoute);
                    },
                  ),
                ),
                const CustomSizedBox(height: 16),
              ],
              CustomContainer(
                color: context.colors.surfacePrimary,
                borderRadius: UiUtils.borderRadiusOf12,
                padding: const EdgeInsets.all(12),
                child: _buildRow(
                  context: context,
                  icon: AppAssets.drDeleteAccount,
                  title: 'deleteAccount'.translate(context: context),
                  iconColor: context.colors.iconError,
                  titleColor: context.colors.textError,
                  iconBackgroundColor: context.colors.backgroundErrorSubtle,
                  onTap: () {
                    UiUtils.showBottomSheet(
                      context: context,
                      enableDrag: true,
                      isScrollControlled: true,
                      useSafeArea: true,
                      child: BlocProvider(
                        create: (context) =>
                            DeleteUserAccountCubit(AuthenticationRepository()),
                        child: const DeleteUserAccountSheet(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
