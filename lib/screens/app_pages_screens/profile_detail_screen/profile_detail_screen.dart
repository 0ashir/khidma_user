import '../../../config.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileDetailProvider>(builder: (context1, value, child) {
      return Consumer<CommonApiProvider>(builder: (context2, profile, child) {
        return StatefulWrapper(
          onInit: () => Future.delayed(DurationClass.ms150)
              .then((value1) => value.onInitData(context)),
          child: Scaffold(
              appBar: AppBar(
                  centerTitle: true,
                  leading: CommonArrow(
                      arrow: eSvgAssets.arrowLeft,
                      onTap: () => route.pop(context)).paddingAll(Insets.i8),
                  title: Text(language(context, translations!.profileDetails),
                      style: appCss.dmDenseBold18
                          .textColor(appColor(context).darkText))),
              body: SingleChildScrollView(
                  child: Column(children: [
                const VSpace(Sizes.s20),
                Stack(children: [
                  const FieldsBackground(),
                  Column(children: [
                    Stack(alignment: Alignment.bottomCenter, children: [
                      Image.asset(eImageAssets.profileBg,
                              width: MediaQuery.of(context).size.width,
                              height: Sizes.s60)
                          .paddingOnly(bottom: Insets.i45),
                      Stack(alignment: Alignment.bottomRight, children: [
                        ProfilePicCommon(
                            image: value.imageFile,
                            imageUrl: value.userModel != null
                                ? value.userModel!.media.isNotEmpty
                                    ? value.userModel!.media[0].originalUrl
                                    : null
                                : null),
                        SizedBox(
                                child: SvgPicture.asset(eSvgAssets.edit,
                                        height: Sizes.s14)
                                    .paddingAll(Insets.i7))
                            .decorated(
                                color: appColor(context).stroke,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: appColor(context).primary))
                            .inkWell(onTap: () => value.showLayout(context))
                      ])
                    ]),
                    const VSpace(Sizes.s40),
                    TextFieldLayout()
                  ]).paddingSymmetric(vertical: Insets.i20)
                ]),
                const VSpace(Sizes.s40),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  decoration: ShapeDecoration(
                      color: appColor(context).primary,
                      shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: AppRadius.r8, cornerSmoothing: 1))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      value.isUpdateLoader
                          ? const CircularProgressIndicator(color: Colors.white)
                              .center()
                              .padding(vertical: Sizes.s5)
                          : Text(language(context, translations!.update),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: appCss.dmDenseRegular16
                                  .textColor(appColor(context).whiteColor)),
                    ],
                  ),
                ).inkWell(
                    onTap: value.isUpdateLoader
                        ? () {}
                        : () => value.updateProfile(context))
                /* ButtonCommon(
                  title: translations!.update,
                  onTap: () => value.updateProfile(context),
                ) */
              ]).paddingSymmetric(horizontal: Insets.i20))),
        );
      });
    });
  }
}
