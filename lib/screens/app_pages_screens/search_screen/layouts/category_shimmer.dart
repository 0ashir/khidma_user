import '../../../../config.dart';

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          CommonSkeleton(height: Sizes.s70),
        ]).marginSymmetric(horizontal: Sizes.s10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CommonWhiteShimmer(
                  width: Sizes.s30,
                  height: Sizes.s30,
                  isCircle: false,
                  radius: Sizes.s5,
                ),
                HSpace(Sizes.s10),
                CommonWhiteShimmer(width: Sizes.s100, height: Sizes.s14),
                Spacer(),
                CommonWhiteShimmer(
                  width: Sizes.s30,
                  height: Sizes.s30,
                  isCircle: false,
                  radius: Sizes.s5,
                ),
              ],
            ).paddingAll(Sizes.s20),
          ],
        ),
      ],
    ).padding(bottom: Sizes.s20);
  }
}
