import '../../../../config.dart';

class RotationAnimationLayout extends StatelessWidget {
  const RotationAnimationLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashProvider>(builder: (context, splash, child) {
      return Roulette(
          animate: false,
          spins: 2,
          duration: const Duration(seconds: 5),
          child: AnimatedContainer(
              alignment: Alignment.center,
              height: splash.controller!.isCompleted ? Sizes.s45 : splash.size,
              width: splash.controller!.isCompleted ? Sizes.s45 : splash.size,
              duration: const Duration(seconds: 1),
              decoration: appSettingModel?.general?.splashScreenLogo != null
                  ? null
                  : ShapeDecoration(
                      color: splash.controller!.isCompleted
                          ? appColor(context).whiteBg
                          : appColor(context).primary,
                      shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: splash.controller!.isCompleted
                                  ? AppRadius.r8
                                  : AppRadius.r14,
                              cornerSmoothing: 1))),
              child: appSettingModel?.general?.splashScreenLogo != null
                  ? CachedNetworkImage(
                      /*    height: splash.controller!.isCompleted ? Sizes.s45 : splash.size,
              width: splash.controller!.isCompleted ? Sizes.s45 : splash.size, */
                      imageUrl:
                          "${appSettingModel?.general?.splashScreenLogo}" /* data?.media?.first.originalUrl ?? "" */,
                      imageBuilder: (context, imageProvider) => Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        height: splash.controller!.isCompleted
                            ? Sizes.s45
                            : splash.size,
                        width: splash.controller!.isCompleted
                            ? Sizes.s45
                            : splash.size,
                      ),
                      placeholder: (context, url) => Image.asset(
                              eImageAssets.noImageFound1,
                              fit: BoxFit.fill,
                              height: Sizes.s22,
                              width: Sizes.s22)
                          .paddingAll(Insets.i18),
                      errorWidget: (context, url, error) => Image.asset(
                              eImageAssets.noImageFound1,
                              fit: BoxFit.fill,
                              height: Sizes.s22,
                              width: Sizes.s22)
                          .paddingAll(Insets.i18),
                    )
                  :
                  /*   alignment: Alignment.center,
              height: splash.controller!.isCompleted ? Sizes.s45 : splash.size,
              width: splash.controller!.isCompleted ? Sizes.s45 : splash.size,
              duration: const Duration(seconds: 1), */
                  /*   decoration: ShapeDecoration(
                  color: splash.controller!.isCompleted
                      ? appColor(context).whiteBg
                      : appColor(context).primary,
                  shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: splash.controller!.isCompleted
                              ? AppRadius.r8
                              : AppRadius.r14,
                          cornerSmoothing: 1))),
              child: */
                  Text("ft",
                      style: splash.controller!.isCompleted
                          ? appCss.righteousSemiBold23
                              .textColor(appColor(context).darkText)
                          : appCss.dmDenseExtraBold70
                              .textColor(appColor(context).whiteBg))));
    });
  }
}
