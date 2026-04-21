import 'dart:developer';
import '../../../../config.dart';

class TorontoAppbar extends StatelessWidget {
  final String? location;
  final GestureTapCallback? onTap;

  const TorontoAppbar({super.key, this.location, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer3<DashboardProvider, HomeScreenProvider, LoginProvider>(
        builder: (context1, dash, value, login, child) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const HSpace(Sizes.s20),
          SizedBox(
              height: Sizes.s40,
              width: Sizes.s40,
              child: CachedNetworkImage(
                  imageUrl: userModel != null &&
                          userModel!.media.isNotEmpty
                      ? userModel!.media[0].originalUrl
                      : "",
                  imageBuilder: (context, imageProvider) => Container(
                      height: Sizes.s88,
                      width: Sizes.s88,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                          border: Border.all(
                              color:
                                  appColor(context).whiteBg.withOpacity(0.75),
                              width: 4,
                              style: BorderStyle.solid))),
                  placeholder: (context, url) => Container(
                      height: Sizes.s88,
                      width: Sizes.s88,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage(eImageAssets.noImageFound3),
                              fit: BoxFit.cover),
                          border: Border.all(
                              color: appColor(context).whiteBg.withOpacity(0.75),
                              width: 4,
                              style: BorderStyle.solid))),
                  errorWidget: (context, url, error) => Container(height: Sizes.s88, width: Sizes.s88, decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage(eImageAssets.noImageFound3), fit: BoxFit.cover), border: Border.all(color: appColor(context).whiteBg.withOpacity(0.75), width: 4, style: BorderStyle.solid)))).inkWell(
                onTap: () {
                  if (login.pref?.getBool(session.isContinueAsGuest) == true) {
                    hideLoading(context);
                    route.pushNamed(context, routeName.login);

                    log("value::::$value");
                  } else {
                    dash.selectIndex = 3;
                    dash.notifyListeners();
                    hideLoading(context);
                  }
                },
              )),
          const HSpace(Sizes.s10),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    login.pref?.getBool(session.isContinueAsGuest) == true
                        ? translations?.guestUser ?? appFonts.guestUser
                        : userModel?.name ?? 'Demo User'.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: appCss.dmDenseBold14
                        .textColor(appColor(context).darkText)),
              ])
        ]),
        Row(children: [
          CommonArrow(arrow: eSvgAssets.search).inkWell(onTap: () {
            route.pushNamed(context, routeName.search);
          }),
          const HSpace(Sizes.s10),
          Consumer<NotificationProvider>(
              builder: (context1, notification, child) {
            return Container(
                    alignment: Alignment.center,
                    height: Sizes.s40,
                    width: Sizes.s40,
                    child: Stack(alignment: Alignment.topRight, children: [
                      SvgPicture.asset(eSvgAssets.notification,
                          alignment: Alignment.center,
                          fit: BoxFit.scaleDown,
                          colorFilter: ColorFilter.mode(
                              appColor(context).darkText, BlendMode.srcIn)),
                      if (notification.totalCount() != 0)
                        Positioned(
                            top: 2,
                            right: 2,
                            child: Icon(Icons.circle,
                                size: Sizes.s7, color: appColor(context).red))
                    ]))
                .decorated(
                    shape: BoxShape.circle,
                    color: appColor(context).fieldCardBg)
                .inkWell(onTap: () => value.notificationTap(context))
                .paddingOnly(
                    right: rtl(context) ? 0 : Insets.i20,
                    left: rtl(context) ? Insets.i20 : 0);
          })
        ])
      ]);
    });
  }
}
