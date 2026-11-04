import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class CustomPasswordFieldWithValidators extends StatefulWidget {
  const CustomPasswordFieldWithValidators({
    required this.controller,
    super.key,
    this.textInputAction,
    this.currentFocusNode,
    this.nextFocusNode,
    this.labelText,
    this.hintText,
    this.validator,
    this.isRequired = false,
  });

  final TextEditingController controller;
  final FocusNode? currentFocusNode;
  final FocusNode? nextFocusNode;
  final TextInputAction? textInputAction;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool isRequired;

  @override
  State<CustomPasswordFieldWithValidators> createState() =>
      _CustomPasswordFieldWithValidatorsState();
}

class _CustomPasswordFieldWithValidatorsState
    extends State<CustomPasswordFieldWithValidators> {
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validatePassword);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validatePassword);
    super.dispose();
  }

  void _validatePassword() {
    final password = widget.controller.text;

    setState(() {
      hasMinLength =
          password.length >=
          (context
                  .read<SystemSettingCubit>()
                  .loginSettings
                  ?.minumumPasswordLength ??
              0);
      hasUppercase = password.contains(RegExp('[A-Z]'));
      hasLowercase = password.contains(RegExp('[a-z]'));
      hasNumber = password.contains(RegExp('[0-9]'));
      hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  Widget _buildLabel(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: 4),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          widget.labelText!.translate(context: context),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: context.colors.textPrimary,
        ),
        if (widget.isRequired) ...[
          const CustomSizedBox(width: 4),
          CustomText('*', fontSize: 14, color: context.colors.textError),
        ],
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final loginSettings = context.read<SystemSettingCubit>().loginSettings;
    final bool showsChecklist = loginSettings != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) _buildLabel(context),
        CustomContainer(
          avoideResponsive: true,
          color: context.colors.backgroundPrimary,
          borderRadius: 8,
          border: Border.all(color: context.colors.borderDefault, width: 0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFormField(
                controller: widget.controller,
                hintText: widget.hintText,
                isPassword: true,
                textInputAction: widget.textInputAction,
                currentFocusNode: widget.currentFocusNode,
                nextFocusNode: widget.nextFocusNode,
                validator: widget.validator,
                bottomPadding: 0,
                borderColor: Colors.transparent,
                focusedBorderColor: Colors.transparent,
                fillColor: Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              if (showsChecklist) ...[
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: context.colors.borderDefault,
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      if (loginSettings.minumumPasswordLength != null)
                        _buildValidationItem(
                          "${"passwordMustBeAtLeastChars".translate(context: context)} ${loginSettings.minumumPasswordLength!} ${"characterLong".translate(context: context)}",
                          hasMinLength,
                        ),
                      if (loginSettings.requireAtLeastOneUppercase == true)
                        _buildValidationItem(
                          'passwordMustHaveUppercase'.translate(
                            context: context,
                          ),
                          hasUppercase,
                        ),
                      if (loginSettings.requireAtLeastOneLowercase == true)
                        _buildValidationItem(
                          'passwordMustHaveLowercase'.translate(
                            context: context,
                          ),
                          hasLowercase,
                        ),
                      if (loginSettings.requireAtLeastOneNumber == true)
                        _buildValidationItem(
                          'passwordMustHaveNumber'.translate(context: context),
                          hasNumber,
                        ),
                      if (loginSettings.requireAtLeastOneSpecialCharacter ==
                          true)
                        _buildValidationItem(
                          'passwordMustHaveSpecialChar'.translate(
                            context: context,
                          ),
                          hasSpecialChar,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValidationItem(String text, bool isValid) {
    final greyColor = context.colors.textTertiary;
    final iconValidColor = context.colors.backgroundBrand;
    final textValidColor = context.colors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          TweenAnimationBuilder<Color?>(
            duration: const Duration(milliseconds: 300),
            tween: ColorTween(
              begin: greyColor,
              end: isValid ? iconValidColor : greyColor,
            ),
            builder: (context, color, child) => CustomSvgPicture(
              svgImage: isValid
                  ? AppAssets.checkCircleFill
                  : AppAssets.checkCircle,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TweenAnimationBuilder<Color?>(
              duration: const Duration(milliseconds: 300),
              tween: ColorTween(
                begin: greyColor,
                end: isValid ? textValidColor : greyColor,
              ),
              builder: (context, color, child) {
                return CustomText(
                  text,
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
