import 'package:fixit_user/config.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/home_skeleton/toronto_coupon_shimmer.dart';

class TorontoSkeleton extends StatelessWidget {
  const TorontoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDark(context) ? Colors.black : Colors.white,
        body: ListView(children: [
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
              ]).paddingSymmetric(horizontal: Sizes.s20),
          const VSpace(Sizes.s30),
          const Stack(
            children: [CommonSkeleton(height: Sizes.s50)],
          ).paddingSymmetric(horizontal: Sizes.s20),
          const VSpace(Sizes.s12),
          const Row(children: [
            CommonSkeleton(height: Sizes.s130, width: Sizes.s270, radius: 8),
            HSpace(Sizes.s15),
            CommonSkeleton(height: Sizes.s130, width: Sizes.s55, radius: 8)
          ]).padding(left: Sizes.s20),
          const VSpace(Sizes.s12),
          const VSpace(Sizes.s30),
          const RowText().paddingSymmetric(horizontal: Sizes.s20),
          const VSpace(Sizes.s20),
          const TorontoCouponShimmer(),
          const VSpace(Sizes.s28),
          const RowText().paddingSymmetric(horizontal: Sizes.s20),
          const VSpace(Sizes.s17),
          const GridShimmer(),
        ]).paddingSymmetric(vertical: Sizes.s20));
  }
}
