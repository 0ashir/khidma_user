import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/data/model/countryCodeModel.dart';
import 'package:flutter/material.dart';

class EmailOrPhoneCredentialField extends StatelessWidget {
  const EmailOrPhoneCredentialField({
    required this.controller,
    required this.isEmailMode,
    required this.onChanged,
    this.focusNode,
    this.fieldKey,
    super.key,
  });

  final TextEditingController controller;
  final bool isEmailMode;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final Key? fieldKey;

  @override
  Widget build(final BuildContext context) => CustomTextFormField(
    key: fieldKey,
    controller: controller,
    currentFocusNode: focusNode,
    labelText: isEmailMode ? 'email' : 'phoneNumber',
    isRequired: true,
    hintText: isEmailMode ? 'enterEmail' : 'enterYourPhoneNumber',
    hintTextColor: context.colors.textTertiary,
    fillColor: context.colors.backgroundPrimary,
    borderColor: context.colors.borderDefault,
    borderWidth: 1.5,
    focusedBorderColor: context.colors.borderFocus,
    focusedBorderWidth: 1,
    bottomPadding: 0,
    textInputType: isEmailMode
        ? TextInputType.emailAddress
        : TextInputType.phone,
    inputFormatters: isEmailMode
        ? null
        : [FilteringTextInputFormatter.digitsOnly],
    prefix: isEmailMode ? null : const _CountryCodePrefix(),
    onChanged: onChanged,
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return "fieldMustNotBeEmpty".translate(context: context);
      }
      return isEmailMode
          ? isValidEmail(email: value, context: context)
          : isValidMobileNumber(number: value, context: context);
    },
  );
}

class _CountryCodePrefix extends StatelessWidget {
  const _CountryCodePrefix();

  @override
  Widget build(final BuildContext context) =>
      BlocBuilder<CountryCodeCubit, CountryCodeState>(
        builder: (final BuildContext context, final CountryCodeState state) {
          final CountryCodeModel? country = state is CountryCodeFetchSuccess
              ? state.selectedCountry
              : null;

          final bool isPickerAvailable =
              !allowOnlySingleCountry &&
              !(state is CountryCodeFetchSuccess &&
                  (state.temporaryCountryList?.length ?? 0) == 1);

          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, end: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomInkWellContainer(
                  onTap: isPickerAvailable
                      ? () {
                          Navigator.pushNamed(
                            context,
                            countryCodePickerRoute,
                          ).then((final Object? value) {
                            Future.delayed(
                              const Duration(milliseconds: 250),
                            ).then((final value) {
                              if (!context.mounted) return;
                              context
                                  .read<CountryCodeCubit>()
                                  .fillTemporaryList();
                            });
                          });
                        }
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CountryFlag(country),
                      const CustomSizedBox(width: 4),
                      CustomText(
                        country?.callingCode ?? '--',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: context.colors.textPrimary,
                      ),
                      if (isPickerAvailable) ...[
                        const CustomSizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: context.colors.iconPrimary,
                        ),
                      ],
                    ],
                  ),
                ),
                const CustomSizedBox(width: 12),
                CustomContainer(
                  avoideResponsive: true,
                  width: 1,
                  height: 16,
                  color: context.colors.borderDefault,
                ),
              ],
            ),
          );
        },
      );
}

class _CountryFlag extends StatelessWidget {
  const _CountryFlag(this.country);

  final CountryCodeModel? country;

  static const double _width = 20;
  static const double _height = 15;

  @override
  Widget build(final BuildContext context) {
    if (country == null) {
      return const CustomSizedBox(width: _width, height: _height);
    }

    return CustomSizedBox(
      width: _width,
      height: _height,
      child: country!.flagImage.startsWith('http')
          ? Image.network(
              country!.flagImage,
              fit: BoxFit.cover,
              errorBuilder: (final context, final error, final stackTrace) =>
                  Image.asset(
                    'assets/images/flags/${country!.countryCode.toLowerCase()}.png',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (final context, final error, final stackTrace) =>
                            const Icon(Icons.flag, size: _height),
                  ),
            )
          : Image.asset(country!.flag, fit: BoxFit.cover),
    );
  }
}
