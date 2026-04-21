import 'dart:developer';

import '../../../../config.dart';

/*
class ProfileLayout extends StatelessWidget {
  final Animation<Offset>? offsetAnimation;
  final GestureTapCallback? onTap;

  const ProfileLayout({super.key, this.offsetAnimation, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CommonApiProvider, ProfileProvider>(
        builder: (context1, value, profile, child) {
      return Stack(alignment: Alignment.topRight, children: [
        SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(children: [
                  ProfilePicCommon(
                          imageUrl:
                              userModel != null && userModel!.media.isNotEmpty
                                  ? userModel!.media[0].originalUrl!
                                  : null)
                      .inkWell(
                    onTap: () {
                      if (profile.isGuest) {
                        hideLoading(context);
                        route.pushNamed(
                            context,
                            routeName
                                .login) */
/*  route.pushReplacementNamed(context, routeName.login) */ /*
;

                        log("value::::$value");
                      } else {
                        hideLoading(context);
                      }
                    },
                  ),
                  const VSpace(Sizes.s5),
                  if (profile.isGuest)
                    Text("Guest",
                        style: appCss.dmDenseSemiBold14
                            .textColor(appColor(context).darkText)),
                  if (!profile.isGuest)
                    userModel != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                Text(
                                    userModel != null
                                        ? capitalizeFirstLetter(userModel!.name)
                                        : "",
                                    style: appCss.dmDenseSemiBold14
                                        .textColor(appColor(context).darkText)),
                                const VSpace(Sizes.s3),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(eSvgAssets.mail),
                                      const HSpace(Sizes.s5),
                                      Text(
                                          userModel != null &&
                                                  userModel!.email != null
                                              ? language(context,
                                                  userModel!.email.toString())
                                              : "",
                                          style: appCss.dmDenseMedium12
                                              .textColor(
                                                  appColor(context).lightText))
                                    ]),
                                const VSpace(Sizes.s3),
                                if (userModel != null)
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(eSvgAssets.phone),
                                        const HSpace(Sizes.s5),
                                        Text(
                                            userModel != null
                                                ? "+${userModel!.code} ${userModel!.phone}"
                                                : "",
                                            style: appCss.dmDenseMedium12
                                                .textColor(appColor(context)
                                                    .lightText))
                                      ])
                              ])
                        : userModel != null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    SvgPicture.asset(eSvgAssets.phone),
                                    const HSpace(Sizes.s5),
                                    Text(
                                        userModel != null
                                            ? "${userModel!.code} ${userModel!.phone}"
                                            : "",
                                        style: appCss.dmDenseMedium12.textColor(
                                            appColor(context).lightText))
                                  ])
                            : Container(),
                  const VSpace(Sizes.s16),
                  if (!profile.isGuest)
                    BalanceLayout(
                        isGuest: profile.isGuest,
                        offsetAnimation: offsetAnimation,
                        totalBalance:
                            userModel != null && userModel!.wallet != null
                                ? userModel!.wallet!.balance.toString()
                                : "0.00")
                ]).paddingSymmetric(
                    vertical: Insets.i15, horizontal: Insets.i13))
            .boxShapeExtension(
                color: appColor(context).fieldCardBg, radius: AppRadius.r12),
        if (!profile.isGuest)
          SvgPicture.asset(eSvgAssets.edit,
                  color: appColor(context).primary,
                  height: Sizes.s24,
                  width: Sizes.s24)
              .paddingAll(Insets.i15)
              .inkWell(onTap: onTap)
      ]);
    });
  }
}
*/

class ProfileLayout extends StatelessWidget {
  final Animation<Offset>? offsetAnimation;
  final GestureTapCallback? onTap;

  const ProfileLayout({super.key, this.offsetAnimation, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CommonApiProvider, ProfileProvider>(
        builder: (context1, value, profile, child) {
      return Stack(alignment: Alignment.topRight, children: [
        const Text("data-=-=-=-="),
        SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(children: [
                  /* ProfilePicCommon(
                          imageUrl: userModel != null &&
                                  userModel?.media != [] /* .isNotEmpty */
                              ? userModel!.media.first.originalUrl!
                              : null)
                      .inkWell(
                    onTap: () {
                      if (profile.isGuest) {
                        hideLoading(context);
                        route.pushNamed(
                            context,
                            routeName
                                .login) /*  route.pushReplacementNamed(context, routeName.login) */;

                        log("value::::$value");
                      } else {
                        hideLoading(context);
                      }
                    },
                  ), */
                  ProfilePicCommon(
                    imageUrl: (userModel != null &&
                            userModel!.media.isNotEmpty)
                        ? userModel!.media.first.originalUrl
                        : null,
                  ).inkWell(
                    onTap: () {
                      if (profile.isGuest) {
                        hideLoading(context);
                        route.pushNamed(context, routeName.login);
                        log("value::::$value");
                      } else {
                        hideLoading(context);
                      }
                    },
                  ),
                  const VSpace(Sizes.s5),
                  if (profile.isGuest)
                    Text("Guest",
                        style: appCss.dmDenseSemiBold14
                            .textColor(appColor(context).darkText)),
                  if (!profile.isGuest)
                    userModel != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // --- Name ---
                              Text(
                                (userModel?.name ?? "").isNotEmpty
                                    ? capitalizeFirstLetter(userModel?.name)
                                    : "",
                                style: appCss.dmDenseSemiBold14
                                    .textColor(appColor(context).darkText),
                              ),
                              const VSpace(Sizes.s3),

                              // --- Email ---
                              if ((userModel?.email ?? "").isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(eSvgAssets.mail),
                                    const HSpace(Sizes.s5),
                                    Text(
                                      language(context, userModel!.email),
                                      style: appCss.dmDenseMedium12.textColor(
                                          appColor(context).lightText),
                                    ),
                                  ],
                                ),

                              const VSpace(Sizes.s3),

                              // --- Phone ---
                              if ((userModel?.phone.toString() ?? "")
                                  .isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(eSvgAssets.phone),
                                    const HSpace(Sizes.s5),
                                    Text(
                                      "${userModel!.code ?? ""} ${userModel!.phone ?? ""}",
                                      style: appCss.dmDenseMedium12.textColor(
                                          appColor(context).lightText),
                                    ),
                                  ],
                                ),
                            ],
                          )
                        : Container()
                  else
                    Container(),

                  /*  if (!profile.isGuest)
                    userModel != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                Text(
                                    userModel?.name != null
                                        ? capitalizeFirstLetter(userModel?.name)
                                        : "",
                                    style: appCss.dmDenseSemiBold14
                                        .textColor(appColor(context).darkText)),
                                const VSpace(Sizes.s3),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(eSvgAssets.mail),
                                      const HSpace(Sizes.s5),
                                      Text(
                                          userModel != null &&
                                                  userModel!.email != null
                                              ? language(context,
                                                  userModel!.email.toString())
                                              : "",
                                          style: appCss.dmDenseMedium12
                                              .textColor(
                                                  appColor(context).lightText))
                                    ]),
                                const VSpace(Sizes.s3),
                                if (userModel != null)
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(eSvgAssets.phone),
                                        const HSpace(Sizes.s5),
                                        Text(
                                            userModel != null
                                                ? "${userModel!.code} ${userModel!.phone}"
                                                : "",
                                            style: appCss.dmDenseMedium12
                                                .textColor(appColor(context)
                                                    .lightText))
                                      ])
                              ])
                        : userModel != null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    SvgPicture.asset(eSvgAssets.phone),
                                    const HSpace(Sizes.s5),
                                    Text(
                                        userModel != null
                                            ? "${userModel!.code} ${userModel!.phone}"
                                            : "",
                                        style: appCss.dmDenseMedium12.textColor(
                                            appColor(context).lightText))
                                  ])
                            : Container(), */
                  const VSpace(Sizes.s16),
                  if (!profile.isGuest)
                    BalanceLayout(
                        isGuest: profile.isGuest,
                        offsetAnimation: offsetAnimation,
                        totalBalance:
                            userModel != null && userModel!.wallet != null
                                ? userModel!.wallet!.balance.toString()
                                : "0.00")
                ]).paddingSymmetric(
                    vertical: Insets.i15, horizontal: Insets.i13))
            .boxShapeExtension(
                color: appColor(context).fieldCardBg, radius: AppRadius.r12),
        if (!profile.isGuest)
          SvgPicture.asset(eSvgAssets.edit,
                  color: appColor(context).primary,
                  height: Sizes.s24,
                  width: Sizes.s24)
              .paddingAll(Insets.i15)
              .inkWell(onTap: onTap)
      ]);
    });
  }
}
