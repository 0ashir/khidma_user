import 'package:e_demand/data/enums/userStatusEnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../app/generalImports.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({required this.source, final Key? key})
    : super(key: key);

  final String source;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();

  static Route route(final RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>?;
    final String source = arguments?['source'] as String? ?? '';

    return CupertinoPageRoute(
      builder: (final _) => RegisterScreen(source: source),
    );
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _credentialController = TextEditingController();
  final ValueNotifier<int> _numberLength = ValueNotifier(0);
  final FocusNode _credentialFocusNode = FocusNode();
  String _phoneNumberWithCountryCode = '';
  String _onlyPhoneNumber = '';
  String _countryCode = '';
  bool _isEmailMode = false;
  bool _isAccountDeactivated = false;

  @override
  void initState() {
    super.initState();

    //phone is the default, so the only reason to open on email is that phone
    //sign-up is switched off entirely
    _isEmailMode =
        !(context
                .read<SystemSettingCubit>()
                .loginSettings
                ?.isPhoneAuthEnabled ??
            false);
  }

  @override
  void dispose() {
    _credentialController.dispose();
    _numberLength.dispose();
    _credentialFocusNode.dispose();
    super.dispose();
  }

  bool get _isEmail =>
      !RegExp(r'^[0-9]+$').hasMatch(_credentialController.text.trim());

  /// Points the credential field at one kind of credential and puts the caret
  /// in it. What was typed for the other kind is dropped — a phone number is
  /// never a valid email, and the formatters would strip it anyway.
  void _switchCredentialMode({required final bool isEmailMode}) {
    UiUtils.removeFocus();
    _credentialController.clear();
    _numberLength.value = 0;
    setState(() {
      _isEmailMode = isEmailMode;
      _isAccountDeactivated = false;
    });
    //the field is rebuilt by the mode change, so it can only take focus once
    //that build has landed
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      if (mounted) _credentialFocusNode.requestFocus();
    });
  }

  void _onContinuePressed() {
    UiUtils.removeFocus();

    if (!_formKey.currentState!.validate()) return;

    final String inputText = _credentialController.text.trim();

    final String? countryCallingCode = _isEmail
        ? null
        : context.read<CountryCodeCubit>().getSelectedCountryCode();

    _phoneNumberWithCountryCode = _isEmail
        ? inputText
        : (countryCallingCode! + inputText);
    _onlyPhoneNumber = _isEmail ? '' : inputText;
    _countryCode = countryCallingCode ?? '';

    context.read<CheckIsUserExistsCubit>().isUserExists(
      mobileNumber: _isEmail ? null : _onlyPhoneNumber,
      countryCode: _isEmail ? null : _countryCode,
      email: _isEmail ? inputText : null,
      uid: '',
      loginType: _isEmail ? LogInType.email : LogInType.phone,
    );
  }

  Future<void> _handleCheckIsUserExistsState(
    final CheckIsUserExistsState state,
  ) async {
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

    if (state is! CheckIsUserExistsSuccess) return;
    if (state.loginType != LogInType.phone &&
        state.loginType != LogInType.email) {
      return;
    }

    if (state.isError) {
      UiUtils.showMessage(
        context,
        state.errorMessage,
        ToastificationType.warning,
      );
      return;
    }

    final UserStatus? userStatus = UserStatus.fromCode(state.statusCode);

    if (userStatus == null) {
      UiUtils.showMessage(
        context,
        'unknownStatus'.translate(context: context),
        ToastificationType.error,
      );
      return;
    }

    if (userStatus == UserStatus.deactive) {
      setState(() {
        _isAccountDeactivated = true;
      });
      return;
    }

    if (userStatus != UserStatus.notRegistered) {
      UiUtils.showMessage(
        context,
        'accountAlreadyExistsPleaseSignIn'.translate(context: context),
        ToastificationType.warning,
      );
      _goToLogin();
      return;
    }

    final bool isEmailAuth = state.email != null && state.email!.isNotEmpty;

    if (state.authenticationType == "sms_gateway" || isEmailAuth) {
      UiUtils.showMessage(
        context,
        'otpSentSuccessfully'.translate(context: context),
        ToastificationType.success,
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.pushNamed(
          context,
          otpVerificationRoute,
          arguments: {
            'phoneNumberWithCountryCode': _phoneNumberWithCountryCode,
            'phoneNumberWithOutCountryCode': _onlyPhoneNumber,
            'countryCode': _countryCode,
            'email': state.email,
            'source': widget.source,
            "userAuthenticationCode": state.statusCode,
            "authenticationType": state.authenticationType,
            "hasPassword": state.hasPassword,
            "isForPasswordSet": false,
            "autoSendOtp": false,
          },
        );
      });
    } else {
      context.read<SendVerificationCodeCubit>().sendVerificationCode(
        phoneNumber: _phoneNumberWithCountryCode,
        userAuthenticationCode: state.statusCode,
        authenticationType: state.authenticationType,
        hasPassword: state.hasPassword,
        isForPasswordSet: false,
      );
    }
  }

  void _handleSendVerificationCodeState(final SendVerificationCodeState state) {
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

    if (state is SendVerificationCodeSuccessState) {
      Navigator.pushNamed(
        context,
        otpVerificationRoute,
        arguments: {
          'phoneNumberWithCountryCode': _phoneNumberWithCountryCode,
          'phoneNumberWithOutCountryCode': _onlyPhoneNumber,
          'countryCode': _countryCode,
          'source': widget.source,
          "userAuthenticationCode": state.userAuthenticationCode,
          "authenticationType": state.authenticationType,
          "hasPassword": state.hasPassword,
          "isForPasswordSet": state.isForPasswordSet,
        },
      );
    } else if (state is SendVerificationCodeFailureState) {
      UiUtils.showMessage(
        context,
        state.error.toString().translate(context: context),
        ToastificationType.error,
      );
    }
  }

  Widget _buildWelcomeContainer() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Image.asset(AppAssets.loginLogoLight, width: 64, height: 64),
      const CustomSizedBox(height: 16),
      CustomText(
        (_isEmailMode ? 'signUpWithEmail' : 'signUpWithPhoneNumber').translate(
          context: context,
        ),
        color: context.colors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 24,
      ),
      const CustomSizedBox(height: 4),
      CustomText(
        (_isEmailMode
                ? 'enterEmailToCreateAccount'
                : 'enterPhoneNumberToCreateAccount')
            .translate(context: context),
        color: context.colors.textSecondary,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
    ],
  );

  Widget _buildCredentialField() => EmailOrPhoneCredentialField(
    fieldKey: ValueKey<bool>(_isEmailMode),
    controller: _credentialController,
    focusNode: _credentialFocusNode,
    isEmailMode: _isEmailMode,
    onChanged: (final String value) {
      _numberLength.value = value.length;
      setState(() {
        _isAccountDeactivated = false;
      });
    },
  );

  Widget _buildTermsFooter() => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            "byRegisteringYouAgreeTo".translate(context: context),
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w400,
            color: context.colors.textSecondary,
            fontSize: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomInkWellContainer(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    customPageDetailsRoute,
                    arguments: {
                      "title": "termsofservice".translate(context: context),
                      "pageKey": "customer_terms_conditions",
                    },
                  );
                },
                child: CustomText(
                  "termsAndConditions".translate(context: context),
                  color: context.colors.textPrimary,
                  showUnderline: true,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              CustomText(
                " ${"and".translate(context: context)} ",
                color: context.colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              CustomInkWellContainer(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    customPageDetailsRoute,
                    arguments: {
                      "title": "privacyAndPolicy".translate(context: context),
                      "pageKey": "customer_privacy_policy",
                    },
                  );
                },
                child: CustomText(
                  "privacyAndPolicy".translate(context: context),
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w400,
                  showUnderline: true,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildContinueButton() =>
      BlocConsumer<CheckIsUserExistsCubit, CheckIsUserExistsState>(
        listener: (final context, final state) =>
            _handleCheckIsUserExistsState(state),
        builder: (context, checkIsUserExistsState) {
          final bool isCheckingUserExists =
              checkIsUserExistsState is CheckIsUserExistsInProgress;

          return BlocConsumer<
            SendVerificationCodeCubit,
            SendVerificationCodeState
          >(
            listener: (final context, final state) =>
                _handleSendVerificationCodeState(state),
            builder: (context, sendVerificationCodeState) {
              final bool isSendingCode =
                  sendVerificationCodeState
                      is SendVerificationCodeInProgressState;

              final bool isDisabled = _credentialController.text.trim().isEmpty;

              return CustomRoundedButton(
                buttonTitle: '',
                showBorder: false,
                widthPercentage: 1,
                radius: 12,
                backgroundColor: isDisabled
                    ? context.colors.component.buttonPrimaryDisabled
                    : context.colors.backgroundBrand,
                onTap: () {
                  if (isDisabled || isCheckingUserExists || isSendingCode) {
                    return;
                  }
                  _onContinuePressed();
                },
                child: (isCheckingUserExists || isSendingCode)
                    ? CustomSizedBox(
                        height: 20,
                        width: 20,
                        child: CustomCircularProgressIndicator(
                          color: context.colors.textInverseLight,
                        ),
                      )
                    : CustomText(
                        'continue'.translate(context: context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDisabled
                            ? context.colors.textDisabled
                            : context.colors.textInverseLight,
                      ),
              );
            },
          );
        },
      );

  /// Register is only ever pushed on top of login, so heading back to login
  /// pops to it. Pushing a fresh login here would stack a duplicate each time
  /// the user bounces between the two screens.
  void _goToLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushReplacementNamed(
      context,
      loginRoute,
      arguments: {'source': widget.source},
    );
  }

  Widget _buildLoginRow() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CustomText(
        'alreadyHaveAnAccount'.translate(context: context),
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: context.colors.textSecondary,
      ),
      const CustomSizedBox(width: 4),
      CustomInkWellContainer(
        onTap: _goToLogin,
        child: CustomText(
          'signIn'.translate(context: context),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.colors.textBrand,
        ),
      ),
    ],
  );

  @override
  Widget build(final BuildContext context) {
    final loginSettings = context.read<SystemSettingCubit>().loginSettings;
    final bool isSocialLoginEnabled =
        loginSettings?.isSocialLoginEnabled ?? false;
    final bool isEmailAuthEnabled = loginSettings?.isEmailAuthEnabled ?? false;
    final bool isPhoneAuthEnabled = loginSettings?.isPhoneAuthEnabled ?? false;

    //the email button only offers something the field is not already set up
    //for when both kinds of credential are accepted
    final bool showEmailButton = isEmailAuthEnabled && isPhoneAuthEnabled;
    final bool hasAlternatives = isSocialLoginEnabled || showEmailButton;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: AnnotatedSafeArea(
        isAnnotated: true,
        applyBottomInset: false,
        child: Scaffold(
          backgroundColor: context.colors.backgroundSecondary,
          appBar: const AuthAppBar(),
          body: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.isTabletDevice(context) ? 48 : 16,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CustomSizedBox(height: 24),
                      _buildWelcomeContainer(),
                      const CustomSizedBox(height: 24),
                      if (_isAccountDeactivated) ...[
                        const AccountDeactivatedBanner(),
                        const CustomSizedBox(height: 16),
                      ],
                      ValueListenableBuilder<int>(
                        valueListenable: _numberLength,
                        builder: (context, _, __) => _buildCredentialField(),
                      ),
                      const CustomSizedBox(height: 24),
                      _buildContinueButton(),
                      if (hasAlternatives) ...[
                        const CustomSizedBox(height: 16),
                        const OrContinueWithDivider(),
                        const CustomSizedBox(height: 16),
                        if (showEmailButton) ...[
                          SocialSignInButton(
                            icon: CustomSvgPicture(
                              avoideResponsive: true,
                              svgImage: _isEmailMode
                                  ? AppAssets.phone
                                  : AppAssets.envelopeSimple,
                              height: 24,
                              width: 24,
                              color: context.colors.iconPrimary,
                            ),
                            label: _isEmailMode
                                ? 'continueWithPhoneNumber'
                                : 'continueWithEmail',
                            onTap: () => _switchCredentialMode(
                              isEmailMode: !_isEmailMode,
                            ),
                          ),
                          const CustomSizedBox(height: 8),
                        ],
                        if (isSocialLoginEnabled) ...[
                          SocialAuthButtons(
                            source: widget.source,
                            isSignUp: true,
                            onAccountDeactivated: () => setState(() {
                              _isAccountDeactivated = true;
                            }),
                          ),
                        ],
                      ],
                      const CustomSizedBox(height: 16),
                      _buildLoginRow(),
                      const CustomSizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: _buildTermsFooter(),
        ),
      ),
    );
  }
}
