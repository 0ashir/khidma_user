import '../../../../config.dart';

class NewJobRequestLayout extends StatelessWidget {
  const NewJobRequestLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(language(context, translations!.customJobRequestQuestion),
            textAlign: TextAlign.center,
            style:
                appCss.dmDenseMedium14.textColor(appColor(context).darkText)),
        const VSpace(Sizes.s20),
        ButtonCommon(
          title: translations!.postNewJobRequest!,
          margin: 35,
          onTap: () => requestJobTap(
              context) /* route.pushNamed(context, routeName.jobRequestList) */,
          style: appCss.dmDenseMedium12.textColor(
            appColor(context).whiteColor,
          ),
        )
      ],
    )
        .paddingAll(20)
        .boxBorderExtension(context,
            color: appColor(context).primary.withOpacity(.10),
            isShadow: true,
            bColor: appColor(context).primary.withOpacity(.10))
        .marginSymmetric(horizontal: Sizes.s20);
  }

  requestJobTap(context) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    bool isGuest = preferences.getBool(session.isContinueAsGuest) ?? false;
    if (isGuest == false) {
      route.pushNamed(context, routeName.jobRequestList);
    } else {
      route.pushAndRemoveUntil(context);
      hideLoading(context);
    }
  }
}
