
import '../../../../config.dart';

class ProfileOptionLayout extends StatelessWidget {
  final dynamic data;
  final GestureTapCallback? onTap;
  final List? list;
  final int? index, mainIndex;

  const ProfileOptionLayout(
      {super.key,
      this.data,
      this.onTap,
      this.list,
      this.index,
      this.mainIndex});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LoginProvider, LanguageProvider>(
        builder: (context, login, value, child) {
      final isGuest = login.pref?.getBool(session.isContinueAsGuest) == true;
      // log("isGuest:::$isGuest");
// Properly extract values depending on guest or not
      final icon = login.pref?.getBool(session.isContinueAsGuest) == true
          ? (data is Map ? data['icon'] : data.icon)
          : (data is Map ? data['icon'] : data.icon);

      final title = login.pref?.getBool(session.isContinueAsGuest) == true
          ? (data is Map ? data['title'] : data.title)
          : (data is Map ? data['title'] : data.title);

      final isArrow = login.pref?.getBool(session.isContinueAsGuest) == true
          ? (data is Map ? data['isArrow'] : data.isArrow)
          : (data is Map ? data['isArrow'] : data.isArrow);

      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  CommonArrow(
                      arrow: icon,
                      color: mainIndex == 3
                          ? appColor(context).whiteColor
                          : appColor(context).fieldCardBg,
                      svgColor: mainIndex == 3
                          ? appColor(context).red
                          : appColor(context).darkText),
                  const HSpace(Sizes.s15),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language(context, title),
                            style: appCss.dmDenseMedium14.textColor(
                                mainIndex == 3
                                    ? appColor(context).red
                                    : appColor(context).darkText)),
// if (data.description != null)
                        // SizedBox(
                        // width: 200,
                        // child: Text(language(context, translations!.aboutUs),
                        // overflow: TextOverflow.ellipsis,
                        // style: appCss.dmDenseMedium12
                        // .textColor(appColor(context).lightText)),
                        // )
                      ])
                ]),
                if (isArrow == true)
                  SvgPicture.asset(
                      rtl(context)
                          ? eSvgAssets.arrowLeft
                          : eSvgAssets.arrowRight,
                      colorFilter: ColorFilter.mode(
                          appColor(context).lightText, BlendMode.srcIn))
              ]),
              if (index != list!.length - 1)
                Divider(
                        height: 0,
                        color: appColor(context).fieldCardBg,
                        thickness: 1)
                    .paddingSymmetric(vertical: Insets.i12)
            ])
          ]).inkWell(onTap: onTap);
    });
  }
}

// import '../../../../config.dart';
class ProfileOptionLayout2 extends StatelessWidget {
  final dynamic data;
  final GestureTapCallback? onTap;
  final List? list;
  final int? index, mainIndex;

  const ProfileOptionLayout2({
    super.key,
    this.data,
    this.onTap,
    this.list,
    this.index,
    this.mainIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer3<LoginProvider, LanguageProvider, AppSettingProvider>(
      builder: (context, login, value, settingCtrl, child) {
        final isGuest = login.pref?.getBool(session.isContinueAsGuest) == true;
// log("isGuest:::$isGuest");
        // Properly extract values depending on guest or not
        // Handle both object and map safely
        final icon = isGuest
            ? (data is Map ? data['icon'] : data.icon)
            : (data is Map ? data['icon'] : data.icon);

        final title = isGuest
            ? (data is Map ? data['title'] : data.title)
            : (data is Map ? data['title'] : data.title);

        final isArrow = isGuest
            ? (data is Map ? data['isArrow'] : data.isArrow)
            : (data is Map ? data['isArrow'] : data.isArrow);

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    CommonArrow(
                      arrow: icon,
                      color: mainIndex == 3
                          ? appColor(context).whiteColor
                          : appColor(context).fieldCardBg,
                      svgColor: mainIndex == 3
                          ? appColor(context).red
                          : appColor(context).darkText,
                    ),
                    const HSpace(Sizes.s15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language(context, title),
                          style: appCss.dmDenseMedium14.textColor(
                            mainIndex == 3
                                ? appColor(context).red
                                : appColor(context).darkText,
                          ),
                        ),
                      ],
                    )
                  ]),
                  if (isArrow == true)
                    SvgPicture.asset(
                      rtl(context)
                          ? eSvgAssets.arrowLeft
                          : eSvgAssets.arrowRight,
                      colorFilter: ColorFilter.mode(
                        appColor(context).lightText,
                        BlendMode.srcIn,
                      ),
                    ),
                ],
              ),
              if (index != null && list != null && index != list!.length - 1)
                Divider(
                  height: 0,
                  color: appColor(context).fieldCardBg,
                  thickness: 1,
                ).paddingSymmetric(vertical: Insets.i12),
            ]).inkWell(onTap: onTap),
          ],
        );
      },
    );
  }
}
