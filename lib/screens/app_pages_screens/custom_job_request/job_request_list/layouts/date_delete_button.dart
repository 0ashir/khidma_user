import 'package:intl/intl.dart';

import '../../../../../config.dart';

class DateDeleteButton extends StatelessWidget {
  final JobRequestModel? data;
  final GestureTapCallback? onTap;
  const DateDeleteButton({super.key, this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
          DateFormat("MMM d, yyyy")
              .format(DateTime.parse(data!.bookingDate!)),
          style:
          appCss.dmDenseMedium12.textColor(appColor(context).lightText)),
      CommonArrow(
          arrow: eSvgAssets.delete,
          color: appColor(context).red.withOpacity(0.10),
          svgColor: appColor(context).red,
          isThirteen: true,
          onTap: onTap)
    ]);
  }
}
