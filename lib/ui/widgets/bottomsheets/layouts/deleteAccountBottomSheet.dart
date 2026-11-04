import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class DeleteUserAccountSheet extends StatefulWidget {
  const DeleteUserAccountSheet({super.key});

  @override
  State<DeleteUserAccountSheet> createState() => _DeleteUserAccountSheetState();
}

class _DeleteUserAccountSheetState extends State<DeleteUserAccountSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _hasConfirmedUnderstanding = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPasswordLoginEnabled =
        context
            .read<SystemSettingCubit>()
            .loginSettings
            ?.isPasswordLoginEnabled ??
        false;
    final bool requiresPassword =
        isPasswordLoginEnabled &&
        (context
                .watch<UserDetailsCubit>()
                .getUserDetails()
                .loginType
                ?.hasPassword ??
            false);

    return BlocConsumer<DeleteUserAccountCubit, DeleteUserAccountState>(
      listener:
          (
            final BuildContext context,
            final DeleteUserAccountState state,
          ) async {
            if (state is DeleteUserAccountSuccess) {
              final bool response = await UiUtils.clearUserData();

              if (response) {
                UiUtils.showMessage(
                  context,
                  'accountDeletedSuccessfully'.translate(context: context),
                  ToastificationType.success,
                );

                Future.delayed(Duration.zero, () {
                  context.read<AuthenticationCubit>().checkStatus();
                  context.read<UserDetailsCubit>().clearCubit();
                  context.read<CartCubit>().clearCartCubit();
                  context.read<BookmarkCubit>().clearBookMarkCubit();

                  AppQuickActions.createAppQuickActions();

                  Navigator.of(
                    context,
                  ).popUntil((final route) => route.isFirst);
                });
              } else {
                UiUtils.showMessage(
                  context,
                  'somethingWentWrong'.translate(context: context),
                  ToastificationType.error,
                );
                Navigator.pop(context, true);
              }
            } else if (state is DeleteUserAccountFailure) {
              UiUtils.showMessage(
                context,
                state.errorMessage,
                ToastificationType.error,
              );
              Navigator.pop(context, true);
            }
          },
      builder:
          (final BuildContext context, final DeleteUserAccountState state) {
            final bool isInProgress = state is DeleteUserAccountInProgress;

            void handleDelete() {
              if (isInProgress || !_hasConfirmedUnderstanding) return;
              if (!_formKey.currentState!.validate()) return;

              context.read<DeleteUserAccountCubit>().deleteUserAccount(
                password: requiresPassword
                    ? _passwordController.text.trim()
                    : null,
              );
            }

            return CustomContainer(
              color: context.colors.backgroundPrimary,
              margin: EdgeInsetsDirectional.only(
                bottom: MediaQuery.viewPaddingOf(context).bottom,
              ),
              borderRadiusStyle: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Form(
                  key: _formKey,
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
                            const CustomSizedBox(height: 8),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: CustomText(
                                'deleteAccount'.translate(context: context),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            const CustomSizedBox(height: 8),
                            CustomContainer(
                              height: 1.5,
                              color: context.colors.backgroundSecondary,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (requiresPassword) ...[
                              CustomTextFormField(
                                controller: _passwordController,
                                labelText: 'password'.translate(
                                  context: context,
                                ),
                                isRequired: true,
                                isPassword: true,
                                fillColor: context.colors.backgroundSecondary,
                                textInputAction: TextInputAction.done,
                                validator: (value) => isTextFieldEmpty(
                                  context: context,
                                  value: value,
                                ),
                              ),
                              const CustomSizedBox(height: 16),
                            ],
                            CustomContainer(
                              width: double.infinity,
                              color: context.colors.backgroundWarningSubtle,
                              borderRadius: UiUtils.borderRadiusOf8,
                              padding: const EdgeInsets.all(8),
                              child: CustomText(
                                'deleteAccountWarning'.translate(
                                  context: context,
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            const CustomSizedBox(height: 16),
                            Row(
                              children: [
                                // CustomCheckBox(
                                //   value: _hasConfirmedUnderstanding,
                                //   isCircular: true,
                                //   onChanged: (final bool? checked) {
                                //     setState(() {
                                //       _hasConfirmedUnderstanding =
                                //           checked ?? false;
                                //     });
                                //   },
                                // ),
                                CustomInkWellContainer(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () {
                                    setState(() {
                                      _hasConfirmedUnderstanding =
                                          !_hasConfirmedUnderstanding;
                                    });
                                  },
                                  child: CustomContainer(
                                    width: 20,
                                    height: 20,
                                    shape: BoxShape.circle,
                                    color: _hasConfirmedUnderstanding
                                        ? context
                                              .colors
                                              .component
                                              .buttonPrimaryBg
                                        : Colors.transparent,
                                    border: _hasConfirmedUnderstanding
                                        ? null
                                        : Border.all(
                                            color: context.colors.iconPrimary,
                                            width: 1.5,
                                          ),
                                    child: _hasConfirmedUnderstanding
                                        ? Icon(
                                            Icons.check,
                                            size: 14,
                                            color: context
                                                .colors
                                                .component
                                                .buttonPrimaryText,
                                          )
                                        : null,
                                  ),
                                ),
                                const CustomSizedBox(width: 8),
                                Expanded(
                                  child: CustomText(
                                    'deleteAccountUnderstandConfirmation'
                                        .translate(context: context),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const CustomSizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomInkWellContainer(
                                    borderRadius: BorderRadius.circular(
                                      UiUtils.borderRadiusOf12,
                                    ),
                                    onTap: isInProgress
                                        ? null
                                        : () => Navigator.pop(context),
                                    child: CustomContainer(
                                      height: 48,
                                      color:
                                          context.colors.backgroundErrorSubtle,
                                      border: Border.all(
                                        color: context.colors.borderError,
                                      ),
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
                                  child: Opacity(
                                    opacity: _hasConfirmedUnderstanding
                                        ? 1
                                        : 0.4,
                                    child: CustomInkWellContainer(
                                      borderRadius: BorderRadius.circular(
                                        UiUtils.borderRadiusOf12,
                                      ),
                                      onTap: _hasConfirmedUnderstanding
                                          ? handleDelete
                                          : null,
                                      child: CustomContainer(
                                        height: 48,
                                        color: context.colors.backgroundError,
                                        borderRadius: UiUtils.borderRadiusOf12,
                                        child: Center(
                                          child: isInProgress
                                              ? CustomCircularProgressIndicator(
                                                  color: context
                                                      .colors
                                                      .textInverseLight,
                                                  widthAndHeight: 24,
                                                )
                                              : CustomText(
                                                  'delete'.translate(
                                                    context: context,
                                                  ),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: context
                                                      .colors
                                                      .textInverseLight,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
    );
  }
}
