import 'package:fixit_user/screens/bottom_screens/home_screen/tokyo_layout/tokyo_custom_coupon_layout.dart';

import '../../../../config.dart';

class TokyoCouponShimmer extends StatelessWidget {
  const TokyoCouponShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          ...List.generate(3, (index) {
            return Stack(children: [
              CommonSkeleton(
                  baseColor: Colors.grey /* .withOpacity(0.1) */,
                  child: CustomPaint(
                      size: Size(Sizes.s210, (Sizes.s96).toDouble()),
                      painter: TokyoCustomCouponLayout())),
            ]).marginSymmetric(horizontal: Sizes.s10);
          })
        ]).marginSymmetric(horizontal: Sizes.s10));
  }
}
