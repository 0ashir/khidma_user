import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/data/enums/userStatusEnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // ignore_for_file: use_build_context_synchronously

import 'package:pinput/pinput.dart';

import "../../utils/timer.dart";

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    required this.countryCode,
    required this.phoneNumberWithCountryCode,
    required this.phoneNumberWithOutCountryCode,
    required this.source,
    required this.userAuthenticationCode,
    required this.authenticationType,
    final Key? key,
  }) : super(key: key);

  final String phoneNumberWithCountryCode;
  final String phoneNumberWithOutCountryCode;
  final String countryCode;
  final String source;
  final String userAuthenticationCode;
  final String authenticationType;

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

  @override
  void dispose() {
    otpFiledFocusNode.dispose();
    otpController.dispose();

    countDownTimer.timerController.close();
    isCountDownCompleted.dispose();
    super.dispose();
  }

  @override
  void initState() {
    countDownTimer.start(_onCountdownComplete);
    if (widget.phoneNumberWithOutCountryCode == "9876543210") {
      otpController.text = '123456';

      Future.delayed(
        Duration.zero,
        () {
          context.read<VerifyOtpCubit>().verifyOtp(
                otp: "123456",
                authenticationType: widget.authenticationType,
                countryCode: widget.countryCode,
                mobileNumber: widget.phoneNumberWithOutCountryCode,
              );
        },
      );
    }
    super.initState();
  }

  void _onCountdownComplete() {
    isCountDownCompleted.value = true;
  }

  void _onResendOtpClick() {
    if (isCountDownCompleted.value) {
      context.read<ResendOtpCubit>().resendOtp(
            phoneNumber: widget.phoneNumberWithOutCountryCode,
            authenticationType: widget.authenticationType,
            countryCode: widget.countryCode,
            onOtpSent: () {
              otpController.clear();
              isCountdownFinished = false;
              SchedulerBinding.instance.addPostFrameCallback((final _) {
                if (mounted) setState(() {});
              });
            },
          );
    }
  }

  Widget _buildHeader() => CustomText(
        'otp_verification'.translate(context: context),
        fontSize: 24,
        color: Theme.of(context).colorScheme.blackColor,
        fontWeight: FontWeight.w600,
      );

  Widget _buildSubHeading() => CustomText(
        'enter_verification_code'.translate(context: context),
        color: Theme.of(context).colorScheme.blackColor,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
        fontSize: 14,
        textAlign: TextAlign.center,
      );

  Widget _buildResendButton(final BuildContext context, final resendOtpState) =>
      Row(
        children: [
          Expanded(
              child: CustomContainer(
            height: 0.5,
            gradient: LinearGradient(
              colors: [
                context.colorScheme.secondaryColor,
                context.colorScheme.lightGreyColor.withAlpha(80),
                context.colorScheme.lightGreyColor,
              ],
            ),
          )),
          const SizedBox(width: 12),
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
                    color: Theme.of(context).colorScheme.lightGreyColor,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    textAlign: TextAlign.center,
                  );
                }
                if (resendOtpState is ResendOtpInProcess) {
                  return CustomText(
                    'sending_otp'.translate(context: context),
                    color: Theme.of(context).colorScheme.lightGreyColor,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    textAlign: TextAlign.center,
                  );
                }
                return isCountDownCompleted.value
                    ? CustomInkWellContainer(
                        onTap: _onResendOtpClick,
                        showRippleEffect: false,
                        child: CustomText(
                          'resend_otp'.translate(context: context),
                          color: Theme.of(context).colorScheme.accentColor,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          showUnderline: true,
                          textAlign: TextAlign.center,
                          underlineOrLineColor:
                              Theme.of(context).colorScheme.accentColor,
                        ),
                      )
                    : _resendCountDownButton();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: CustomContainer(
            height: 0.5,
            gradient: LinearGradient(
              colors: [
                context.colorScheme.lightGreyColor,
                context.colorScheme.lightGreyColor.withAlpha(80),
                context.colorScheme.secondaryColor,
              ],
            ),
          )),
        ],
      );

  Widget _resendCountDownButton() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            'resend_otp_in'.translate(context: context),
            color: Theme.of(context).colorScheme.lightGreyColor,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 14,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            width: 5,
          ),
          countDownTimer.listenText(
              color: Theme.of(context).colorScheme.accentColor)
        ],
      );

  Widget _buildOtpField(final BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Pinput(
              controller: otpController,
              keyboardType: TextInputType.number,
              closeKeyboardWhenCompleted: true,
              focusNode: otpFiledFocusNode,
              autofocus: true,
              pinAnimationType: PinAnimationType.scale,
              focusedPinTheme: PinTheme(
                height: 50,
                textStyle: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.blackColor),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.accentColor),
                    borderRadius:
                        BorderRadius.circular(UiUtils.borderRadiusOf5)),
              ),
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              isCursorAnimationEnabled: true,
              defaultPinTheme: PinTheme(
                height: 50,
                textStyle: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.blackColor),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.lightGreyColor),
                    borderRadius:
                        BorderRadius.circular(UiUtils.borderRadiusOf5)),
              ),
              readOnly:
                  context.watch<VerifyOtpCubit>().state is VerifyOtpInProcess ||
                      context.watch<CheckIsUserExistsCubit>().state
                          is CheckIsUserExistsInProgress,
              onCompleted: (final otpValue) {
                if (otpValue.length == 6) {
                  UiUtils.removeFocus();

                  context.read<VerifyOtpCubit>().verifyOtp(
                      otp: otpValue,
                      authenticationType: widget.authenticationType,
                      countryCode: widget.countryCode,
                      mobileNumber: widget.phoneNumberWithOutCountryCode);
                }
              },
              length: 6,
            ),
          ),
        ),
      );

  Widget _buildLogoWidget() {
    return CustomSvgPicture(
        svgImage: Theme.of(context).colorScheme.brightness == Brightness.light
            ? AppAssets.loginLogoLight
            : AppAssets.loginLogoDark,
        height: MediaQuery.of(context).size.height * 0.15);
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: '',
          backgroundColor: Theme.of(context).colorScheme.primaryColor,
        ),
        body:
            BlocListener<SendVerificationCodeCubit, SendVerificationCodeState>(
          listener: (final BuildContext context,
              final SendVerificationCodeState verifyPhoneNumberstate) async {},
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 30, 15, 15),
            child: BlocConsumer<ResendOtpCubit, ResendOtpState>(
              listener: (final BuildContext c, final ResendOtpState state) {
                if (state is ResendOtpSuccess) {
                  isCountDownCompleted.value = false;

                  countDownTimer.start(_onCountdownComplete);

                  context.read<ResendOtpCubit>().setDefaultOtpState();
                  UiUtils.showMessage(
                      context,
                      'otp_sent'.translate(context: context),
                      ToastificationType.success);
                } else if (state is ResendOtpFail) {
                  UiUtils.showMessage(
                      context, state.error, ToastificationType.error);
                }
              },
              builder: (final context, final ResendOtpState resendOtpState) =>
                  SizedBox(
                width: context.screenWidth,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildLogoWidget(),
                      const SizedBox(height: 24),
                      LinearDivider(),
                      const SizedBox(height: 24),
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildSubHeading(),
                      const SizedBox(height: 12),
                      _buildMobileNumberWidget(),
                      const SizedBox(height: 28),
                      _buildOtpField(context),
                      const SizedBox(height: 18),
                      _buildResendButton(context, resendOtpState),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildMobileNumberWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: CustomText(
            widget.phoneNumberWithCountryCode,
            color: Theme.of(context).colorScheme.accentColor,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 5),
        CustomInkWellContainer(
          onTap: () {
            Navigator.pop(context);
          },
          child: CustomSvgPicture(
            svgImage: AppAssets.edit,
            color: Theme.of(context).colorScheme.accentColor,
          ),
        ),
      ],
    );
  }

  Future<void> _handleVerifyOtpListener(
      BuildContext context, VerifyOtpState verifyOtpState) async {
    if (verifyOtpState is VerifyOtpSuccess) {
      countDownTimer.close();
      UiUtils.showMessage(
        context,
        'otpVerifiedSuccessfully'.translate(context: context),
        ToastificationType.success,
      );

      final userStatus = UserStatus.fromCode(widget.userAuthenticationCode);

      if (userStatus == null) {
        UiUtils.showMessage(
          context,
          'unknownStatus'.translate(context: context),
          ToastificationType.error,
        );
        return;
      }

      if (userStatus == UserStatus.active) {
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
                loginType: LogInType.phone,
                countryCode: widget.countryCode,
                mobileNumber: widget.phoneNumberWithOutCountryCode)
            .then(
          (final UserDetailsModel value) {
            HiveRepository.setUserFirstTimeInApp = false;
            HiveRepository.setUserLoggedIn = true;

            context.read<AuthenticationCubit>().checkStatus();

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {

                await context.read<SystemSettingCubit>().getSystemSettings();
                // List of all async calls
                final futures = <Future>[

                  context.read<BookingCubit>().fetchBookingDetails(status: ''),
                  context.read<HomeScreenCubit>().fetchHomeScreenData(),
                  context
                      .read<CartCubit>()
                      .getCartDetails(isReorderCart: false),
                  context.read<BookmarkCubit>().fetchBookmark(type: "list"),
                  context.read<MyRequestListCubit>().fetchRequests(),
                  context.read<UserDetailsCubit>().loadUserDetails(),
                ];

                // Wait for all calls to complete
                await Future.wait(futures);
              } catch (_) {}
              if (widget.source == 'dialog') {
                Navigator.pop(context);
                Navigator.pop(context);
              } else {
                UiUtils.bottomNavigationBarGlobalKey.currentState
                    ?.selectedIndexOfBottomNavigationBar.value = 0;
                Navigator.of(context).pushNamedAndRemoveUntil(
                    navigationRoute, (Route<dynamic> route) => false);
              }
            });
          },
        );
      } else {
        await Navigator.pushReplacementNamed(
          context,
          editProfileRoute,
          arguments: {
            'phoneNumberWithCountryCode': widget.phoneNumberWithCountryCode,
            'phoneNumberWithOutCountryCode':
                widget.phoneNumberWithOutCountryCode,
            'countryCode': widget.countryCode,
            'source': widget.source,
            'uid': '',
            "isNewUser": true,
            "loginType": LogInType.phone,
          },
        );
      }
    } else if (verifyOtpState is VerifyOtpFail) {
      Future.delayed(const Duration(seconds: 1), () {
        context.read<VerifyOtpCubit>().setInitialState();
      });

      UiUtils.showMessage(
          context, verifyOtpState.error, ToastificationType.error);

      Future.delayed(Duration.zero, () {
        otpController.clear();
      });
    }
  }
}
