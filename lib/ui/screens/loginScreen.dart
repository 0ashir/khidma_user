import 'package:e_demand/data/enums/userStatusEnum.dart';
import 'package:e_demand/ui/widgets/authenticationScreenBackground.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/generalImports.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({required this.source, final Key? key}) : super(key: key);
  final String source;

  @override
  State<LogInScreen> createState() => _LogInScreenState();

  static Route route(final RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (final _) => LogInScreen(
        source: arguments['source'],
      ),
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

  @override
  void dispose() {
    _numberFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (context.read<SystemSettingCubit>().isDemoModeEnabled) {
      _numberFieldController.text = "9876543210";
      numberLength.value = 10;
    }
  }

  void _onContinueButtonClicked() {
    UiUtils.removeFocus();
    if (numberLength.value < UiUtils.minimumMobileNumberDigit ||
        numberLength.value > UiUtils.maximumMobileNumberDigit) {
      return;
    }
    final bool isValidNumber =
        verifyPhoneNumberFormKey.currentState!.validate();

    if (isValidNumber) {
      final String countryCallingCode =
          context.read<CountryCodeCubit>().getSelectedCountryCode();

      phoneNumberWithCountryCode =
          countryCallingCode + _numberFieldController.text;
      onlyPhoneNumber = _numberFieldController.text;
      countryCode = countryCallingCode;

      context.read<CheckIsUserExistsCubit>().isUserExists(
            mobileNumber: onlyPhoneNumber,
            countryCode: countryCode,
            uid: '',
            loginType: LogInType.phone,
          );
    }
  }

  Widget _buildPhoneNumberFiled() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: MobileNumberFiled(
                controller: _numberFieldController,
                isReadOnly: false,
                onChanged: (number) {
                  numberLength.value = number.length;
                },
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            _buildSignInWithMobileButton(),
          ],
        ),
      );

  Widget _buildLoginOrSignupWidget() => CustomText(
        'loginOrSignup'.translate(context: context),
        color: Theme.of(context).colorScheme.blackColor,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        fontSize: 16,
        textAlign: TextAlign.center,
      );

  Widget _buildWelcomeHeadingWidget() => Column(
        children: [
          CustomText(
            'welcomeTo'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
            fontSize: 28,
            textAlign: TextAlign.center,
          ),
          CustomText(
            appName,
            color: Theme.of(context).colorScheme.accentColor,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
            fontSize: 28,
            textAlign: TextAlign.center,
          ),
        ],
      );

  @override
  Widget build(final BuildContext context) {

    final Size size = MediaQuery.sizeOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        body: SingleChildScrollView(
          child: CustomContainer(
            gradient: LinearGradient(
              colors: [
                context.colorScheme.secondaryColor,
                context.colorScheme.primaryColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            child: BlocListener<CheckIsUserExistsCubit, CheckIsUserExistsState>(
              listener: (final BuildContext context,
                      final CheckIsUserExistsState state) =>
                  _handleCheckIsUserExitListener(state),
              child: AuthenticationScreenBackground(
                child: Stack(
                  children: [
                    Form(
                      key: verifyPhoneNumberFormKey,
                      child: Padding(
                        padding: ResponsiveHelper.isLargeTablet(context) ||
                                ResponsiveHelper.isTablet(context)
                            ? const EdgeInsetsDirectional.symmetric(
                                horizontal: 150)
                            : const EdgeInsetsDirectional.symmetric(
                                horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: context.screenHeight * 0.17),
                            _buildLogoWidget(),
                            const SizedBox(height: 40),
                            SizedBox(
                                width: context.screenWidth * 0.7,
                                child: LinearDivider()),
                            const SizedBox(height: 24),
                            _buildWelcomeHeadingWidget(),
                            const SizedBox(
                              height: 24,
                            ),
                            _buildLoginOrSignupWidget(),
                            const SizedBox(
                              height: 24,
                            ),
                            _buildPhoneNumberFiled(),
                            const SizedBox(
                              height: 32,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: CustomContainer(
                                  height: 0.5,
                                  gradient: LinearGradient(
                                    colors: [
                                      context.colorScheme.secondaryColor,
                                      context.colorScheme.lightGreyColor
                                          .withAlpha(80),
                                      context.colorScheme.lightGreyColor,
                                    ],
                                  ),
                                )),
                                const SizedBox(width: 12),
                                CustomText(
                                  " ${"orContinueWith".translate(context: context)} ",
                                  fontWeight: FontWeight.w400,
                                  color: context.colorScheme.lightGreyColor,
                                  fontSize: 14,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: CustomContainer(
                                  height: 0.5,
                                  gradient: LinearGradient(
                                    colors: [
                                      context.colorScheme.lightGreyColor,
                                      context.colorScheme.lightGreyColor
                                          .withAlpha(80),
                                      context.colorScheme.secondaryColor,
                                    ],
                                  ),
                                )),
                              ],
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            if (Platform.isIOS) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: _buildSignInWithAppleButton(),
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                            ],
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildSignInWithGoogleButton(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.directional(
                        top: 55,
                        end: 15,
                        textDirection: Directionality.of(context),
                        child: BlocBuilder<VerifyOtpCubit, VerifyOtpState>(
                          builder:
                              (final context, final VerifyOtpState state) =>
                                  CustomInkWellContainer(
                            onTap: (state
                                    is SendVerificationCodeInProgressState)
                                ? () {
                                    UiUtils.showMessage(
                                      context,
                                      'verificationIsInProgress'
                                          .translate(context: context),
                                      ToastificationType.warning,
                                    );
                                  }
                                : () async {
                                    HiveRepository
                                        .setUserSkippedTheLoginBefore = true;
                                    if (widget.source == 'dialog') {
                                      Navigator.pop(context);
                                    } else if (Routes.previousRoute ==
                                            onBoardingRoute ||
                                        Routes.previousRoute == splashRoute) {
                                      await Navigator.pushReplacementNamed(
                                          context, navigationRoute);
                                    } else if (Routes.previousRoute ==
                                            navigationRoute ||
                                        Routes.previousRoute == loginRoute) {
                                      Navigator.pop(context);
                                    } else {
                                      await Navigator.pushReplacementNamed(
                                          context, navigationRoute);
                                    }
                                  },
                            child: CustomContainer(
                              border: Border.all(
                                  color: context.colorScheme.lightGreyColor,
                                  width: 0.5),
                              borderRadius: UiUtils.borderRadiusOf5,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              child: CustomText(
                                'skip'.translate(context: context),
                                color: Theme.of(context).colorScheme.blackColor,
                              ),
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: CustomContainer(
          padding: EdgeInsetsDirectional.only(
            bottom: 15.rh(context),
          ),
          width: size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText("by_continue_agree".translate(context: context),
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.lightGreyColor,
                  fontSize: 12),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomInkWellContainer(
                      onTap: () {
                        Navigator.of(context).pushNamed(appSettingsRoute,
                            arguments: 'termsofservice');
                      },
                      child: CustomText(
                        "terms_service".translate(context: context),
                        color: Theme.of(context).colorScheme.blackColor,
                        showUnderline: true,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                    CustomText(
                      " & ",
                      color: Theme.of(context).colorScheme.lightGreyColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    CustomInkWellContainer(
                      onTap: () {
                        Navigator.of(context).pushNamed(appSettingsRoute,
                            arguments: 'privacyAndPolicy');
                      },
                      child: CustomText(
                        "privacyAndPolicy".translate(context: context),
                        color: Theme.of(context).colorScheme.blackColor,
                        fontWeight: FontWeight.w400,
                        showUnderline: true,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInWithMobileButton() =>
      BlocConsumer<CheckIsUserExistsCubit, CheckIsUserExistsState>(
        listener: (final BuildContext context,
            final CheckIsUserExistsState state) async {
          if (state is CheckIsUserExistsSuccess) {
            if (state.loginType != LogInType.phone) {
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
              UiUtils.showMessage(
                context,
                'yourAccountIsDeActive'.translate(context: context),
                ToastificationType.warning,
              );
              Navigator.pop(context);
              return;
            } else {
              if (state.authenticationType == "sms_gateway") {
                UiUtils.showMessage(
                  context,
                  'otpSentSuccessfully'.translate(context: context),
                  ToastificationType.success,
                );
                Future.delayed(const Duration(milliseconds: 500), () {
                  Navigator.pushNamed(
                    context,
                    otpVerificationRoute,
                    arguments: {
                      'phoneNumberWithCountryCode': phoneNumberWithCountryCode,
                      'phoneNumberWithOutCountryCode': onlyPhoneNumber,
                      'countryCode': countryCode,
                      'source': widget.source,
                      "userAuthenticationCode": state.statusCode,
                      "authenticationType": state.authenticationType
                    },
                  );
                });
              } else {
                context.read<SendVerificationCodeCubit>().sendVerificationCode(
                    phoneNumber: phoneNumberWithCountryCode,
                    userAuthenticationCode: state.statusCode,
                    authenticationType: state.authenticationType);
              }
            }
          }
        },
        builder: (context, checkIsUserExistsState) {
          final bool isCheckingUserExists =
              checkIsUserExistsState is CheckIsUserExistsInProgress;
          return BlocConsumer<SendVerificationCodeCubit,
              SendVerificationCodeState>(
            listener:
                (final BuildContext context, final verifyPhoneNumberState) =>
                    _handleVerifyPhoneNumberListener(
                        context, verifyPhoneNumberState),
            builder: (final BuildContext context,
                final SendVerificationCodeState verifyPhoneNumberState) {
              final bool isVerifyingPhoneNumber =
                  verifyPhoneNumberState is SendVerificationCodeInProgressState;

              return ValueListenableBuilder(
                  valueListenable: numberLength,
                  builder: (context, numberLength, _) {
                    return SizedBox(
                      height: 48,
                      width: 48,
                      child: CustomRoundedButton(
                          buttonTitle: '',
                          showBorder: false,
                          widthPercentage: 1,
                          onTap: () {
                            if (verifyPhoneNumberState
                                is SendVerificationCodeInProgressState) {
                              return;
                            } else if (checkIsUserExistsState
                                is CheckIsUserExistsInProgress) {
                              return;
                            }
                            _onContinueButtonClicked();
                          },
                          backgroundColor: ((numberLength <
                                  UiUtils.minimumMobileNumberDigit)
                              ? context.colorScheme.lightGreyColor.withAlpha(30)
                              : (numberLength >
                                      UiUtils.maximumMobileNumberDigit)
                                  ? AppColors.redColor.withAlpha(30)
                                  : context.colorScheme.accentColor),
                          child: (isVerifyingPhoneNumber ||
                                  isCheckingUserExists)
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CustomCircularProgressIndicator(
                                    color: AppColors.whiteColors,
                                  ),
                                )
                              : CustomSvgPicture(
                                  svgImage: Directionality.of(context)
                                          .toString()
                                          .contains(TextDirection.RTL.value
                                              .toLowerCase())
                                      ? AppAssets.loginArrowLft
                                      : AppAssets.loginArrow,
                                  color: ((numberLength <
                                          UiUtils.minimumMobileNumberDigit)
                                      ? context.colorScheme.lightGreyColor
                                      : (numberLength >
                                              UiUtils.maximumMobileNumberDigit)
                                          ? AppColors.redColor
                                          : AppColors.whiteColors))),
                    );
                  });
            },
          );
        },
      );

  Widget _buildSignInWithGoogleButton() {
    return BlocBuilder<CheckIsUserExistsCubit, CheckIsUserExistsState>(
      builder: (context, verificationState) {
        final bool isVerificationLoading =
            verificationState is CheckIsUserExistsInProgress &&
                verificationState.loginType == LogInType.google;

        return BlocConsumer<GoogleLoginCubit, GoogleLoginState>(
          listener: (context, state) {
            if (state is GoogleLoginFailureState) {
              UiUtils.showMessage(
                  context, state.errorMessage, ToastificationType.error);
            } else if (state is GoogleLoginSuccessState) {
              if (state.userDetails == null) {
                UiUtils.showMessage(
                    context,
                    'loginProcessCanceled'
                        .translate(context: context)
                        .translate(context: context),
                    ToastificationType.warning);
                return;
              }
              context.read<CheckIsUserExistsCubit>().isUserExists(
                    uid: state.userDetails?.uid ?? '',
                    loginType: LogInType.google,
                    userName: state.userDetails?.displayName ?? '',
                    userEmail: state.userDetails?.email,
                  );
            }
          },
          builder: (context, state) {
            final bool isLoading = state is GoogleLoginInProgressState;

            return CustomRoundedButton(
              buttonTitle: '',
              showBorder: true,
              widthPercentage: 1,
              radius: UiUtils.borderRadiusOf10,
              borderColor: context.colorScheme.lightGreyColor,
              titleColor: Theme.of(context).colorScheme.blackColor,
              backgroundColor: context.watch<SendVerificationCodeCubit>().state
                          is SendVerificationCodeInProgressState ||
                      context.watch<CheckIsUserExistsCubit>().state
                          is CheckIsUserExistsInProgress
                  ? Theme.of(context).colorScheme.lightGreyColor.withAlpha(30)
                  : context.colorScheme.secondaryColor,
              child: isLoading || isVerificationLoading
                  ? const CustomCircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomSvgPicture(
                          svgImage: AppAssets.googleIcon,
                          height: 22,
                          width: 22,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        CustomText(
                          "signInWithGoogle".translate(context: context),
                        ),
                      ],
                    ),
              onTap: () {
                if (context.read<SendVerificationCodeCubit>().state
                    is SendVerificationCodeInProgressState) {
                  return;
                }
                //check that also is verification in process by other method
                if (isLoading ||
                    isVerificationLoading ||
                    verificationState is CheckIsUserExistsInProgress) {
                  return;
                }
                context.read<GoogleLoginCubit>().loginWithGoogle();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSignInWithAppleButton() {
    return BlocBuilder<CheckIsUserExistsCubit, CheckIsUserExistsState>(
      builder: (context, verificationState) {
        final bool isVerificationLoading =
            verificationState is CheckIsUserExistsInProgress &&
                verificationState.loginType == LogInType.apple;

        return BlocConsumer<AppleLoginCubit, AppleLoginState>(
          listener: (context, state) {
            if (state is AppleLoginFailureState) {
              UiUtils.showMessage(
                  context, state.errorMessage, ToastificationType.error);
            } else if (state is AppleLoginSuccessState) {
              if (state.userDetails == null) {
                UiUtils.showMessage(
                    context,
                    'loginProcessCanceled'.translate(context: context),
                    ToastificationType.warning);
                return;
              }
              context.read<CheckIsUserExistsCubit>().isUserExists(
                    uid: state.userDetails?.uid ?? '',
                    loginType: LogInType.google,
                    userName: state.userDetails?.displayName ?? '',
                    userEmail: state.userDetails?.email,
                  );
            }
          },
          builder: (context, state) {
            final bool isLoading = state is AppleLoginInProgressState;

            return CustomRoundedButton(
              buttonTitle: '',
              showBorder: true,
              borderColor: context.colorScheme.lightGreyColor,
              widthPercentage: 1,
              radius: UiUtils.borderRadiusOf10,
              titleColor: Theme.of(context).colorScheme.blackColor,
              backgroundColor: context.watch<SendVerificationCodeCubit>().state
                          is SendVerificationCodeInProgressState ||
                      context.watch<CheckIsUserExistsCubit>().state
                          is CheckIsUserExistsInProgress
                  ? Theme.of(context).colorScheme.lightGreyColor.withAlpha(30)
                  : context.colorScheme.secondaryColor,
              child: isLoading || isVerificationLoading
                  ? const CustomCircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomSvgPicture(
                          svgImage: AppAssets.appleIcon,
                          height: 24,
                          width: 24,
                          color: context.colorScheme.blackColor,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        CustomText(
                          "signInWithApple".translate(context: context),
                        ),
                      ],
                    ),
              onTap: () {
                if (context.read<SendVerificationCodeCubit>().state
                    is SendVerificationCodeInProgressState) {
                  return;
                }
                //check that also is verification in process by other method

                if (isLoading ||
                    isVerificationLoading ||
                    verificationState is CheckIsUserExistsInProgress) {
                  return;
                }
                context.read<AppleLoginCubit>().loginWithApple();
              },
            );
          },
        );
      },
    );
  }

  Future<void> _handleCheckIsUserExitListener(
      CheckIsUserExistsState state) async {
    if (state is CheckIsUserExistsFailure) {
      UiUtils.showMessage(
        context,
        state.errorMessage,
        ToastificationType.error,
      );
    } else if (state is CheckIsUserExistsSuccess) {
      if (state.loginType == LogInType.phone) {
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
          'unknownStatus',
          ToastificationType.error,
        );
        return;
      }

      if (userStatus == UserStatus.deactive) {
        UiUtils.showMessage(
          context,
          'yourAccountIsDeActive',
          ToastificationType.warning,
        );
        // Navigator.pop(context);
        return;
      } else if (userStatus == UserStatus.active) {
        final latitude = HiveRepository.getLatitude ?? "0.0";
        final longitude = HiveRepository.getLongitude ?? "0.0";
        //update fcm id
        String fcmId = '';
        try {
          fcmId = await FirebaseMessaging.instance.getToken() ?? '';
        } catch (_) {}

        await AuthenticationRepository.loginUser(
                uid: state.uid,
                latitude: latitude.toString(),
                longitude: longitude.toString(),
                loginType: state.loginType,
                fcmId: fcmId)
            .then(
          (final UserDetailsModel value) {
            HiveRepository.setUserFirstTimeInApp = false;
            HiveRepository.setUserLoggedIn = true;

            context.read<AuthenticationCubit>().checkStatus();

            UiUtils.showMessage(
                context,
                "userLoggedInSuccessfully".translate(context: context),
                ToastificationType.success);

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
              } catch (e, stack) {
                debugPrint('Error fetching initial data: $e\n$stack');
              }

              // Check if the widget is still mounted before navigating
              if (!mounted) return;

              if (widget.source == 'dialog') {
                Navigator.pop(context);
              } else {
                // Reset bottom navigation bar index
                UiUtils.bottomNavigationBarGlobalKey.currentState
                    ?.selectedIndexOfBottomNavigationBar.value = 0;

                // Navigate and remove all previous routes
                Navigator.of(context).pushNamedAndRemoveUntil(
                  navigationRoute,
                  (Route<dynamic> route) => false,
                );
              }
            });
          },
        );
      } else {
        await Navigator.pushNamed(
          context,
          editProfileRoute,
          arguments: {
            'source': widget.source,
            'uid': state.uid,
            "userEmail": state.userEmail,
            "userName": state.userName,
            "loginType": state.loginType,
            "isNewUser": true,
          },
        );
      }
    }
  }

  Widget _buildLogoWidget() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.15,
      child: CustomSvgPicture(
        svgImage: Theme.of(context).colorScheme.brightness == Brightness.light
            ? AppAssets.loginLogoLight
            : AppAssets.loginLogoDark,
      ),
    );
  }

  void _handleVerifyPhoneNumberListener(BuildContext context,
      SendVerificationCodeState sendVerificationCodeState) {
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
          "authenticationType": sendVerificationCodeState.authenticationType
        },
      );
    } else if (sendVerificationCodeState is SendVerificationCodeFailureState) {
      String errorMessage = '';

      errorMessage = sendVerificationCodeState.error
          .toString()
          .translate(context: context);
      UiUtils.showMessage(context, errorMessage, ToastificationType.error);
    }
  }
}
