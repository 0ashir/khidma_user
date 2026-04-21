import '../../../../config.dart';

class FavProviderShimmer extends StatelessWidget {
  const FavProviderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            const Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              CommonSkeleton(height: Sizes.s90),
            ]).marginSymmetric(horizontal: Sizes.s10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonWhiteShimmer(
                      width: Sizes.s55,
                      height: Sizes.s55,
                      isCircle: false,
                      radius: Sizes.s5,
                    ),
                    HSpace(Sizes.s10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonWhiteShimmer(
                            width: Sizes.s100, height: Sizes.s14),
                        VSpace(Sizes.s5),
                        CommonWhiteShimmer(width: Sizes.s80, height: Sizes.s14),
                      ],
                    ),
                    Spacer(),
                    CommonWhiteShimmer(
                      width: Sizes.s30,
                      height: Sizes.s30,
                    ),
                  ],
                ).paddingAll(Sizes.s20),
              ],
            ),
          ],
        ).padding(bottom: Sizes.s20);
      },
    );
  }
}
