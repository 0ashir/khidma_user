import 'dart:developer';

import 'package:share_plus/share_plus.dart';

import '../../../../config.dart';

class ProfileOptionsLayout extends StatelessWidget {
  final AnimationController controller;
  final TickerProvider? sync;

  const ProfileOptionsLayout({super.key, required this.controller, this.sync});

  @override
  Widget build(BuildContext context) {
    return Consumer3<LoginProvider, LanguageProvider, ProfileProvider>(
        builder: (context, login, lang, value, child) {
      return Column(
          children: value.profileLists.asMap().entries.map((e) {
        bool isGuest = value.isGuest;

        var title = isGuest
            ? (e.value is Map ? e.value['title'] : e.value.title)
            : e.value['title'];

        var data = isGuest
            ? (e.value is Map ? e.value['data'] : e.value.data)
            : e.value['data'];
        // log("GUEST=$isGuest  | DATA=${e.value}||$data");

        //log("e.value:::${e.value}/// ${e.key}");
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (e.key != 3 /*  2 */)
            Text(
              language(context, title.toString()).toString().toUpperCase(),
              style: appCss.dmDenseBold14.textColor(
                  /* e.key == 3
                        ? appColor(context).red
                        : */
                  appColor(context).primary),
            ).padding /* Symmetric */ (
                vertical: isGuest == true ? Insets.i15 : Insets.i15),
          if (data != null && data is List && data.isNotEmpty)
            Container(
                decoration: ShapeDecoration(
                  color: e.key == 3
                      ? appColor(context).red.withOpacity(0.1)
                      : appColor(context)
                          .whiteBg /* appColor(context).whiteBg */,
                  shadows: [
                    BoxShadow(
                      color: e.key == 3
                          ? appColor(context).whiteBg
                          : appColor(context).darkText.withOpacity(0.06),
                      spreadRadius: 1,
                      blurRadius: 2,
                    )
                  ],
                  shape: SmoothRectangleBorder(
                    side: BorderSide(color: appColor(context).fieldCardBg),
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: AppRadius.r12,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                child: Column(
                        children: (data)
                            .asMap()
                            .entries
                            .map((s) => login.pref
                                        ?.getBool(session.isContinueAsGuest) ==
                                    true
                                ? ProfileOptionLayout2(
                                    data: s.value,
                                    index: s.key,
                                    mainIndex: e.key,
                                    list: data,
                                    onTap: () {
                                      log("message=-=-=-${s.key}//${data[s.key].title}");

                                      if (s.key == 0) {
                                        route.pushNamed(
                                            context, routeName.appDetails);
                                      } else if (s.key == 1) {
                                        Share.share(
                                            'Download the fixit User App for get better services at home.\n\nhttps://play.google.com/store/apps/details?id=com.fixit');
                                      }
                                    })
                                : ProfileOptionLayout(
                                    data: s.value,
                                    index: s.key,
                                    mainIndex: e.key,
                                    list: data,
                                    onTap: () => value.onTapOption(
                                        s.value, context, controller, sync)))
                            .toList())
                    .paddingAll(Insets.i15)),
          if (e.key == 1)
            if (appSettingModel?.activation?.becomeProvider == "1")
              const BecomeProviderLayout()
                  .padding(top: isGuest != true ? Sizes.s25 : 0)
        ]);
      }).toList());
    });
  }
}
