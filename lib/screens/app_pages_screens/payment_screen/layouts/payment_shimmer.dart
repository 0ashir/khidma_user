import 'package:fixit_user/config.dart';

class PaymentShimmer extends StatelessWidget {
  const PaymentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            const CommonSkeleton(
              height: Sizes.s70,
              isCircle: false,
              radius: Sizes.s5,
            ).paddingAll(Sizes.s20),
            const Row(
              children: [
                CommonWhiteShimmer(
                  width: Sizes.s45,
                  height: Sizes.s45,
                ),
                HSpace(Sizes.s10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonWhiteShimmer(width: Sizes.s100, height: Sizes.s14),
                    VSpace(Sizes.s8),
                    CommonWhiteShimmer(width: Sizes.s70, height: Sizes.s14),
                  ],
                ),
                Spacer(),
                CommonWhiteShimmer(
                  width: Sizes.s30,
                  height: Sizes.s30,
                ),
              ],
            ).padding(horizontal: Sizes.s30, top: 30),
          ],
        ),
        /*  VSpace(Sizes.s15), */
        Stack(
          children: [
            const CommonSkeleton(
              height: Sizes.s70,
              isCircle: false,
              radius: Sizes.s5,
            ).paddingAll(Sizes.s20),
            const Row(
              children: [
                CommonWhiteShimmer(
                  width: Sizes.s45,
                  height: Sizes.s45,
                ),
                HSpace(Sizes.s10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonWhiteShimmer(width: Sizes.s100, height: Sizes.s14),
                    VSpace(Sizes.s8),
                    CommonWhiteShimmer(width: Sizes.s70, height: Sizes.s14),
                  ],
                ),
                Spacer(),
                CommonWhiteShimmer(
                  width: Sizes.s30,
                  height: Sizes.s30,
                ),
              ],
            ).padding(horizontal: Sizes.s30, top: 30),
          ],
        ),
        Stack(
          children: [
            const CommonSkeleton(
              height: Sizes.s70,
              isCircle: false,
              radius: Sizes.s5,
            ).paddingAll(Sizes.s20),
            const Row(
              children: [
                CommonWhiteShimmer(
                  width: Sizes.s45,
                  height: Sizes.s45,
                ),
                HSpace(Sizes.s10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonWhiteShimmer(width: Sizes.s100, height: Sizes.s14),
                    VSpace(Sizes.s8),
                    CommonWhiteShimmer(width: Sizes.s70, height: Sizes.s14),
                  ],
                ),
                Spacer(),
                CommonWhiteShimmer(
                  width: Sizes.s30,
                  height: Sizes.s30,
                ),
              ],
            ).padding(horizontal: Sizes.s30, top: 30),
          ],
        ),
        Stack(
          children: [
            const CommonSkeleton(
              height: Sizes.s70,
              isCircle: false,
              radius: Sizes.s5,
            ).paddingAll(Sizes.s20),
            const Row(
              children: [
                CommonWhiteShimmer(
                  width: Sizes.s45,
                  height: Sizes.s45,
                ),
                HSpace(Sizes.s10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonWhiteShimmer(width: Sizes.s100, height: Sizes.s14),
                    VSpace(Sizes.s8),
                    CommonWhiteShimmer(width: Sizes.s70, height: Sizes.s14),
                  ],
                ),
                Spacer(),
                CommonWhiteShimmer(
                  width: Sizes.s30,
                  height: Sizes.s30,
                ),
              ],
            ).padding(horizontal: Sizes.s30, top: 30),
          ],
        ),
      ],
    );
  }
}
