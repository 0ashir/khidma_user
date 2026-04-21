import 'package:fixit_user/config.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/berlin_layout.dart/berlin_custom_coupon.dart';

class BerlinSkeleton extends StatelessWidget {
  const BerlinSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Stack(children: [
          const CommonSkeleton(
              height: Sizes.s100, bLRadius: Insets.i20, bRRadius: Insets.i20),
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
              ]).padding(horizontal: Sizes.s20, top: Sizes.s20)
        ]),
        const VSpace(Sizes.s25),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              ...List.generate(5, (index) {
                return const Column(children: [
                  CommonSkeleton(height: Sizes.s58, width: Sizes.s58),
                  VSpace(Sizes.s15),
                  CommonSkeleton(height: Sizes.s12, width: Sizes.s50)
                ]).padding(left: Insets.i20);
              })
            ])),
        const VSpace(Sizes.s25),
        const CommonSkeleton(height: Sizes.s158, radius: Sizes.s8)
            .padding(horizontal: Insets.i20),
        const VSpace(Sizes.s15),
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          CommonSkeleton(height: Sizes.s5, width: Sizes.s15),
          HSpace(Sizes.s3),
          CommonSkeleton(height: Sizes.s5, width: Sizes.s5, isCircle: true)
        ]),
        const VSpace(Sizes.s25),
        const RowText().paddingSymmetric(horizontal: Sizes.s20),
        const VSpace(Sizes.s15),
        CommonSkeleton(
                baseColor: Colors.grey /* .withOpacity(0.1) */,
                child: CustomPaint(
                    size: Size(Sizes.s55, (Sizes.s55).toDouble()),
                    painter: BerlinCustomCoupon()))
            .padding(left: Insets.i20),
        const VSpace(Sizes.s25),
        const RowText().paddingSymmetric(horizontal: Sizes.s20),
        const VSpace(Sizes.s15),
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
                            CommonSkeleton(height: Sizes.s12, width: Sizes.s60),
                            VSpace(Sizes.s5),
                            VSpace(Sizes.s10),
                            CommonSkeleton(height: Sizes.s40)
                          ]))
                  .decorated(
                      color: appColor(context).whiteBg,
                      borderRadius: BorderRadius.circular(AppRadius.r8),
                      border: Border.all(color: appColor(context).stroke));
            }).paddingSymmetric(horizontal: Insets.i15),
        const VSpace(Sizes.s30),
      ],
    );
  }
}
