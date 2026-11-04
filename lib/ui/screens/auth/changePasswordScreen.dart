import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({final Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();

  static Route route(final RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (final _) => MultiBlocProvider(
        providers: [BlocProvider(create: (context) => ChangePasswordCubit())],
        child: const ChangePasswordScreen(),
      ),
    );
  }
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onChangePasswordButtonPressed() {
    UiUtils.removeFocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<ChangePasswordCubit>().changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      loginType: context.read<UserDetailsCubit>().getUserDetails().loginType!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        backgroundColor: context.colors.backgroundSecondary,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: "changePassword".translate(context: context),
          backgroundColor: context.colors.backgroundPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        body: BlocListener<ChangePasswordCubit, ChangePasswordState>(
          listener: (context, state) {
            if (state is ChangePasswordSuccess) {
              UiUtils.showMessage(
                context,
                state.message.translate(context: context),
                ToastificationType.success,
              );
              Navigator.pop(context);
            } else if (state is ChangePasswordFail) {
              UiUtils.showMessage(
                context,
                state.error.translate(context: context),
                ToastificationType.error,
              );
            }
          },
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      controller: _currentPasswordController,
                      labelText: "currentPassword".translate(context: context),
                      hintText: "enterCurrentPassword".translate(
                        context: context,
                      ),
                      isRequired: true,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "fieldMustNotBeEmpty".translate(
                            context: context,
                          );
                        }
                        return null;
                      },
                    ),
                    const CustomSizedBox(height: 16),
                    CustomPasswordFieldWithValidators(
                      controller: _newPasswordController,
                      labelText: "newPassword".translate(context: context),
                      hintText: "enterNewPassword".translate(context: context),
                      isRequired: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) => isValidPassword(
                        password: value ?? '',
                        context: context,
                      ),
                    ),
                    const CustomSizedBox(height: 16),
                    CustomTextFormField(
                      controller: _confirmPasswordController,
                      labelText: "confirmPassword".translate(context: context),
                      hintText: "enterConfirmPassword".translate(
                        context: context,
                      ),
                      isRequired: true,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) => confirmPasswordValidator(
                        password: _newPasswordController.text,
                        confirmPassword: value ?? '',
                        context: context,
                      ),
                    ),
                    const CustomSizedBox(height: 24),
                    BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                      builder: (context, state) {
                        final isLoading = state is ChangePasswordInProgress;
                        return CustomRoundedButton(
                          widthPercentage: 1,
                          height: 48,
                          radius: 12,
                          textSize: 16,
                          fontWeight: FontWeight.w500,
                          backgroundColor: context.colors.backgroundBrand,
                          buttonTitle: isLoading
                              ? ""
                              : "updatePassword".translate(context: context),
                          showBorder: false,
                          onTap: isLoading
                              ? null
                              : _onChangePasswordButtonPressed,
                          titleColor: context.colors.textInverseLight,
                          child: isLoading
                              ? CustomCircularProgressIndicator(
                                  color: context.colors.textInverseLight,
                                )
                              : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
