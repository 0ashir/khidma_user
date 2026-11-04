import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/authentication/logoutCubit.dart'
    show LogoutCubit;

import 'package:e_demand/ui/widgets/customSwitch.dart';
import 'package:e_demand/ui/widgets/unreadChatCounterBadgeContainer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.scrollController,
    final Key? key,
    this.currentVersion,
  }) : super(key: key);
  final String? currentVersion;
  final ScrollController scrollController;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? latestVersionOfAndroid, latestVersionOfIOS;
  bool _isShareInProgress = false;

  @override
  void initState() {
    super.initState();
    getLatestVersions();
  }

  @override
  void dispose() {
    widget.scrollController.dispose();
    super.dispose();
  }

  void getLatestVersions() {
    Future.delayed(Duration.zero).then((final value) {
      if (!mounted) return;
      latestVersionOfAndroid = context
          .read<SystemSettingCubit>()
          .androidVersion;
      latestVersionOfIOS = context.read<SystemSettingCubit>().iOSVersion;
    });
  }

  /// White rounded card shell shared by every section on the screen.
  Widget _sectionCard({
    required final Widget child,
    final EdgeInsetsGeometry? padding,
  }) => CustomContainer(
    color: context.colors.surfacePrimary,
    borderRadius: UiUtils.borderRadiusOf12,
    padding: padding ?? const EdgeInsets.all(12),
    child: child,
  );

  /// Section title + hairline divider used at the top of a [_sectionCard].
  Widget _sectionHeader({required final String title, final Color? color}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,
            color: color ?? context.colors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          const CustomSizedBox(height: 8),
          CustomContainer(height: 1, color: context.colors.borderDefault),
          const CustomSizedBox(height: 8),
        ],
      );

  Widget _buildListItemWidget({
    final GlobalKey? key,
    required final String imageName,
    required final String title,
    final bool showDarkModeToggle = false,
    final VoidCallback? onTap,
    final bool showLanguageName = false,
    final double bottomPadding = 0,
    final Color? imageColor,
    final Color? titleColor,
    final Color? iconBackgroundColor,
    final int? unreadNotificationCount,
  }) => Padding(
    padding: EdgeInsetsDirectional.only(bottom: bottomPadding),
    child: CustomInkWellContainer(
      key: key,
      onTap: onTap,
      child: Row(
        children: [
          CustomContainer(
            color: iconBackgroundColor ?? context.colors.backgroundSecondary,
            borderRadius: 24,
            padding: const EdgeInsets.all(8),
            child: CustomSvgPicture(
              avoideResponsive: true,
              svgImage: imageName,
              color: imageColor ?? context.colors.iconPrimary,
              height: 20,
              width: 20,
            ),
          ),
          const CustomSizedBox(width: 12),
          Expanded(
            child: CustomText(
              title,
              color: titleColor ?? context.colors.textPrimary,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          if (HiveRepository.getCurrentLanguage() != null)
            if (showLanguageName) ...[
              CustomText(
                HiveRepository.getCurrentLanguage()!.languageName,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.colors.textSecondary,
              ),
            ],
          if (showDarkModeToggle) ...[
            CustomSwitch(
              thumbColor: context.colors.backgroundInverse,
              trackColor: context.colors.backgroundTertiary,
              activeColor: context.colors.backgroundTertiary,
              value:
                  context.read<AppThemeCubit>().state.appTheme == AppTheme.dark,
              onChanged: (final bool value) {
                HiveRepository.setDarkThemeEnable = value;

                if (value) {
                  context.read<AppThemeCubit>().changeTheme(AppTheme.dark);
                } else {
                  context.read<AppThemeCubit>().changeTheme(AppTheme.light);
                }
              },
            ),
          ],
          if ((unreadNotificationCount ?? 0) > 0)
            UnreadChatCounterBadgeContainer(count: unreadNotificationCount!),
          if (!showLanguageName && !showDarkModeToggle) ...[
            CustomSvgPicture(
              svgImage:
                  Directionality.of(
                    context,
                  ).toString().contains(TextDirection.RTL.value.toLowerCase())
                  ? AppAssets.backArrow
                  : AppAssets.backArrowLtr,
              color: context.colors.iconPrimary,
              height: 24,
              width: 24,
              avoideResponsive: true,
            ),
          ],
        ],
      ),
    ),
  );

  Widget _buildBecomeProviderBanner() => CustomInkWellContainer(
    borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
    onTap: () => _handleBecomeProviderClick(context),
    child: CustomContainer(
      width: double.infinity,
      color: context.colors.surfacePrimary,
      borderRadius: UiUtils.borderRadiusOf12,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 16,
              top: 16,
              bottom: 16,
              end: 140,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  'becomeProvider'.translate(context: context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
                const CustomSizedBox(height: 4),
                CustomText(
                  'becomeProviderDescription'.translate(context: context),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textSecondary,
                  maxLines: 3,
                ),
                const CustomSizedBox(height: 12),
                CustomContainer(
                  color: context.colors.component.buttonPrimaryBg,
                  borderRadius: UiUtils.borderRadiusOf12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: CustomText(
                    'getStarted'.translate(context: context),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: context.colors.component.buttonPrimaryText,
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            end: -10,
            bottom: -50,
            child: Image.asset(
              AppAssets.drBecomeProvider,
              height: 230,
              width: 210,
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(final BuildContext context) => AnnotatedRegion(
    value: UiUtils.getSystemUiOverlayStyle(context: context),
    child: Scaffold(
      backgroundColor: context.colors.backgroundSecondary,
      appBar: UiUtils.getSimpleAppBar(
        context: context,
        title: 'myProfile'.translate(context: context),
        isLeadingIconEnable: false,
      ),
      body: SingleChildScrollView(
        controller: widget.scrollController,
        padding: const EdgeInsetsDirectional.only(bottom: 65),
        child: BlocBuilder<UserDetailsCubit, UserDetailsState>(
          builder: (final BuildContext context, UserDetailsState state) {
            final token = HiveRepository.getUserToken;

            return Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomSizedBox(height: 16),
                  BlocBuilder<UserDetailsCubit, UserDetailsState>(
                    builder:
                        (
                          final BuildContext context,
                          final UserDetailsState userDetails,
                        ) {
                          if (userDetails is UserDetails) {
                            void openEditProfile() {
                              final UserDetailsModel userDetails = context
                                  .read<UserDetailsCubit>()
                                  .getUserDetails();

                              Navigator.pushNamed(
                                context,
                                editProfileRoute,
                                arguments: {
                                  'source': 'profileScreen',
                                  "isNewUser": false,
                                  "countryCodeName":
                                      userDetails.countryCodeName,
                                  "countryCode": userDetails.countryCode,
                                  "phoneNumberWithOutCountryCode":
                                      userDetails.phone,
                                  "loginType": userDetails.loginType,
                                },
                              );
                            }

                            return _sectionCard(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CustomContainer(
                                    width: 48,
                                    height: 48,
                                    borderRadius: 24,
                                    color: context.colors.backgroundSecondary,
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        (HiveRepository
                                                    .getUserProfilePictureURL ==
                                                null ||
                                            HiveRepository
                                                    .getUserProfilePictureURL ==
                                                '')
                                        ? Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: CustomSvgPicture(
                                              svgImage: AppAssets.user,
                                              color: context.colors.iconPrimary,
                                            ),
                                          )
                                        : CustomCachedNetworkImage(
                                            height: 48,
                                            width: 48,
                                            fit: BoxFit.cover,
                                            networkImageUrl: HiveRepository
                                                .getUserProfilePictureURL
                                                .toString(),
                                          ),
                                  ),
                                  const CustomSizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (token != '') ...{
                                          CustomText(
                                            HiveRepository.getUsername ?? '',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: context.colors.textPrimary,
                                            maxLines: 1,
                                          ),
                                          if (HiveRepository
                                                  .getUserMobileNumber !=
                                              '') ...[
                                            const CustomSizedBox(height: 4),
                                            CustomText(
                                              "${HiveRepository.getUserMobileCountryCode ?? ''}${HiveRepository.getUserMobileNumber ?? ''}",
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color:
                                                  context.colors.textSecondary,
                                              maxLines: 1,
                                            ),
                                          ],
                                        } else ...{
                                          CustomText(
                                            'guest'.translate(context: context),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: context.colors.textPrimary,
                                            maxLines: 1,
                                          ),
                                          const CustomSizedBox(height: 4),
                                          CustomText(
                                            "login_or_signup".translate(
                                              context: context,
                                            ),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: context.colors.textSecondary,
                                            maxLines: 1,
                                          ),
                                        },
                                      ],
                                    ),
                                  ),
                                  if (token != '') ...[
                                    const CustomSizedBox(width: 8),
                                    CustomInkWellContainer(
                                      borderRadius: BorderRadius.circular(
                                        UiUtils.borderRadiusOf8,
                                      ),
                                      onTap: openEditProfile,
                                      child: CustomContainer(
                                        color:
                                            context.colors.backgroundSecondary,
                                        borderRadius: UiUtils.borderRadiusOf8,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CustomSvgPicture(
                                              avoideResponsive: true,
                                              svgImage: AppAssets.edit,
                                              color: context.colors.iconPrimary,
                                              height: 16,
                                              width: 16,
                                            ),
                                            const CustomSizedBox(width: 4),
                                            CustomText(
                                              'edit'.translate(
                                                context: context,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: context.colors.textPrimary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    const CustomSizedBox(width: 8),
                                    CustomInkWellContainer(
                                      borderRadius: BorderRadius.circular(
                                        UiUtils.borderRadiusOf8,
                                      ),
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        loginRoute,
                                        arguments: {'source': 'profileScreen'},
                                      ),
                                      child: CustomContainer(
                                        color:
                                            context.colors.backgroundSecondary,
                                        borderRadius: UiUtils.borderRadiusOf8,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        child: CustomText(
                                          'login'.translate(context: context),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: context.colors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                  ),
                  const CustomSizedBox(height: 16),
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          title: 'content'.translate(context: context),
                        ),
                        if (token != '') ...[
                          _buildListItemWidget(
                            imageName: AppAssets.drNotification,
                            title: 'notification'.translate(context: context),
                            bottomPadding: 12,
                            onTap: () {
                              Navigator.pushNamed(context, notificationRoute);
                            },
                          ),
                          _buildListItemWidget(
                            imageName: AppAssets.drFavorite,
                            title: 'bookmark'.translate(context: context),
                            bottomPadding: 12,
                            onTap: () {
                              Navigator.pushNamed(context, bookmarkRoute);
                            },
                          ),
                          _buildListItemWidget(
                            imageName: AppAssets.mapPinArea,
                            title: 'address'.translate(context: context),
                            bottomPadding: 12,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                manageAddressScreen,
                                arguments: {'appBarTitle': 'address'},
                              );
                            },
                          ),
                          _buildListItemWidget(
                            onTap: () {
                              Navigator.pushNamed(context, blogsRoute);
                            },
                            imageName: AppAssets.fileText,
                            title: 'blogs'.translate(context: context),
                            bottomPadding: 12,
                          ),
                          _buildListItemWidget(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                paymentDetailsScreen,
                              );
                            },
                            imageName: AppAssets.drPayment,
                            title: 'payment'.translate(context: context),
                          ),
                        ] else ...[
                          _buildListItemWidget(
                            onTap: () {
                              Navigator.pushNamed(context, blogsRoute);
                            },
                            imageName: AppAssets.fileText,
                            title: 'blogs'.translate(context: context),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const CustomSizedBox(height: 16),
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          title: 'preference'.translate(context: context),
                        ),
                        _buildListItemWidget(
                          showLanguageName: true,
                          imageName: AppAssets.drLanguage,
                          title: 'language'.translate(context: context),
                          bottomPadding: 12,
                          onTap: () {
                            Navigator.pushNamed(context, languageRoute);
                          },
                        ),
                        _buildListItemWidget(
                          showDarkModeToggle: true,
                          imageName: AppAssets.drTheme,
                          title: 'darkMode'.translate(context: context),
                        ),
                      ],
                    ),
                  ),
                  const CustomSizedBox(height: 16),
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          title: 'others'.translate(context: context),
                        ),
                        _buildListItemWidget(
                          imageName: AppAssets.drRateUs,
                          title: 'rateApp'.translate(context: context),
                          bottomPadding: 12,
                          onTap: () => _handleRateAppClick(context),
                        ),
                        Builder(
                          builder: (context) {
                            return _buildListItemWidget(
                              key: _shareButtonKey,
                              imageName: AppAssets.drShare,
                              title: 'shareApp'.translate(context: context),
                              onTap: () => _handleShareAppClick(context),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const CustomSizedBox(height: 16),
                  _sectionCard(
                    child: _buildListItemWidget(
                      imageName: AppAssets.support,
                      title: 'helpAndSupport'.translate(context: context),
                      onTap: () {
                        Navigator.pushNamed(context, supportHelpRoute);
                      },
                    ),
                  ),
                  const CustomSizedBox(height: 16),
                  _sectionCard(
                    child: _buildListItemWidget(
                      imageName: AppAssets.drPolicy,
                      title: 'legalAndInformation'.translate(context: context),
                      onTap: () {
                        Navigator.pushNamed(context, legalInformationRoute);
                      },
                    ),
                  ),
                  if (token != '') ...[
                    const CustomSizedBox(height: 16),
                    _sectionCard(
                      child: _buildListItemWidget(
                        imageName: AppAssets.drAccount,
                        title: 'account'.translate(context: context),
                        onTap: () {
                          Navigator.pushNamed(context, accountRoute);
                        },
                      ),
                    ),
                    const CustomSizedBox(height: 16),
                    _sectionCard(
                      child: _buildListItemWidget(
                        imageName: AppAssets.drLogout,
                        title: 'logoutFromApp'.translate(context: context),
                        onTap: () {
                          UiUtils.showBottomSheet(
                            context: context,
                            enableDrag: true,
                            isScrollControlled: true,
                            useSafeArea: true,
                            child: BlocProvider<LogoutCubit>(
                              create: (context) =>
                                  LogoutCubit(AuthenticationRepository()),
                              child: const LogoutAccountSheet(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const CustomSizedBox(height: 16),
                  _buildBecomeProviderBanner(),
                  CustomSizedBox(
                    height: 70,
                    child: Center(
                      child: CustomText(
                        "$appName ${Platform.isAndroid ? "v$latestVersionOfAndroid" : "v$latestVersionOfIOS"}",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );

  Future<void> _handleBecomeProviderClick(BuildContext context) async {
    final String providerAppURL = context
        .read<SystemSettingCubit>()
        .getProviderAppURL;

    final bool canLaunch = await canLaunchUrl(Uri.parse(providerAppURL));
    if (!context.mounted) return;
    if (canLaunch) {
      try {
        launchUrl(
          Uri.parse(providerAppURL),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        UiUtils.showMessage(
          context,
          'somethingWentWrong'.translate(context: context),
          ToastificationType.error,
        );
      }
    }
  }

  final GlobalKey _shareButtonKey = GlobalKey();

  void _handleShareAppClick(BuildContext context) {
    if (_isShareInProgress) return;

    _isShareInProgress = true;
    try {
      UiUtils.share(
        context: context,
        context.read<SystemSettingCubit>().getCustomerAppURL,
      );
    } catch (e) {
      UiUtils.showMessage(
        context,
        'somethingWentWrong'.translate(context: context),
        ToastificationType.warning,
      );
    } finally {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _isShareInProgress = false;
      });
    }
  }

  Future<void> _handleRateAppClick(BuildContext context) async {
    final String customerAppURL = context
        .read<SystemSettingCubit>()
        .getCustomerAppURL;
    final bool canLaunch = await canLaunchUrl(Uri.parse(customerAppURL));
    if (!context.mounted) return;
    if (canLaunch) {
      launchUrl(
        Uri.parse(customerAppURL),
        mode: LaunchMode.externalApplication,
      );
    } else {
      UiUtils.showMessage(
        context,
        'unableToOpen'.translate(context: context),
        ToastificationType.error,
      );
    }
  }
}
