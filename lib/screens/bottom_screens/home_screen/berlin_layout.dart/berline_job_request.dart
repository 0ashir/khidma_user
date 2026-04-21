// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:fixit_user/config.dart';

class BerlinJobRequest extends StatelessWidget {
  const BerlinJobRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        SvgPicture.asset(eSvgAssets.berlinJobRequest),
        Image.asset(
          eImageAssets.linePackage,
          color: const Color(0XFF7A8591),
        ).padding(horizontal: Sizes.s18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language(context, translations!.customJobRequestQuestion),
                  textAlign: TextAlign.start,
                  style: appCss.dmDenseMedium13
                      .textColor(appColor(context).darkText)),
              const VSpace(Sizes.s10),
              Text(translations!.postNewJobRequest!,
                      textAlign: TextAlign.start,
                      style: appCss.dmDenseMedium14
                          .textColor(appColor(context).primary))
                  .inkWell(onTap: () async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();

                bool isGuest =
                    preferences.getBool(session.isContinueAsGuest) ?? false;
                if (isGuest == false) {
                  route.pushNamed(context, routeName.jobRequestList);
                } else {
                  route.pushAndRemoveUntil(context);
                  hideLoading(context);
                }
              }),
            ],
          ),
        ),
      ])
    ])
        .inkWell(onTap: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();

          bool isGuest =
              preferences.getBool(session.isContinueAsGuest) ?? false;
          if (isGuest == false) {
            route.pushNamed(context, routeName.jobRequestList);
          } else {
            route.pushAndRemoveUntil(context);
            hideLoading(context);
          }
        })
        .paddingAll(13)
        .boxBorderExtension(context,
            color: appColor(context).primary.withOpacity(.10),
            isShadow: true,
            bColor: appColor(context).primary.withOpacity(.10))
        .marginSymmetric(horizontal: Sizes.s20);
  }
}
