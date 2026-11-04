import 'package:e_demand/data/enums/userStatusEnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../app/generalImports.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({required this.source, final Key? key}) : super(key: key);
  final String source;

  @override
  State<LogInScreen> createState() => _LogInScreenState();

  static Route route(final RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    final String source = arguments['source'];

    return CupertinoPageRoute(
      builder: (final _) => LogInScreen(source: source),
    );
  }
}

class _LogInScreenState extends State<LogInScreen> {
  String phoneNumberWithCountryCode = '';
  String onlyPhoneNumber = '';
  String countryCode = '';
  final GlobalKey<FormState> verifyPhoneNumberFormKey = GlobalKey<FormState>();
  final TextEditingController _numberFieldController = TextEditingController();
  ValueNotifier<int> numberLength = ValueNotifier(0);
  final TextEditingController _passwordController = TextEditingController();
  bool showPasswordField = false;
  bool userHasPassword = false;
  final FocusNode _credentialFocusNode = FocusNode();
  bool _isEmailMode = false;
  bool _isAccountDeactivated = false;
  bool get _isPasswordLoginEnabled =>
      context
          .read<SystemSettingCubit>()
          .loginSettings
          ?.isPasswordLoginEnabled ??
      false;

  @override
  void dispose() {
    _numberFieldController.dispose();
    _passwordController.dispose();
    _credentialFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //phone is the default, so the only reason to open on email is that phone
    //sign-in is switched off entirely
    _isEmailMode =
        !(context
                .read<SystemSettingCubit>()
                .loginSettings
                ?.isPhoneAuthEnabled ??
            false);

    if (context.read<SystemSettingCubit>().isDemoModeEnabled) {
      _numberFieldController.text = "9876543210";
      _passwordController.text = "Test@123";
      numberLength.value = 10;
    }
  }

  void _onContinueButtonClicked() {
    UiUtils.removeFocus();

    final inputText = _numberFieldController.text.trim();
    if (inputText.isEmpty) {
      return;
    }

    final bool isEmail = !RegExp(r'^[0-9]+$').hasMatch(inputText);

    // Validate based on input type
    if (!isEmail) {
      if (numberLength.value < UiUtils.minimumMobileNumberDigit ||
          numberLength.value > UiUtils.maximumMobileNumberDigit) {
        return;
      }
    }

    final bool isValidInput = verifyPhoneNumberFormKey.currentState!.validate();

    if (!isValidInput) {
      return;
    }

    // Get country code for phone numbers
    final String? countryCallingCode = isEmail
        ? null
        : context.read<CountryCodeCubit>().getSelectedCountryCode();

    // Check if password login is enabled and user wants to login with password
    final bool isPasswordLoginEnabled =
        context
            .read<SystemSettingCubit>()
            .loginSettings
            ?.isPasswordLoginEnabled ??
        false;

    if (isPasswordLoginEnabled &&
        showPasswordField &&
        _passwordController.text.isNotEmpty) {
      // Login with password
      _loginWithPassword(inputText, countryCallingCode);
    } else {
      // Check if user exists and has password
      phoneNumberWithCountryCode = isEmail
          ? inputText
          : (countryCallingCode! + inputText);
      onlyPhoneNumber = isEmail ? '' : inputText;
      countryCode = countryCallingCode ?? '';

      context.read<CheckIsUserExistsCubit>().isUserExists(
        mobileNumber: isEmail ? null : onlyPhoneNumber,
        countryCode: isEmail ? null : countryCode,
        email: isEmail ? inputText : null,
        uid: '',
        loginType: isEmail ? LogInType.email : LogInType.phone,
      );
    }
  }

  bool _isLoggingIn = false;
  bool _isForgotPasswordFlow = false;

  void _handleForgotPasswordClick() {
    final inputText = _numberFieldController.text.trim();
    if (inputText.isEmpty) {
      UiUtils.showMessage(
        context,
        'pleaseEnterEmailOrPhone'.translate(context: context),
        ToastificationType.warning,
      );
      return;
    }

    final bool isEmail = !RegExp(r'^[0-9]+$').hasMatch(inputText);

    final String? countryCallingCode = isEmail
        ? null
        : context.read<CountryCodeCubit>().getSelectedCountryCode();

    phoneNumberWithCountryCode = isEmail
        ? inputText
        : (countryCallingCode! + inputText);
    onlyPhoneNumber = isEmail ? '' : inputText;
    countryCode = countryCallingCode ?? '';

    // Set flag to trigger forgot password flow
    _isForgotPasswordFlow = true;

    // For forgot password, we need to check if user exists first to get authentication type
    // This is necessary because the authentication mode comes from the backend
    context.read<CheckIsUserExistsCubit>().isUserExists(
      mobileNumber: isEmail ? null : onlyPhoneNumber,
      countryCode: isEmail ? null : countryCode,
      email: isEmail ? inputText : null,
      uid: '',
      loginType: isEmail ? LogInType.email : LogInType.phone,
      isForForgotPassword: true,
    );
  }

  Future<void> _loginWithPassword(String input, String? countryCode) async {
    if (_isLoggingIn || _isAccountDeactivated) return;

    setState(() {
      _isLoggingIn = true;
    });

    final latitude = HiveRepository.getLatitude ?? '0.0';
    final longitude = HiveRepository.getLongitude ?? '0.0';

    String fcmId = '';
    try {
      fcmId = await FirebaseMessaging.instance.getToken() ?? '';
    } catch (_) {}

    if (!mounted) return;

    // Determine if input is email or phone
    final bool isEmail = input.contains('@');

    try {
      // Use manage_user API (loginUser) with password parameter
      final UserDetailsModel userDetails =
          await AuthenticationRepository.loginUser(
            uid: '',
            fcmId: fcmId,
            latitude: latitude,
            longitude: longitude,
            loginType: isEmail ? LogInType.email : LogInType.phone,
            email: isEmail ? input : null,
            mobileNumber: isEmail ? null : input,
            countryCode: isEmail ? null : countryCode,
            password: _passwordController.text,
          );

      // Store user data
      HiveRepository.setUserFirstTimeInApp = false;
      HiveRepository.setUserLoggedIn = true;

      if (mounted) {
        context.read<AuthenticationCubit>().checkStatus();
        context.read<UserDetailsCubit>().setUserDetails(userDetails);

        UiUtils.showMessage(
          context,
          'userLoggedInSuccessfully'.translate(context: context),
          ToastificationType.success,
        );

        // Fetch initial data
        await context.read<SystemSettingCubit>().getSystemSettings();
        if (!mounted) return;
        await context.read<UserDetailsCubit>().loadUserDetails();
        if (!mounted) return;
        final futures = <Future>[
          context.read<BookingCubit>().fetchAllBookings(status: ''),
          context.read<HomeScreenCubit>().fetchHomeScreenData(),
          context.read<CartCubit>().getCartDetails(isReorderCart: false),
          context.read<BookmarkCubit>().fetchBookmark(type: "list"),
          context.read<MyRequestListCubit>().fetchRequests(),
          context.read<EnquiryChatUserCubit>().fetchChatUsers(),
          context.read<BookingChatUserCubit>().fetchChatUsers(),
        ];
        Future.wait(futures);

        // Navigate to home
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            navigationRoute,
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });

        UiUtils.showMessage(
          context,
          e.toString().translate(context: context),
          ToastificationType.error,
        );
      }
    }
  }

  Widget _buildCredentialField() => EmailOrPhoneCredentialField(
    fieldKey: ValueKey<bool>(_isEmailMode),
    controller: _numberFieldController,
    focusNode: _credentialFocusNode,
    isEmailMode: _isEmailMode,
    onChanged: (final String value) {
      numberLength.value = value.length;
      //the account the password belonged to is no longer the one on screen
      setState(() {
        showPasswordField = false;
        _isAccountDeactivated = false;
      });
    },
  );

  Widget _buildPasswordField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomTextFormField(
        controller: _passwordController,
        labelText: 'password',
        isRequired: true,
        hintText: 'enterPassword',
        hintTextColor: context.colors.textTertiary,
        fillColor: context.colors.backgroundPrimary,
        borderColor: context.colors.borderDefault,
        borderWidth: 1.5,
        focusedBorderColor: context.colors.borderFocus,
        focusedBorderWidth: 1,
        bottomPadding: 0,
        isPassword: true,
        textInputAction: TextInputAction.done,
        validator: (final value) {
          if (!_isPasswordLoginEnabled) return null;
          if (value == null || value.isEmpty) {
            return "fieldMustNotBeEmpty".translate(context: context);
          }
          return null;
        },
      ),
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: CustomInkWellContainer(
          onTap: _handleForgotPasswordClick,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: CustomText(
              "forgotPassword".translate(context: context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.colors.textBrand,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildWelcomeContainer() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Image.asset(AppAssets.loginLogoLight, width: 64, height: 64),
      const CustomSizedBox(height: 16),
      CustomText(
        'welcomeBack'.translate(context: context),
        color: context.colors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 24,
      ),
      const CustomSizedBox(height: 4),
      CustomText(
        'signInSubtitle'.translate(context: context),
        color: context.colors.textSecondary,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
    ],
  );

  void _switchCredentialMode({required final bool isEmailMode}) {
    UiUtils.removeFocus();
    _numberFieldController.clear();
    numberLength.value = 0;
    setState(() {
      _isEmailMode = isEmailMode;
      showPasswordField = false;
      _isAccountDeactivated = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      if (mounted) _credentialFocusNode.requestFocus();
    });
  }

  Widget _buildRegisterRow() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CustomText(
        'dontHaveAnAccount'.translate(context: context),
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: context.colors.textSecondary,
      ),
      const CustomSizedBox(width: 4),
      CustomInkWellContainer(
        onTap: () => Navigator.pushNamed(
          context,
          registerRoute,
          arguments: {'source': widget.source},
        ),
        child: CustomText(
          'register'.translate(context: context),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.colors.textBrand,
        ),
      ),
    ],
  );

  Widget _buildSkipButton() => Align(
    alignment: AlignmentDirectional.centerEnd,
    child: BlocBuilder<VerifyOtpCubit, VerifyOtpState>(
      builder: (final context, final VerifyOtpState state) =>
          CustomInkWellContainer(
            onTap: (state is SendVerificationCodeInProgressState)
                ? () {
                    UiUtils.showMessage(
                      context,
                      'verificationIsInProgress'.translate(context: context),
                      ToastificationType.warning,
                    );
                  }
                : () async {
                    HiveRepository.setUserSkippedTheLoginBefore = true;
                    if (widget.source == 'dialog') {
                      Navigator.pop(context);
                    } else if (Routes.previousRoute == onBoardingRoute ||
                        Routes.previousRoute == splashRoute) {
                      await Navigator.pushReplacementNamed(
                        context,
                        navigationRoute,
                      );
                    } else if (Routes.previousRoute == navigationRoute ||
                        Routes.previousRoute == loginRoute) {
                      Navigator.pop(context);
                    } else {
                      await Navigator.pushReplacementNamed(
                        context,
                        navigationRoute,
                      );
                    }
                  },
            child: CustomContainer(
              borderRadius: UiUtils.borderRadiusOf20,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: CustomText(
                'skip'.translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: context.colors.textBrand,
              ),
            ),
          ),
    ),
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
          body: MultiBlocListener(
            listeners: [
              BlocListener<CheckIsUserExistsCubit, CheckIsUserExistsState>(
                listener:
                    (
                      final BuildContext context,
                      final CheckIsUserExistsState state,
                    ) {
                      // Check if user has password and password login is enabled
                      if (state is CheckIsUserExistsSuccess) {
                        final userStatus = UserStatus.fromCode(
                          state.statusCode,
                        );
                        if (userStatus == UserStatus.deactive) {
                          return;
                        }

                        final bool isPasswordLoginEnabled =
                            context
                                .read<SystemSettingCubit>()
                                .loginSettings
                                ?.isPasswordLoginEnabled ??
                            false;

                        if (isPasswordLoginEnabled &&
                            state.hasPassword == true) {
                          setState(() {
                            showPasswordField = true;
                            userHasPassword = true;
                          });

                          //password was already typed alongside the identifier,
                          //so chain straight into login instead of waiting for
                          //a second tap on the same button
                          if (!_isForgotPasswordFlow &&
                              _passwordController.text.trim().isNotEmpty) {
                            _loginWithPassword(
                              _numberFieldController.text.trim(),
                              countryCode.isEmpty ? null : countryCode,
                            );
                          }
                        }
                      }
                    },
              ),
            ],
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.isTabletDevice(context)
                      ? 48
                      : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CustomSizedBox(height: 8),
                    _buildSkipButton(),
                    const CustomSizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: verifyPhoneNumberFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildWelcomeContainer(),
                              const CustomSizedBox(height: 24),
                              if (_isAccountDeactivated) ...[
                                const AccountDeactivatedBanner(),
                                const CustomSizedBox(height: 16),
                              ],
                              _buildCredentialField(),
                              if (_isPasswordLoginEnabled &&
                                  showPasswordField) ...[
                                const CustomSizedBox(height: 16),
                                _buildPasswordField(),
                              ],
                              const CustomSizedBox(height: 24),
                              _buildSignInButton(),
                              if (hasAlternatives) ...[
                                const CustomSizedBox(height: 24),
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
                                        ? 'signInWithPhoneNumber'
                                        : 'signInWithEmail',
                                    onTap: () => _switchCredentialMode(
                                      isEmailMode: !_isEmailMode,
                                    ),
                                  ),
                                  const CustomSizedBox(height: 8),
                                ],
                                if (isSocialLoginEnabled) ...[
                                  SocialAuthButtons(
                                    source: widget.source,
                                    onAccountDeactivated: () => setState(() {
                                      _isAccountDeactivated = true;
                                    }),
                                  ),
                                ],
                              ],
                              const CustomSizedBox(height: 16),
                              _buildRegisterRow(),
                              const CustomSizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: _buildTermsFooter(),
        ),
      ),
    );
  }

  Widget
  _buildSignInButton() => BlocConsumer<CheckIsUserExistsCubit, CheckIsUserExistsState>(
    listener: (final BuildContext context, final CheckIsUserExistsState state) async {
      //this screen can stay mounted (just obscured) under Register/OTP —
      //shares this same app-level cubit, so a stale instance must not act on it
      if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

      if (state is CheckIsUserExistsSuccess) {
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

        final userStatus = UserStatus.fromCode(state.statusCode);

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
        } else {
          // Check if password login is enabled and user has password
          final bool isPasswordLoginEnabled =
              context
                  .read<SystemSettingCubit>()
                  .loginSettings
                  ?.isPasswordLoginEnabled ??
              false;

          // Check if it's an email or phone
          final bool isEmailAuth =
              state.email != null && state.email!.isNotEmpty;

          // Send OTP for:
          // 1. New users (status 102) - need to verify before registration
          // 2. Forgot password flow
          // 3. Existing users without password (status 101) - need to set password
          if (userStatus == UserStatus.notRegistered ||
              _isForgotPasswordFlow ||
              (userStatus == UserStatus.active &&
                  isPasswordLoginEnabled &&
                  !state.hasPassword)) {
            // Determine if this is for new user registration or password set
            final bool isNewUserRegistration =
                userStatus == UserStatus.notRegistered;
            _isForgotPasswordFlow = false; // Reset the flag

            if (state.authenticationType == "sms_gateway" || isEmailAuth) {
              // SMS Gateway - navigate directly to OTP screen
              // Note: For forgot password and new user, verify_user already sends OTP,
              // so we don't need autoSendOtp flag to avoid duplicate API calls

              // Show success message before navigating
              UiUtils.showMessage(
                context,
                'otpSentSuccessfully'.translate(context: context),
                ToastificationType.success,
              );

              Future.delayed(const Duration(milliseconds: 500), () {
                if (!context.mounted) return;
                Navigator.pushNamed(
                  context,
                  otpVerificationRoute,
                  arguments: {
                    'phoneNumberWithCountryCode': phoneNumberWithCountryCode,
                    'phoneNumberWithOutCountryCode': onlyPhoneNumber,
                    'countryCode': countryCode,
                    'email': state.email,
                    'source': widget.source,
                    "userAuthenticationCode": state.statusCode,
                    "authenticationType": state.authenticationType,
                    "hasPassword": state.hasPassword,
                    "isForPasswordSet": !isNewUserRegistration,
                    "autoSendOtp": false,
                  },
                );
              });
            } else {
              // Firebase authentication - send OTP via Firebase then navigate
              context.read<SendVerificationCodeCubit>().sendVerificationCode(
                phoneNumber: phoneNumberWithCountryCode,
                userAuthenticationCode: state.statusCode,
                authenticationType: state.authenticationType,
                hasPassword: state.hasPassword,
                isForPasswordSet: !isNewUserRegistration,
              );
            }
            return;
          }

          // If user has password and password login is enabled, don't send OTP
          if (isPasswordLoginEnabled && state.hasPassword == true) {
            // Password field will be shown via the listener above
            // Don't send OTP, user should login with password
            return;
          }

          if (state.authenticationType == "sms_gateway" || isEmailAuth) {
            UiUtils.showMessage(
              context,
              'otpSentSuccessfully'.translate(context: context),
              ToastificationType.success,
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!context.mounted) return;
              Navigator.pushNamed(
                context,
                otpVerificationRoute,
                arguments: {
                  'phoneNumberWithCountryCode': phoneNumberWithCountryCode,
                  'phoneNumberWithOutCountryCode': onlyPhoneNumber,
                  'countryCode': countryCode,
                  'email': state.email,
                  'source': widget.source,
                  "userAuthenticationCode": state.statusCode,
                  "authenticationType": state.authenticationType,
                  "hasPassword": state.hasPassword,
                },
              );
            });
          } else {
            context.read<SendVerificationCodeCubit>().sendVerificationCode(
              phoneNumber: phoneNumberWithCountryCode,
              userAuthenticationCode: state.statusCode,
              authenticationType: state.authenticationType,
              hasPassword: state.hasPassword,
            );
          }
        }
      }
    },
    builder: (context, checkIsUserExistsState) {
      final bool isCheckingUserExists =
          checkIsUserExistsState is CheckIsUserExistsInProgress;
      return BlocConsumer<SendVerificationCodeCubit, SendVerificationCodeState>(
        listener: (final BuildContext context, final verifyPhoneNumberState) =>
            _handleVerifyPhoneNumberListener(context, verifyPhoneNumberState),
        builder:
            (
              final BuildContext context,
              final SendVerificationCodeState verifyPhoneNumberState,
            ) {
              final bool isVerifyingPhoneNumber =
                  verifyPhoneNumberState is SendVerificationCodeInProgressState;

              return ListenableBuilder(
                listenable: Listenable.merge([
                  numberLength,
                  _passwordController,
                ]),
                builder: (context, _) {
                  final inputText = _numberFieldController.text.trim();
                  final bool isEmail = !RegExp(r'^[0-9]+$').hasMatch(inputText);

                  // Determine button state
                  bool isValidInput = false;

                  if (inputText.isEmpty) {
                    isValidInput = false;
                  } else if (isEmail) {
                    // Validate email
                    isValidInput = RegExp(
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
                    ).hasMatch(inputText);
                  } else {
                    // Validate phone number length
                    isValidInput =
                        numberLength.value >=
                            UiUtils.minimumMobileNumberDigit &&
                        numberLength.value <= UiUtils.maximumMobileNumberDigit;
                  }
                  final bool isPasswordEmpty = _passwordController.text
                      .trim()
                      .isEmpty;
                  final bool isFormIncomplete =
                      inputText.isEmpty ||
                      (showPasswordField && isPasswordEmpty);

                  return CustomRoundedButton(
                    buttonTitle: '',
                    showBorder: false,
                    widthPercentage: 1,
                    radius: 12,
                    backgroundColor: isFormIncomplete
                        ? context.colors.component.buttonSecondaryDisabled
                        : context.colors.backgroundBrand,
                    onTap: () {
                      if (verifyPhoneNumberState
                          is SendVerificationCodeInProgressState) {
                        return;
                      } else if (checkIsUserExistsState
                          is CheckIsUserExistsInProgress) {
                        return;
                      } else if (_isLoggingIn) {
                        return;
                      }
                      if (!isValidInput) {
                        verifyPhoneNumberFormKey.currentState?.validate();
                        return;
                      }
                      _onContinueButtonClicked();
                    },
                    child:
                        (isVerifyingPhoneNumber ||
                            isCheckingUserExists ||
                            _isLoggingIn)
                        ? CustomSizedBox(
                            height: 20,
                            width: 20,
                            child: CustomCircularProgressIndicator(
                              color: context.colors.textInverseLight,
                            ),
                          )
                        : CustomText(
                            (_isPasswordLoginEnabled && !showPasswordField)
                                ? 'continue'.translate(context: context)
                                : 'signIn'.translate(context: context),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isFormIncomplete
                                ? context.colors.textSecondary
                                : context.colors.textInverseLight,
                          ),
                  );
                },
              );
            },
      );
    },
  );

  void _handleVerifyPhoneNumberListener(
    BuildContext context,
    SendVerificationCodeState sendVerificationCodeState,
  ) {
    //same app-level cubit is shared with any stale instance of this screen
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

    if (sendVerificationCodeState is SendVerificationCodeSuccessState) {
      Navigator.pushNamed(
        context,
        otpVerificationRoute,
        arguments: {
          'phoneNumberWithCountryCode': phoneNumberWithCountryCode,
          'phoneNumberWithOutCountryCode': onlyPhoneNumber,
          'countryCode': countryCode,
          'source': widget.source,
          "userAuthenticationCode":
              sendVerificationCodeState.userAuthenticationCode,
          "authenticationType": sendVerificationCodeState.authenticationType,
          "hasPassword": sendVerificationCodeState.hasPassword,
          "isForPasswordSet": sendVerificationCodeState.isForPasswordSet,
        },
      );
    } else if (sendVerificationCodeState is SendVerificationCodeFailureState) {
      String errorMessage = '';

      errorMessage = sendVerificationCodeState.error.toString().translate(
        context: context,
      );
      UiUtils.showMessage(context, errorMessage, ToastificationType.error);
    }
  }
}
