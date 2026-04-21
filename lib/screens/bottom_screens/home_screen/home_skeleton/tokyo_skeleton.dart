import 'package:fixit_user/config.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/home_skeleton/tokyo_coupon_shimmer.dart';

class TokyoSkeleton extends StatelessWidget {
  const TokyoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Stack(
          children: [
            const CommonSkeleton(
                height: Sizes.s158, bLRadius: Insets.i20, bRRadius: Insets.i20),
            const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    CommonSkeleton(
                        height: Sizes.s45, width: Sizes.s45, isCircle: true),
                    HSpace(Sizes.s10),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonSkeleton(height: Sizes.s14, width: Sizes.s138),
                          VSpace(Sizes.s4),
                          CommonSkeleton(height: Sizes.s14, width: Sizes.s155)
                        ])
                  ]),
                  Row(children: [
                    CommonSkeleton(
                        height: Sizes.s45, width: Sizes.s45, isCircle: true),
                    HSpace(Sizes.s10),
                    CommonSkeleton(
                        height: Sizes.s45, width: Sizes.s45, isCircle: true)
                  ])
                ]).padding(horizontal: Sizes.s20, top: Sizes.s18),
            Stack(
              children: [
                Column(
                  children: [
                    const CommonSkeleton(height: Sizes.s158, radius: Sizes.s8)
                        .padding(horizontal: Insets.i20),
                  ],
                ).padding(top: Sizes.s94),
                const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonWhiteShimmer(width: Sizes.s70),
                      VSpace(Sizes.s12),
                      CommonWhiteShimmer(width: Sizes.s175),
                      VSpace(Sizes.s12),
                      CommonWhiteShimmer(width: Sizes.s130),
                    ]).padding(horizontal: Sizes.s25, top: Sizes.s130),
              ],
            ),
            const VSpace(Sizes.s3),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              CommonSkeleton(height: Sizes.s5, width: Sizes.s15),
              HSpace(Sizes.s3),
              CommonSkeleton(height: Sizes.s5, width: Sizes.s5, isCircle: true)
            ]).padding(top: Sizes.s270),
            const VSpace(Sizes.s12),
          ],
        ),
        const VSpace(Sizes.s25),
        const RowText().paddingSymmetric(horizontal: Sizes.s20),
        const VSpace(Sizes.s15),
        const TokyoCouponShimmer(),
        const VSpace(Sizes.s25),
        const RowText().paddingSymmetric(horizontal: Sizes.s20),
        const VSpace(Sizes.s15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...List.generate(5, (index) {
                return const Column(
                  children: [
                    CommonSkeleton(
                        isCircle: true, height: Sizes.s58, width: Sizes.s58),
                    VSpace(Sizes.s15),
                    CommonSkeleton(height: Sizes.s12, width: Sizes.s50),
                  ],
                ).padding(left: Insets.i20);
              })
            ],
          ),
        ),
        const VSpace(Sizes.s30),
        const RowText().paddingSymmetric(horizontal: Sizes.s20),
      ],
    );
  }
}
