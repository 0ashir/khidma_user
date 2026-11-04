import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/data/enums/userStatusEnum.dart';
import 'package:e_demand/utils/verifiedPhoneNumber.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // ignore_for_file: use_build_context_synchronously

import 'package:pinput/pinput.dart';

import "../../../utils/timer.dart";

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    required this.countryCode,
    required this.phoneNumberWithCountryCode,
    required this.phoneNumberWithOutCountryCode,
    required this.source,
    required this.userAuthenticationCode,
    required this.authenticationType,
    this.email,
    this.hasPassword = false,
    this.isForPasswordSet = false,
    this.autoSendOtp = false,
    final Key? key,
  }) : super(key: key);

  final String phoneNumberWithCountryCode;
  final String phoneNumberWithOutCountryCode;
  final String countryCode;
  final String source;
  final String userAuthenticationCode;
  final String authenticationType;
  final String? email;
  final bool hasPassword;
  final bool isForPasswordSet;
  final bool autoSendOtp;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();

  static Route route(final RouteSettings routeSettings) {
    final Map parameters = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final _) => OtpVerificationScreen(
        countryCode: parameters['countryCode'],
        phoneNumberWithOutCountryCode:
            parameters['phoneNumberWithOutCountryCode'],
        phoneNumberWithCountryCode: parameters["phoneNumberWithCountryCode"],
        source: parameters["source"],
        userAuthenticationCode: parameters["userAuthenticationCode"],
        authenticationType: parameters["authenticationType"],
        email: parameters["email"],
        hasPassword: parameters["hasPassword"] ?? false,
        isForPasswordSet: parameters["isForPasswordSet"] ?? false,
        autoSendOtp: parameters["autoSendOtp"] ?? false,
      ),
    );
  }
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  bool isCountdownFinished = false;
  bool isOtpSent = false;
  TextEditingController otpController = TextEditingController();
  bool shouldShowOtpResendSuccessMessage = false;
  FocusNode otpFiledFocusNode = FocusNode();
  CountDownTimer countDownTimer = CountDownTimer();

  ValueNotifier<bool> isCountDownCompleted = ValueNotifier(false);

  final ValueNotifier<String> _otpValue = ValueNotifier('');

  bool get _isEmail => widget.email != null && widget.email!.isNotEmpty;

  @override
  void dispose() {
    otpFiledFocusNode.dispose();
    otpController.dispose();
    _otpValue.dispose();

    countDownTimer.timerController.close();
    isCountDownCompleted.dispose();
    super.dispose();
  }

  @override
  void initState() {
    countDownTimer.start(_onCountdownComplete);

    if (widget.autoSendOtp) {
      Future.delayed(Duration.zero, () {
        final bool isEmail = widget.email != null && widget.email!.isNotEmpty;
        context.read<ResendOtpCubit>().resendOtp(
          phoneNumber: isEmail ? null : widget.phoneNumberWithOutCountryCode,
          email: isEmail ? widget.email : null,
          authenticationType: widget.authenticationType,
          countryCode: isEmail ? null : widget.countryCode,
          onOtpSent: () {},
        );
      });
    }

    if (widget.phoneNumberWithOutCountryCode == "9876543210") {
      otpController.text = '123456';

      Future.delayed(Duration.zero, () {
        final bool isEmail = widget.email != null && widget.email!.isNotEmpty;
        context.read<VerifyOtpCubit>().verifyOtp(
          otp: "123456",
          authenticationType: widget.authenticationType,
          countryCode: isEmail ? null : widget.countryCode,
          mobileNumber: isEmail ? null : widget.phoneNumberWithOutCountryCode,
          email: isEmail ? widget.email : null,
          passwordUpdate: widget.isForPasswordSet,
          loginType: isEmail ? LogInType.email : LogInType.phone,
        );
      });
    }
    super.initState();
  }

  void _onCountdownComplete() {
    isCountDownCompleted.value = true;
  }

  void _onResendOtpClick() {
    if (isCountDownCompleted.value) {
      final bool isEmail = widget.email != null && widget.email!.isNotEmpty;

      context.read<ResendOtpCubit>().resendOtp(
        phoneNumber: isEmail ? null : widget.phoneNumberWithOutCountryCode,
        email: isEmail ? widget.email : null,
        authenticationType: widget.authenticationType,
        countryCode: isEmail ? null : widget.countryCode,
        onOtpSent: () {
          otpController.clear();
          _otpValue.value = '';
          isCountdownFinished = false;
          SchedulerBinding.instance.addPostFrameCallback((final _) {
            if (mounted) setState(() {});
          });
        },
      );
    }
  }

  Widget _buildHeader() => CustomText(
    (_isEmail ? 'verifyYourEmail' : 'verifyYourPhoneNumber').translate(
      context: context,
    ),
    fontSize: 24,
    color: context.colors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  Widget _buildSubHeading() => CustomText(
    "${'weJustSentYouCodeIn'.translate(context: context)} ${(_isEmail ? 'email' : 'phone').translate(context: context)}",
    color: context.colors.textSecondary,
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  Widget _buildResendButton(
    final BuildContext context,
    final resendOtpState,
  ) => Row(
    children: [
      Expanded(
        child: CustomContainer(height: 1, color: context.colors.borderDefault),
      ),
      const CustomSizedBox(width: 12),
      if (resendOtpState is ResendOtpInProcess) ...[] else ...[],
      BlocConsumer<VerifyOtpCubit, VerifyOtpState>(
        listener: (final context, verifyOtpState) =>
            _handleVerifyOtpListener(context, verifyOtpState),
        builder: (final context, final verifyOtpState) =>
            ValueListenableBuilder(
              valueListenable: isCountDownCompleted,
              builder: (final context, final value, final child) {
                if (verifyOtpState is VerifyOtpInProcess) {
                  return CustomText(
                    'otpVerifying'.translate(context: context),
                    color: context.colors.textTertiary,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  );
                }
                if (resendOtpState is ResendOtpInProcess) {
                  return CustomText(
                    'sending_otp'.translate(context: context),
                    color: context.colors.textTertiary,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  );
                }
                return isCountDownCompleted.value
                    ? CustomInkWellContainer(
                        onTap: _onResendOtpClick,
                        showRippleEffect: false,
                        child: CustomText(
                          'resend_otp'.translate(context: context),
                          color: context.colors.textBrand,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          showUnderline: true,
                          underlineOrLineColor: context.colors.textBrand,
                        ),
                      )
                    : _resendCountDownButton();
              },
            ),
      ),
      const CustomSizedBox(width: 12),
      Expanded(
        child: CustomContainer(height: 1, color: context.colors.borderDefault),
      ),
    ],
  );

  Widget _resendCountDownButton() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CustomText(
        'resend_otp_in'.translate(context: context),
        color: context.colors.textTertiary,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      const CustomSizedBox(width: 5),
      countDownTimer.listenText(color: context.colors.textBrand),
    ],
  );

  Widget _buildOtpField(final BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 15),
    child: CustomSizedBox(
      width: context.screenWidth,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Pinput(
          controller: otpController,
          keyboardType: TextInputType.number,
          closeKeyboardWhenCompleted: true,
          focusNode: otpFiledFocusNode,
          autofocus: true,
          pinAnimationType: PinAnimationType.scale,
          separatorBuilder: (final index) => const CustomSizedBox(width: 14),
          focusedPinTheme: PinTheme(
            width: 48,
            height: 48,
            textStyle: TextStyle(
              fontSize: 14,
              color: context.colors.textPrimary,
            ),
            decoration: BoxDecoration(
              color: context.colors.backgroundBrandSubtle,
              border: Border.all(color: context.colors.borderBrand),
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
            ),
          ),
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          isCursorAnimationEnabled: true,
          defaultPinTheme: PinTheme(
            width: 48,
            height: 48,
            textStyle: TextStyle(
              fontSize: 14,
              color: context.colors.textPrimary,
            ),
            decoration: BoxDecoration(
              color: context.colors.backgroundPrimary,
              border: Border.all(color: context.colors.borderDefault),
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
            ),
          ),
          readOnly:
              context.watch<VerifyOtpCubit>().state is VerifyOtpInProcess ||
              context.watch<CheckIsUserExistsCubit>().state
                  is CheckIsUserExistsInProgress,
          onChanged: (final value) => _otpValue.value = value,
          onCompleted: _submitOtp,
          length: 6,
        ),
      ),
    ),
  );

  void _submitOtp(final String otpValue) {
    if (otpValue.length != 6) return;
    if (context.read<VerifyOtpCubit>().state is VerifyOtpInProcess) return;
    UiUtils.removeFocus();

    context.read<VerifyOtpCubit>().verifyOtp(
      otp: otpValue,
      authenticationType: widget.authenticationType,
      countryCode: _isEmail ? null : widget.countryCode,
      mobileNumber: _isEmail ? null : widget.phoneNumberWithOutCountryCode,
      email: _isEmail ? widget.email : null,
      passwordUpdate: widget.isForPasswordSet,
      loginType: _isEmail ? LogInType.email : LogInType.phone,
    );
  }

  Widget _buildContinueButton() => BlocBuilder<VerifyOtpCubit, VerifyOtpState>(
    builder: (final context, final verifyOtpState) {
      final bool isVerifying = verifyOtpState is VerifyOtpInProcess;

      return ValueListenableBuilder<String>(
        valueListenable: _otpValue,
        builder: (context, otpValue, _) => CustomRoundedButton(
          buttonTitle: '',
          showBorder: false,
          widthPercentage: 1,
          height: 48,
          radius: 16,
          backgroundColor: context.colors.backgroundBrand,
          onTap: isVerifying ? null : () => _submitOtp(otpValue),
          child: isVerifying
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
                  color: context.colors.textInverseLight,
                ),
        ),
      );
    },
  );

  @override
  Widget build(final BuildContext context) => AnnotatedSafeArea(
    isAnnotated: true,
    applyBottomInset: false,
    child: Scaffold(
      backgroundColor: context.colors.backgroundSecondary,
      appBar: const AuthAppBar(),
      body: BlocListener<SendVerificationCodeCubit, SendVerificationCodeState>(
        listener:
            (
              final BuildContext context,
              final SendVerificationCodeState verifyPhoneNumberstate,
            ) async {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: BlocConsumer<ResendOtpCubit, ResendOtpState>(
            listener: (final BuildContext c, final ResendOtpState state) {
              if (state is ResendOtpSuccess) {
                isCountDownCompleted.value = false;

                countDownTimer.start(_onCountdownComplete);

                context.read<ResendOtpCubit>().setDefaultOtpState();
                UiUtils.showMessage(
                  context,
                  'otp_sent'.translate(context: context),
                  ToastificationType.success,
                );
              } else if (state is ResendOtpFail) {
                UiUtils.showMessage(
                  context,
                  state.error,
                  ToastificationType.error,
                );
              }
            },
            builder: (final context, final ResendOtpState resendOtpState) =>
                CustomSizedBox(
                  width: context.screenWidth,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const CustomSizedBox(height: 8),
                        _buildSubHeading(),
                        const CustomSizedBox(height: 4),
                        _buildMobileNumberWidget(),
                        const CustomSizedBox(height: 24),
                        _buildOtpField(context),
                        const CustomSizedBox(height: 18),
                        _buildContinueButton(),
                        const CustomSizedBox(height: 18),
                        _buildResendButton(context, resendOtpState),
                      ],
                    ),
                  ),
                ),
          ),
        ),
      ),
      bottomNavigationBar: _buildTermsFooter(),
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

  Widget _buildMobileNumberWidget() {
    final String displayText = _isEmail
        ? widget.email!
        : widget.phoneNumberWithCountryCode;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: CustomText(
            displayText,
            color: context.colors.textBrand,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const CustomSizedBox(width: 5),
        CustomInkWellContainer(
          onTap: () {
            Navigator.pop(context);
          },
          child: CustomSvgPicture(
            svgImage: AppAssets.edit,
            color: context.colors.iconBrand,
          ),
        ),
      ],
    );
  }

  Future<void> _handleVerifyOtpListener(
    BuildContext context,
    VerifyOtpState verifyOtpState,
  ) async {
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

    if (verifyOtpState is VerifyOtpSuccess) {
      countDownTimer.close();
      final userStatus = UserStatus.fromCode(widget.userAuthenticationCode);

      if (userStatus == null) {
        UiUtils.showMessage(
          context,
          'unknownStatus'.translate(context: context),
          ToastificationType.error,
        );
        return;
      }

      if (userStatus == UserStatus.deactive) {
        UiUtils.showMessage(
          context,
          'yourAccountIsDeActive'.translate(context: context),
          ToastificationType.warning,
        );
        return;
      }

      var verifiedMobileNumber = widget.phoneNumberWithOutCountryCode;
      var verifiedCountryCode = widget.countryCode;
      var verifiedInternationalNumber = widget.phoneNumberWithCountryCode;
      if (!_isEmail && widget.authenticationType != 'sms_gateway') {
        try {
          // Firebase may normalize the typed number (for example a trunk zero).
          // Carry the successful OTP credential's identity into every next step.
          final phone = VerifiedPhoneNumber.fromFirebase(
            phoneNumber: verifyOtpState.signinCredential?.user?.phoneNumber,
            countryCode: widget.countryCode,
          );
          verifiedMobileNumber = phone.nationalNumber;
          verifiedCountryCode = phone.countryCode;
          verifiedInternationalNumber = phone.internationalNumber;
        } on FormatException {
          UiUtils.showMessage(
            context,
            'somethingWentWrong'.translate(context: context),
            ToastificationType.error,
          );
          return;
        }
      }

      UiUtils.showMessage(
        context,
        'otpVerifiedSuccessfully'.translate(context: context),
        ToastificationType.success,
      );

      final bool isPasswordLoginEnabled =
          (context.read<SystemSettingCubit>().state
              is SystemSettingFetchSuccess) &&
          (context.read<SystemSettingCubit>().state
                      as SystemSettingFetchSuccess)
                  .systemSettingDetails
                  .loginSettings
                  ?.isPasswordLoginEnabled ==
              true;

      if (widget.isForPasswordSet && isPasswordLoginEnabled) {
        final bool isEmail = widget.email != null && widget.email!.isNotEmpty;
        final bool isFirstTimeSet = !widget.hasPassword;

        await Navigator.pushReplacementNamed(
          context,
          setPasswordRoute,
          arguments: {
            'source': widget.source,
            'resetToken': verifyOtpState.resetToken,
            'email': isEmail ? widget.email : null,
            'phoneNumber': isEmail ? null : verifiedMobileNumber,
            'countryCode': isEmail ? null : verifiedCountryCode,
            'isFirstTimePasswordSet': isFirstTimeSet,
            'authenticationType': widget.authenticationType,
          },
        );
        return;
      }

      if (userStatus == UserStatus.active) {
        final bool isPasswordLoginEnabled =
            (context.read<SystemSettingCubit>().state
                is SystemSettingFetchSuccess) &&
            (context.read<SystemSettingCubit>().state
                        as SystemSettingFetchSuccess)
                    .systemSettingDetails
                    .loginSettings
                    ?.isPasswordLoginEnabled ==
                true;

        if (isPasswordLoginEnabled && !widget.hasPassword) {
          // User exists but password not set - redirect to set password
          final bool isEmail = widget.email != null && widget.email!.isNotEmpty;

          // We need to get reset token, so redirect to send OTP for password set
          await Navigator.pushReplacementNamed(
            context,
            loginRoute,
            arguments: {
              'source': widget.source,
              'prefillValue': isEmail
                  ? widget.email
                  : verifiedInternationalNumber,
              'needsPasswordSet': true,
            },
          );
          return;
        }

        //update fcm id
        String fcmId = '';
        try {
          fcmId = await FirebaseMessaging.instance.getToken() ?? '';
        } catch (_) {}

        final latitude = HiveRepository.getLatitude ?? "0.0";
        final longitude = HiveRepository.getLongitude ?? "0.0";

        await AuthenticationRepository.loginUser(
          fcmId: fcmId,
          uid: '',
          latitude: latitude.toString(),
          longitude: longitude.toString(),
          loginType: _isEmail ? LogInType.email : LogInType.phone,
          email: _isEmail ? widget.email : null,
          countryCode: _isEmail ? null : verifiedCountryCode,
          mobileNumber: _isEmail ? null : verifiedMobileNumber,
        ).then((final UserDetailsModel value) {
          HiveRepository.setUserFirstTimeInApp = false;
          HiveRepository.setUserLoggedIn = true;

          context.read<AuthenticationCubit>().checkStatus();

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              await context.read<SystemSettingCubit>().getSystemSettings();
              // List of all async calls
              final futures = <Future>[
                context.read<BookingCubit>().fetchAllBookings(status: ''),
                context.read<HomeScreenCubit>().fetchHomeScreenData(),
                context.read<CartCubit>().getCartDetails(isReorderCart: false),
                context.read<BookmarkCubit>().fetchBookmark(type: "list"),
                context.read<MyRequestListCubit>().fetchRequests(),
                context.read<UserDetailsCubit>().loadUserDetails(),
                context.read<EnquiryChatUserCubit>().fetchChatUsers(),
                context.read<BookingChatUserCubit>().fetchChatUsers(),
              ];

              Future.wait(futures);
            } catch (_) {}
            if (widget.source == 'dialog') {
              Navigator.pop(context);
              Navigator.pop(context);
            } else {
              UiUtils
                      .bottomNavigationBarGlobalKey
                      .currentState
                      ?.selectedIndexOfBottomNavigationBar
                      .value =
                  0;
              Navigator.of(context).pushNamedAndRemoveUntil(
                navigationRoute,
                (Route<dynamic> route) => false,
              );
            }
          });
        });
      } else if (userStatus == UserStatus.notRegistered) {
        // Check if it's email or phone registration
        final bool isEmail = widget.email != null && widget.email!.isNotEmpty;

        await Navigator.pushReplacementNamed(
          context,
          editProfileRoute,
          arguments: {
            'phoneNumberWithCountryCode': verifiedInternationalNumber,
            'phoneNumberWithOutCountryCode': verifiedMobileNumber,
            'countryCode': verifiedCountryCode,
            'source': widget.source,
            'uid': '',
            "isNewUser": true,
            "loginType": isEmail ? LogInType.email : LogInType.phone,
            "userEmail": isEmail ? widget.email : '',
            "userName": '',
          },
        );
      }
    } else if (verifyOtpState is VerifyOtpFail) {
      Future.delayed(const Duration(seconds: 1), () {
        context.read<VerifyOtpCubit>().setInitialState();
      });

      UiUtils.showMessage(
        context,
        verifyOtpState.error.toString(),
        ToastificationType.error,
      );

      Future.delayed(Duration.zero, () {
        otpController.clear();
        _otpValue.value = '';
      });
    }
  }
}
