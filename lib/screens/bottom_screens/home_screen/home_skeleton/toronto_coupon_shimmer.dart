import 'package:fixit_user/screens/bottom_screens/home_screen/toronto_layout/toronto_coupon_coustom_layout.dart';

import '../../../../config.dart';

class TorontoCouponShimmer extends StatelessWidget {
  const TorontoCouponShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          ...List.generate(3, (index) {
            return Stack(children: [
              CommonSkeleton(
                  baseColor: Colors.grey.withOpacity(0.1),
                  child: CustomPaint(
                      size: Size(Sizes.s120, (Sizes.s137).toDouble()),
                      painter: TorontoCouponCoustomLayout())),
              const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CommonWhiteShimmer(
                      height: Sizes.s34,
                      width: Sizes.s34,
                      isCircle: false,
                      radius: 5,
                    ),
                    VSpace(Sizes.s5),
                    CommonWhiteShimmer(height: Sizes.s12, width: Sizes.s100),
                    VSpace(Sizes.s30),
                    CommonWhiteShimmer(height: Sizes.s12, width: Sizes.s80),
                    VSpace(Sizes.s5),
                    CommonWhiteShimmer(height: Sizes.s12, width: Sizes.s50),
                    HSpace(Sizes.s25),
                  ]).marginSymmetric(horizontal: Sizes.s10, vertical: Sizes.s15)
            ]).marginSymmetric(horizontal: Sizes.s10);
          })
        ]).marginSymmetric(horizontal: Sizes.s10));
  }
}
