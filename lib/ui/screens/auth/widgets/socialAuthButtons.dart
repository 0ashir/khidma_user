import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/data/enums/userStatusEnum.dart';
import 'package:flutter/material.dart';

class OrContinueWithDivider extends StatelessWidget {
  const OrContinueWithDivider({super.key});

  @override
  Widget build(final BuildContext context) => Row(
    children: [
      Expanded(
        child: CustomDivider(
          color: context.colors.borderDefault,
          thickness: 1,
          height: 1,
        ),
      ),
      const CustomSizedBox(width: 24),
      CustomText(
        'orContinueWith'.translate(context: context),
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: context.colors.textTertiary,
      ),
      const CustomSizedBox(width: 24),
      Expanded(
        child: CustomDivider(
          color: context.colors.borderDefault,
          thickness: 1,
          height: 1,
        ),
      ),
    ],
  );
}

class SocialAuthButtons extends StatefulWidget {
  const SocialAuthButtons({
    required this.source,
    this.onAccountDeactivated,
    this.isSignUp = false,
    super.key,
  });
  final String source;

  /// Sign-up flow words the buttons "Continue with …" instead of "Sign in with …".
  final bool isSignUp;

  /// Called instead of the default toast when the identity resolves to a
  /// deactivated account, so the host screen can show the same inline banner
  /// the credential-field flow uses.
  final VoidCallback? onAccountDeactivated;

  @override
  State<SocialAuthButtons> createState() => _SocialAuthButtonsState();
}

class _SocialAuthButtonsState extends State<SocialAuthButtons> {
  @override
  Widget build(final BuildContext context) =>
      BlocListener<CheckIsUserExistsCubit, CheckIsUserExistsState>(
        listener: (final context, final state) =>
            _handleCheckIsUserExistsState(state),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSignInWithGoogleButton(),
            if (Platform.isIOS) ...[
              const CustomSizedBox(height: 8),
              _buildSignInWithAppleButton(),
            ],
          ],
        ),
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
                context,
                state.errorMessage,
                ToastificationType.error,
              );
            } else if (state is GoogleLoginSuccessState) {
              if (state.userDetails == null) {
                UiUtils.showMessage(
                  context,
                  'loginProcessCanceled'
                      .translate(context: context)
                      .translate(context: context),
                  ToastificationType.warning,
                );
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

            return SocialSignInButton(
              icon: const CustomSvgPicture(
                avoideResponsive: true,
                svgImage: AppAssets.googleIcon,
                height: 24,
                width: 24,
              ),
              label: widget.isSignUp
                  ? 'continueWithGoogle'
                  : 'signInWithGoogle',
              isLoading: isLoading || isVerificationLoading,
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
                context,
                state.errorMessage,
                ToastificationType.error,
              );
            } else if (state is AppleLoginSuccessState) {
              if (state.userDetails == null) {
                UiUtils.showMessage(
                  context,
                  'loginProcessCanceled'.translate(context: context),
                  ToastificationType.warning,
                );
                return;
              }
              context.read<CheckIsUserExistsCubit>().isUserExists(
                uid: state.userDetails?.uid ?? '',
                loginType: LogInType.apple,
                userName: state.userDetails?.displayName ?? '',
                userEmail: state.userDetails?.email,
              );
            }
          },
          builder: (context, state) {
            final bool isLoading = state is AppleLoginInProgressState;

            return SocialSignInButton(
              icon: CustomSvgPicture(
                svgImage: AppAssets.appleIcon,
                avoideResponsive: true,
                height: 24,
                width: 24,
                color: context.colors.iconPrimary,
              ),
              label: widget.isSignUp ? 'continueWithApple' : 'signInWithApple',
              isLoading: isLoading || isVerificationLoading,
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

  Future<void> _handleCheckIsUserExistsState(
    CheckIsUserExistsState state,
  ) async {
    if (state is CheckIsUserExistsFailure) {
      UiUtils.showMessage(
        context,
        state.errorMessage,
        ToastificationType.error,
      );
    } else if (state is CheckIsUserExistsSuccess) {
      // Phone and email are handled by the screen's own credential-field flow.
      // This only ever fires for Google/Apple.
      if (state.loginType == LogInType.phone ||
          state.loginType == LogInType.email) {
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
        UiUtils.showMessage(context, 'unknownStatus', ToastificationType.error);
        return;
      }

      if (userStatus == UserStatus.deactive) {
        if (widget.onAccountDeactivated != null) {
          widget.onAccountDeactivated!();
        } else {
          UiUtils.showMessage(
            context,
            'yourAccountIsDeActive'.translate(context: context),
            ToastificationType.warning,
          );
        }
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
          fcmId: fcmId,
        ).then((final UserDetailsModel value) {
          HiveRepository.setUserFirstTimeInApp = false;
          HiveRepository.setUserLoggedIn = true;

          if (!mounted) return;
          context.read<AuthenticationCubit>().checkStatus();

          UiUtils.showMessage(
            context,
            "userLoggedInSuccessfully".translate(context: context),
            ToastificationType.success,
          );

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              await context.read<SystemSettingCubit>().getSystemSettings();
              if (!mounted) return;
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

              // Wait for all calls to complete
              Future.wait(futures);
            } catch (e, stack) {
              debugPrint('Error fetching initial data: $e\n$stack');
            }

            // Check if the widget is still mounted before navigating
            if (!mounted) return;

            // Check if password login is enabled
            final bool isPasswordLoginEnabled =
                context
                    .read<SystemSettingCubit>()
                    .loginSettings
                    ?.isPasswordLoginEnabled ??
                false;

            // Check if user has password - if not, redirect to edit profile to
            // set password. Only for phone/email login, never social.
            if (isPasswordLoginEnabled &&
                value.hasPassword == false &&
                state.loginType != LogInType.apple &&
                state.loginType != LogInType.google) {
              Navigator.pushNamed(
                context,
                editProfileRoute,
                arguments: {
                  'source': widget.source,
                  'uid': value.id ?? '',
                  "userEmail": value.email,
                  "userName": value.username,
                  "loginType": state.loginType,
                  "isNewUser": false,
                  "hasPassword": false,
                  "phoneNumberWithOutCountryCode": value.phone,
                  "countryCode": value.countryCode,
                  "userAuthenticationCode": "101",
                },
              );
            } else {
              if (widget.source == 'dialog') {
                Navigator.pop(context);
              } else {
                // Reset bottom navigation bar index
                UiUtils
                        .bottomNavigationBarGlobalKey
                        .currentState
                        ?.selectedIndexOfBottomNavigationBar
                        .value =
                    0;

                // Navigate and remove all previous routes
                Navigator.of(context).pushNamedAndRemoveUntil(
                  navigationRoute,
                  (Route<dynamic> route) => false,
                );
              }
            }
          });
        });
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
}
