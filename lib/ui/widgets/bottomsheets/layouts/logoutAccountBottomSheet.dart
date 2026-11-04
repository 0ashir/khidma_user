import 'package:e_demand/cubits/authentication/logoutCubit.dart';
import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class LogoutAccountSheet extends StatelessWidget {
  const LogoutAccountSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LogoutCubit, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.of(context).pop(true);
          UiUtils.showMessage(
            context,
            'loggedOutSuccessfully'.translate(context: context),
            ToastificationType.success,
          );
        }
        if (state is LogoutFailure) {
          UiUtils.showMessage(
            context,
            'loggedOutFailed'.translate(context: context),
            ToastificationType.error,
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is LogoutLoading;

        return CustomContainer(
          color: context.colors.backgroundPrimary,
          margin: EdgeInsetsDirectional.only(
            bottom: MediaQuery.viewPaddingOf(context).bottom,
          ),
          borderRadiusStyle: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const CustomSizedBox(height: 16),
              CustomContainer(
                width: 48,
                height: 48,
                color: context.colors.backgroundErrorSubtle,
                borderRadius: 24,
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: context.colors.iconError,
                  size: 24,
                ),
              ),
              const CustomSizedBox(height: 12),
              CustomText(
                'areYouSureYouWantToLogout'.translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const CustomSizedBox(height: 4),
              CustomText(
                'logoutWarning'.translate(context: context),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const CustomSizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomInkWellContainer(
                      borderRadius: BorderRadius.circular(
                        UiUtils.borderRadiusOf12,
                      ),
                      onTap: isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: CustomContainer(
                        height: 48,
                        color: context.colors.backgroundErrorSubtle,
                        border: Border.all(color: context.colors.borderError),
                        borderRadius: UiUtils.borderRadiusOf12,
                        child: Center(
                          child: CustomText(
                            'close'.translate(context: context),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textError,
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
                        if (isLoading) return;
                        context.read<LogoutCubit>().logout(context);
                      },
                      child: CustomContainer(
                        height: 48,
                        color: context.colors.backgroundError,
                        borderRadius: UiUtils.borderRadiusOf12,
                        child: Center(
                          child: isLoading
                              ? CustomCircularProgressIndicator(
                                  color: context.colors.textInverseLight,
                                  widthAndHeight: 24,
                                )
                              : CustomText(
                                  'logout'.translate(context: context),
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
            ],
          ),
        );
      },
    );
  }
}
