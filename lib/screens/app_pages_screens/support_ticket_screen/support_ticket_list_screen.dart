import 'package:fixit_user/config.dart';

class SupportTicketListScreen extends StatelessWidget {
  const SupportTicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
                  leadingWidth: 80,
                  title: Text(language(context, translations!.supportTickets),
                      style: appCss.dmDenseBold18
                          .textColor(appColor(context).darkText)),
                  centerTitle: true,
                  leading: CommonArrow(
                          arrow: rtl(context)
                              ? eSvgAssets.arrowRight
                              : eSvgAssets.arrowLeft,
                          onTap: () => route.pop(context))
                      .paddingDirectional(vertical: Insets.i8)),
      body: Column(children: [

        Container(
          padding: const EdgeInsets.all(Sizes.s12),
           decoration: ShapeDecoration(
                      color: appColor(context)
                              .whiteBg ,
                      shadows: [
                        BoxShadow(
                          color: appColor(context).darkText.withOpacity(0.06),
                          spreadRadius: 1,
                          blurRadius: 2,
                        )
                      ],
                      shape: SmoothRectangleBorder(
                        side: BorderSide(color: appColor(context).fieldCardBg),
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: AppRadius.r12,
                          cornerSmoothing: 1,
                        ),
                      ),
                    ),

                    child: Column(children: [
                      Row(children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("#123456",style: appCss.dmDenseSemiBold16
                              .textColor(appColor(context).primary)),
                            Text("December 16, 2024",style: appCss.dmDenseMedium12
                              .textColor(appColor(context).lightText)),
                          ],
                        ),
                        Container().decorated(color: appColor(context).primary.withOpacity(0.10),borderRadius: BorderRadius.circular(Insets.i30))
                      ],)
                    ],),
        )
      ],).padding(horizontal: Sizes.s20),
    );
  }
}