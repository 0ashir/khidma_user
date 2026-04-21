import 'package:fixit_user/config.dart';

class DubaiSkeleton extends StatelessWidget {
  const DubaiSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDark(context) ? Colors.black : Colors.white,
        body: ListView(children: [
          const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonSkeleton(height: Sizes.s50, width: Sizes.s210),
                HSpace(Sizes.s10),
                Row(children: [
                  CommonSkeleton(
                      height: Sizes.s45, width: Sizes.s45, isCircle: true),
                  HSpace(Sizes.s10),
                  CommonSkeleton(
                      height: Sizes.s45, width: Sizes.s45, isCircle: true)
                ])
              ]).paddingSymmetric(horizontal: Sizes.s20),
          const VSpace(Sizes.s30),
          Stack(children: [
            const CommonSkeleton(height: Sizes.s158, radius: Sizes.s8)
                .padding(horizontal: Insets.i20),
            const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonWhiteShimmer(width: Sizes.s70),
                  VSpace(Sizes.s12),
                  CommonWhiteShimmer(width: Sizes.s175),
                  VSpace(Sizes.s12),
                  CommonWhiteShimmer(width: Sizes.s130)
                ]).paddingSymmetric(horizontal: Sizes.s25, vertical: Sizes.s40)
          ]),
          const VSpace(Sizes.s3),
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            CommonSkeleton(height: Sizes.s5, width: Sizes.s15),
            HSpace(Sizes.s3),
            CommonSkeleton(height: Sizes.s5, width: Sizes.s5, isCircle: true)
          ]),
          const VSpace(Sizes.s12),
          const VSpace(Sizes.s12),
          const RowText().paddingSymmetric(horizontal: Sizes.s20),
          const VSpace(Sizes.s20),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                ...List.generate(3, (index) {
                  return Stack(children: [
                    const CommonSkeleton(height: Sizes.s41, width: Sizes.s124),
                    const Row(children: [
                      CommonWhiteShimmer(width: Sizes.s24),
                      HSpace(Sizes.s5),
                      CommonWhiteShimmer(width: Sizes.s80)
                    ]).padding(top: Sizes.s10, left: Sizes.s8)
                  ]).padding(left: Insets.i20);
                })
              ])),
          const VSpace(Sizes.s28),
          const RowText().paddingSymmetric(horizontal: Sizes.s20),
          const VSpace(Sizes.s17),
          GridView.builder(
              itemCount: homeFeaturedService.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.596,
                  mainAxisSpacing: Sizes.s16,
                  crossAxisSpacing: Sizes.s16),
              itemBuilder: (context, index) {
                return Container(
                        margin: const EdgeInsets.all(Insets.i10),
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(children: [
                                CommonSkeleton(
                                  height: Sizes.s110,
                                ),
                                Positioned(
                                    top: 8,
                                    left: 8,
                                    child: CommonWhiteShimmer(
                                        height: Sizes.s25, width: Sizes.s35))
                              ]),
                              VSpace(Sizes.s10),
                              CommonSkeleton(height: Sizes.s12),
                              VSpace(Sizes.s10),
                              CommonSkeleton(height: Sizes.s12, width: 80),
                              VSpace(Sizes.s10),
                              CommonSkeleton(
                                  height: Sizes.s12, width: Sizes.s60),
                              VSpace(Sizes.s5),
                              VSpace(Sizes.s10),
                              CommonSkeleton(height: Sizes.s40)
                            ]))
                    .decorated(
                        color: appColor(context).whiteBg,
                        borderRadius: BorderRadius.circular(AppRadius.r8),
                        border: Border.all(color: appColor(context).stroke));
              }).paddingSymmetric(horizontal: Insets.i15)
        ]).paddingSymmetric(vertical: Sizes.s20));
  }
}
