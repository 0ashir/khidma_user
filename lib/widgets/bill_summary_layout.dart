import '../config.dart';

class BillSummaryLayout extends StatelessWidget {
  final String? balance;
  const BillSummaryLayout({super.key, this.balance});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(language(context, translations!.billSummary),
          style: appCss.dmDenseMedium14.textColor(appColor(context).darkText)),
      Text("${language(context, translations!.wallet)}: ${"$balance"}",
          style: appCss.dmDenseMedium12.textColor(appColor(context).online))
    ]);
  }
}
