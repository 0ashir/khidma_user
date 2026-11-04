import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    final Key? key,
    this.phoneNumberWithOutCountryCode,
    this.countryCode,
    this.countryCodeName,
    required this.uid,
    this.source,
    required this.loginType,
    this.userEmail,
    this.userName,
    required this.isNewUser,
  }) : super(key: key);

  final String? phoneNumberWithOutCountryCode;
  final String? countryCode;
  final String? countryCodeName;
  final String uid;
  final String? userEmail;
  final String? userName;
  final LogInType? loginType;
  final String? source;
  final bool isNewUser;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
    builder: (final BuildContext context) {
      Map arguments = {};
      if (routeSettings.arguments != null) {
        arguments = routeSettings.arguments as Map;
      }

      return EditProfileScreen(
        phoneNumberWithOutCountryCode:
            arguments['phoneNumberWithOutCountryCode'] ?? '',
        countryCode: arguments['countryCode'] ?? '',
        countryCodeName: arguments['countryCodeName'] ?? '',
        source: arguments['source'] ?? '',
        uid: arguments['uid'] ?? '',
        loginType: arguments["loginType"],
        userEmail: arguments["userEmail"] ?? '',
        userName: arguments["userName"] ?? '',
        isNewUser: arguments["isNewUser"],
      );
    },
  );
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  FocusNode nameFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  UserDetailsModel? userDetails;
  File? selectedImage;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    nameFocusNode.dispose();
    phoneFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      if (!mounted) return;
      if (widget.countryCodeName != '' &&
          widget.countryCodeName != null &&
          widget.countryCodeName != 'null') {
        final countryCodeCubit = context.read<CountryCodeCubit>();
        final country = await countryCodeCubit.getCountryByCountryCode(
          context,
          countryLocale: widget.countryCodeName!,
        );
        countryCodeCubit.selectCountryCode(country);
      }
    });

    if (widget.phoneNumberWithOutCountryCode != '' &&
        widget.phoneNumberWithOutCountryCode != null &&
        widget.phoneNumberWithOutCountryCode != 'null') {
      // Phone number without country code (country code is shown in prefix)
      phoneNumberController.text = widget.phoneNumberWithOutCountryCode!;

      Future.delayed(Duration.zero, () {
        if (!mounted) return;
        userDetails = context.read<UserDetailsCubit>().getUserDetails();
      });
    } else if (HiveRepository.getUserMobileNumber != null) {
      // Phone number without country code
      phoneNumberController.text = HiveRepository.getUserMobileNumber ?? '';
    }

    if (widget.userEmail != '' &&
        widget.userEmail != null &&
        widget.userEmail != 'null') {
      emailController.text = widget.userEmail!;

      Future.delayed(Duration.zero, () {
        if (!mounted) return;
        userDetails = context.read<UserDetailsCubit>().getUserDetails();
      });
    } else if (HiveRepository.getUserEmailId != null) {
      emailController.text = HiveRepository.getUserEmailId ?? '';
    }
    if (widget.userName!.trim() != '' &&
        widget.userName != null &&
        widget.userName != 'null') {
      usernameController.text = widget.userName!;

      Future.delayed(Duration.zero, () {
        if (!mounted) return;
        userDetails = context.read<UserDetailsCubit>().getUserDetails();
      });
    } else if (HiveRepository.getUsername != null) {
      usernameController.text = HiveRepository.getUsername ?? '';
    }
  }

  Future<void> _getFromGallery() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    final croppedFile = await _croppedImage(pickedFile!.path);

    setState(() {
      selectedImage = File(croppedFile!.path);
    });
  }

  Future<CroppedFile?> _croppedImage(String pickedFilePath) async {
    return ImageCropper().cropImage(
      sourcePath: pickedFilePath,
      compressFormat: ImageCompressFormat.png,
      uiSettings: [
        AndroidUiSettings(
          aspectRatioPresets: [CropAspectRatioPreset.square],
          cropStyle: CropStyle.circle,
          toolbarTitle: "cropImage".translate(context: context),
          toolbarColor: context.colors.backgroundBrand,
          toolbarWidgetColor: context.colors.textInverseLight,
          initAspectRatio: CropAspectRatioPreset.square,
          hideBottomControls: true,
          activeControlsWidgetColor: context.colors.backgroundSecondary,
        ),
        IOSUiSettings(
          title: "cropImage".translate(context: context),
          aspectRatioPresets: [CropAspectRatioPreset.square],
          cropStyle: CropStyle.circle,
        ),
      ],
    );
  }

  @override
  Widget build(
    final BuildContext context,
  ) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: UiUtils.getSystemUiOverlayStyle(context: context),
    child: AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        backgroundColor: context.colors.backgroundSecondary,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: (widget.isNewUser ? "registrationForm" : "editProfile")
              .translate(context: context),
          backgroundColor: context.colors.backgroundPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: BlocConsumer<UpdateUserCubit, UpdateUserState>(
              listener: (context, UpdateUserState updateUserState) {
                if (updateUserState is UpdateUserSuccess) {
                  final existingUserDetails =
                      (context.read<UserDetailsCubit>().state as UserDetails)
                          .userDetailsModel;

                  final newUserDetails = existingUserDetails.fromMapCopyWith(
                    updateUserState.updatedDetails.toMap(),
                  );
                  context.read<UserDetailsCubit>().changeUserDetails(
                    newUserDetails,
                  );
                }
              },
              builder: (final context, UpdateUserState updateUserState) {
                final userProfilePictureURL =
                    HiveRepository.getUserProfilePictureURL;
                return Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CustomInkWellContainer(
                          onTap: () {
                            _getFromGallery();
                          },
                          showRippleEffect: false,
                          child: SizedBox(
                            width: 140,
                            height: 140,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipOval(
                                  child: Container(
                                    width: 140,
                                    height: 140,
                                    color: context.colors.backgroundTertiary,
                                    child: selectedImage != null
                                        ? Image.file(
                                            File(selectedImage?.path ?? ''),
                                            width: 140,
                                            height: 140,
                                            fit: BoxFit.cover,
                                          )
                                        : (userProfilePictureURL == null ||
                                              userProfilePictureURL == '')
                                        ? Center(
                                            child: CustomSvgPicture(
                                              svgImage: AppAssets.user,
                                              color: context.colors.iconPrimary,
                                              height: 56,
                                              width: 56,
                                              avoideResponsive: true,
                                            ),
                                          )
                                        : CustomCachedNetworkImage(
                                            networkImageUrl:
                                                HiveRepository
                                                    .getUserProfilePictureURL ??
                                                '',
                                            width: 140,
                                            height: 140,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                PositionedDirectional(
                                  bottom: 0,
                                  end: 0,
                                  child: CustomContainer(
                                    avoideResponsive: true,
                                    color: context.colors.backgroundBrand,
                                    shape: BoxShape.circle,
                                    padding: const EdgeInsets.all(8),
                                    child: CustomSvgPicture(
                                      svgImage: AppAssets.camera,
                                      color: context.colors.iconInverseLight,
                                      height: 24,
                                      width: 24,
                                      avoideResponsive: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const CustomSizedBox(height: 28),
                      CustomTextFormField(
                        labelText: "username".translate(context: context),
                        isRequired: true,
                        hintText: "enterUsername".translate(context: context),
                        hintTextColor: context.colors.textTertiary,
                        fillColor: context.colors.backgroundPrimary,
                        borderColor: context.colors.borderDefault,
                        borderWidth: 1,
                        focusedBorderColor: context.colors.borderFocus,
                        focusedBorderWidth: 1,
                        bottomPadding: 0,
                        controller: usernameController,
                        currentFocusNode: nameFocusNode,
                        textInputType: TextInputType.name,
                        prefix: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 12),
                          child: CustomSvgPicture(
                            svgImage: AppAssets.user,
                            color: context.colors.iconPrimary,
                            boxFit: BoxFit.scaleDown,
                          ),
                        ),
                        validator: (username) =>
                            isTextFieldEmpty(context: context, value: username),
                      ),
                      const CustomSizedBox(height: 16),
                      CustomTextFormField(
                        labelText: "mobileNumber".translate(context: context),
                        isRequired:
                            widget.loginType != LogInType.apple &&
                            widget.loginType != LogInType.google,
                        hintText: "enterPhoneNumber".translate(
                          context: context,
                        ),
                        hintTextColor: context.colors.textTertiary,
                        fillColor: context.colors.backgroundPrimary,
                        borderColor: context.colors.borderDefault,
                        borderWidth: 1,
                        focusedBorderColor: context.colors.borderFocus,
                        focusedBorderWidth: 1,
                        bottomPadding: 0,
                        currentFocusNode: phoneFocusNode,
                        controller: phoneNumberController,
                        isReadOnly: widget.loginType == LogInType.phone,
                        textInputAction: TextInputAction.done,
                        inputFormatters: UiUtils.allowOnlyDigits(),
                        prefix: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 12),
                          child: BlocBuilder<CountryCodeCubit, CountryCodeState>(
                            builder:
                                (
                                  final BuildContext context,
                                  final CountryCodeState state,
                                ) {
                                  var code = '--';

                                  if (state is CountryCodeFetchSuccess) {
                                    code = state.selectedCountry!.callingCode;
                                  }

                                  return CustomInkWellContainer(
                                    onTap: widget.loginType == LogInType.phone
                                        ? null
                                        : () {
                                            if (allowOnlySingleCountry ||
                                                (state
                                                        is CountryCodeFetchSuccess &&
                                                    state.temporaryCountryList !=
                                                        null &&
                                                    state
                                                            .temporaryCountryList!
                                                            .length ==
                                                        1)) {
                                              return;
                                            }
                                            Navigator.pushNamed(
                                              context,
                                              countryCodePickerRoute,
                                            ).then((Object? value) {
                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 250,
                                                ),
                                              ).then((final value) {
                                                if (!context.mounted) return;
                                                context
                                                    .read<CountryCodeCubit>()
                                                    .fillTemporaryList();
                                              });
                                            });
                                          },
                                    child: IntrinsicWidth(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 5.0,
                                            ),
                                            child: CustomSvgPicture(
                                              svgImage: AppAssets.phone,
                                              color: context.colors.iconPrimary,
                                              boxFit: BoxFit.scaleDown,
                                              height: 24,
                                              width: 24,
                                            ),
                                          ),
                                          const CustomSizedBox(width: 8),
                                          Text(
                                            code,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: context.colors.textPrimary,
                                            ),
                                          ),
                                          if (widget.loginType !=
                                                  LogInType.phone &&
                                              !(allowOnlySingleCountry ||
                                                  (state
                                                          is CountryCodeFetchSuccess &&
                                                      state.temporaryCountryList !=
                                                          null &&
                                                      state
                                                              .temporaryCountryList!
                                                              .length ==
                                                          1)))
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color: context.colors.iconPrimary,
                                              size: 24,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                          ),
                        ),
                        textInputType: TextInputType.number,
                        validator: (mobileNumber) {
                          // Make phone number optional for Apple and Google login
                          if (widget.loginType == LogInType.apple ||
                              widget.loginType == LogInType.google) {
                            return null;
                          }
                          return isTextFieldEmpty(
                            value: mobileNumber,
                            context: context,
                          );
                        },
                      ),
                      const CustomSizedBox(height: 16),
                      CustomTextFormField(
                        labelText: "email".translate(context: context),
                        isRequired: true,
                        hintText: "enterYourEmailAddress".translate(
                          context: context,
                        ),
                        hintTextColor: context.colors.textTertiary,
                        fillColor: context.colors.backgroundPrimary,
                        borderColor: context.colors.borderDefault,
                        borderWidth: 1,
                        focusedBorderColor: context.colors.borderFocus,
                        focusedBorderWidth: 1,
                        bottomPadding: 0,
                        controller: emailController,
                        currentFocusNode: emailFocusNode,
                        prefix: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 12),
                          child: CustomSvgPicture(
                            svgImage: AppAssets.envelopeSimple,
                            color: context.colors.iconPrimary,
                            boxFit: BoxFit.scaleDown,
                          ),
                        ),
                        isReadOnly:
                            widget.loginType == LogInType.email ||
                            widget.loginType == LogInType.apple ||
                            widget.loginType == LogInType.google,
                        textInputType: TextInputType.emailAddress,
                        validator: (email) =>
                            isValidEmail(email: email ?? '', context: context),
                      ),
                      if (widget.isNewUser &&
                          widget.loginType != LogInType.apple &&
                          widget.loginType != LogInType.google &&
                          (context.read<SystemSettingCubit>().state
                              is SystemSettingFetchSuccess) &&
                          (context.read<SystemSettingCubit>().state
                                      as SystemSettingFetchSuccess)
                                  .systemSettingDetails
                                  .loginSettings
                                  ?.isPasswordLoginEnabled ==
                              true) ...[
                        const CustomSizedBox(height: 16),
                        CustomPasswordFieldWithValidators(
                          controller: passwordController,
                          currentFocusNode: passwordFocusNode,
                          nextFocusNode: confirmPasswordFocusNode,
                          labelText: "newPassword",
                          hintText: "enterPassword",
                          isRequired: true,
                          textInputAction: TextInputAction.next,
                          validator: (password) => isValidPassword(
                            password: password ?? '',
                            context: context,
                          ),
                        ),
                        const CustomSizedBox(height: 16),
                        CustomTextFormField(
                          labelText: "confirmPassword",
                          isRequired: true,
                          hintText: "enterConfirmPassword",
                          hintTextColor: context.colors.textTertiary,
                          fillColor: context.colors.backgroundPrimary,
                          borderColor: context.colors.borderDefault,
                          borderWidth: 1,
                          focusedBorderColor: context.colors.borderFocus,
                          focusedBorderWidth: 1,
                          bottomPadding: 0,
                          controller: confirmPasswordController,
                          currentFocusNode: confirmPasswordFocusNode,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: (confirmPassword) =>
                              confirmPasswordValidator(
                                password: passwordController.text,
                                confirmPassword: confirmPassword ?? '',
                                context: context,
                              ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: ClipShadowBottom(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.backgroundPrimary,
              boxShadow: [
                BoxShadow(
                  color: context.colors.overlayFooterShadow,
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BlocConsumer<UpdateUserCubit, UpdateUserState>(
                  listener: (final context, final state) {
                    if (state is UpdateUserSuccess) {
                      ClarityService.logAction(
                        ClarityActions.profileUpdateSaved,
                        {
                          'is_new_user': widget.isNewUser,
                          'login_type': widget.loginType?.name.toString() ?? '',
                          'email': emailController.text.trim(),
                          'phone': phoneNumberController.text.trim(),
                        },
                      );
                      UiUtils.showMessage(
                        context,
                        'profileUpdateSuccess'.translate(context: context),
                        ToastificationType.success,
                      );

                      if (!widget.isNewUser) {
                        //user is editing their profile details
                        Navigator.pop(context);
                      }
                    } else if (state is UpdateUserFail) {
                      UiUtils.showMessage(
                        context,
                        state.error,
                        ToastificationType.error,
                      );
                    }
                  },
                  builder: (final BuildContext context, UpdateUserState state) {
                    final isSubmitting =
                        _isSubmitting || state is UpdateUserInProgress;
                    return CustomRoundedButton(
                      onTap: isSubmitting
                          ? null
                          : () => _handleSaveChangesClick(context),
                      buttonTitle:
                          (widget.isNewUser ? "continue" : "updateProfile")
                              .translate(context: context),
                      titleColor: context.colors.textInverseLight,
                      backgroundColor: context.colors.backgroundBrand,
                      showBorder: false,
                      widthPercentage: 1,
                      height: 48,
                      radius: 12,
                      textSize: 16,
                      fontWeight: FontWeight.w500,
                      child: isSubmitting
                          ? CustomCircularProgressIndicator(
                              color: context.colors.textInverseLight,
                            )
                          : null,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _handleSaveChangesClick(BuildContext context) async {
    if (_isSubmitting ||
        context.read<UpdateUserCubit>().state is UpdateUserInProgress) {
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    UiUtils.removeFocus();
    setState(() => _isSubmitting = true);
    try {
      await _saveChanges(context);
    } catch (error) {
      if (!context.mounted) return;
      UiUtils.showMessage(
        context,
        error.toString().translate(context: context),
        ToastificationType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _saveChanges(BuildContext context) async {
    //if user is registering their profile first time
    if (widget.isNewUser) {
      final latitude = HiveRepository.getLatitude ?? "0.0";
      final longitude = HiveRepository.getLongitude ?? "0.0";

      String? fcmId;
      try {
        await FirebaseMessaging.instance.getToken().then((value) async {
          fcmId = value;
        });
      } catch (_) {}
      if (!context.mounted) return;

      // Get country code for the phone field
      String? phoneCountryCode;
      String? phoneNumber;

      if (widget.loginType == LogInType.phone) {
        // Phone users - use widget country code
        phoneCountryCode = widget.countryCode;
        phoneNumber = widget.phoneNumberWithOutCountryCode;
      } else {
        // Email/Google/Apple users - get country code from selector
        final phoneInput = phoneNumberController.text.trim();
        if (phoneInput.isNotEmpty) {
          try {
            phoneCountryCode = context
                .read<CountryCodeCubit>()
                .getSelectedCountryCode();
          } catch (e) {
            phoneCountryCode = null;
          }
          phoneNumber = phoneInput;
        } else {
          // Phone number is optional for Apple/Google login
          phoneCountryCode = null;
          phoneNumber = null;
        }
      }

      await AuthenticationRepository.loginUser(
        uid: widget.uid,
        fcmId: fcmId,
        latitude: latitude.toString(),
        longitude: longitude.toString(),
        loginType: widget.loginType!,
        mobileNumber: phoneNumber,
        countryCode: phoneCountryCode,
        userName: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim().isNotEmpty
            ? passwordController.text.trim()
            : null,
      ).then((final UserDetailsModel value) async {
        ClarityService.logAction(ClarityActions.signupCompleted, {
          'uid': widget.uid,
          'login_type': widget.loginType?.name.toString() ?? '',
          'country_code': widget.countryCode ?? '',
        });
        ClarityService.logAction(ClarityActions.loginSuccess, {
          'uid': widget.uid,
          'login_type': widget.loginType?.name.toString() ?? '',
        });
        if (!context.mounted) return;
        context.read<UserDetailsCubit>().setUserDetails(value);

        // For new user registration, manage_user already sets all data
        // No need to call update_user afterward

        //update user authenticated status
        HiveRepository.setUserFirstTimeInApp = false;
        HiveRepository.setUserLoggedIn = true;

        if (context.mounted) {
          context.read<AuthenticationCubit>().checkStatus();
        }

        await Future<void>.delayed(Duration.zero, () async {
          if (!context.mounted) return;
          try {
            await context.read<SystemSettingCubit>().getSystemSettings();
            if (!context.mounted) return;
            final futureAPIs = <Future>[
              context.read<HomeScreenCubit>().fetchHomeScreenData(),
              context.read<BookingCubit>().fetchAllBookings(status: ''),
              context.read<MyRequestListCubit>().fetchRequests(),
              context.read<CartCubit>().getCartDetails(isReorderCart: false),
              context.read<BookmarkCubit>().fetchBookmark(type: 'list'),
              context.read<UserDetailsCubit>().loadUserDetails(),
              context.read<EnquiryChatUserCubit>().fetchChatUsers(),
              context.read<BookingChatUserCubit>().fetchChatUsers(),
            ];

            Future.wait(futureAPIs);
          } catch (_) {}
          if (!context.mounted) return;
          if (widget.source == "dialog") {
            Navigator.pop(context);
            Navigator.pop(context);
          } else {
            UiUtils
                    .bottomNavigationBarGlobalKey
                    .currentState
                    ?.selectedIndexOfBottomNavigationBar
                    .value =
                0;
            Navigator.pushNamedAndRemoveUntil(context, navigationRoute, (_) {
              return false;
            });
          }
        });
      });
    } else {
      //if user is editing their profile then directly update their data

      // Get country code for phone field
      String? phoneCountryCode;
      String? phoneNumber;

      if (widget.loginType == LogInType.phone) {
        // Phone users - use existing country code
        phoneCountryCode = widget.countryCode;
        phoneNumber = widget.phoneNumberWithOutCountryCode
            ?.toString()
            .replaceAll(widget.countryCode.toString(), '');
      } else {
        // Email/Google/Apple users - get country code from selector
        final phoneInput = phoneNumberController.text.trim();
        if (phoneInput.isNotEmpty) {
          try {
            phoneCountryCode = context
                .read<CountryCodeCubit>()
                .getSelectedCountryCode();
          } catch (e) {
            phoneCountryCode = null;
          }
          phoneNumber = phoneInput;
        } else {
          // Phone number is optional for Apple/Google login
          phoneCountryCode = null;
          phoneNumber = null;
        }
      }

      final UpdateUserDetails updateUserDetails = UpdateUserDetails(
        email: emailController.value.text,
        phone: phoneNumber,
        countryCode: phoneCountryCode ?? '',
        username: usernameController.value.text,
        image: selectedImage ?? '',
        loginType: widget.loginType?.name.toString(),
        uid: widget.uid,
      );

      await context.read<UpdateUserCubit>().updateUserDetails(
        updateUserDetails,
      );
    }
  }
}
