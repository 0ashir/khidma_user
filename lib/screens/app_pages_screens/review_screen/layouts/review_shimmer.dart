import '../../../../config.dart';

class ReviewShimmer extends StatelessWidget {
  const ReviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CommonSkeleton(height: Sizes.s230),
                  ]).marginSymmetric(horizontal: Sizes.s10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      CommonWhiteShimmer(width: Sizes.s38, height: Sizes.s38),
                      HSpace(Sizes.s10),
                      CommonWhiteShimmer(width: Sizes.s80, height: Sizes.s14),
                      Spacer(),
                      CommonWhiteShimmer(width: Sizes.s80, height: Sizes.s30),
                    ],
                  ).paddingAll(Sizes.s15),
                  const VSpace(Sizes.s10),
                  const CommonWhiteShimmer(height: Sizes.s14)
                      .padding(horizontal: Sizes.s15),
                  const VSpace(Sizes.s10),
                  const CommonWhiteShimmer(height: Sizes.s14)
                      .padding(horizontal: Sizes.s15),
                  const VSpace(Sizes.s10),
                  const CommonWhiteShimmer(
                    height: Sizes.s14,
                    width: Sizes.s150,
                  ).padding(horizontal: Sizes.s15),
                  const VSpace(Sizes.s20),
                  const Row(
                    children: [
                      CommonWhiteShimmer(width: Sizes.s80, height: Sizes.s14),
                      Spacer(),
                      CommonWhiteShimmer(width: Sizes.s38, height: Sizes.s38),
                      HSpace(Sizes.s15),
                      CommonWhiteShimmer(width: Sizes.s38, height: Sizes.s38),
                    ],
                  ).paddingAll(Sizes.s15),
                ],
              ),
            ],
          ).padding(bottom: Sizes.s20);
        });
  }
}
