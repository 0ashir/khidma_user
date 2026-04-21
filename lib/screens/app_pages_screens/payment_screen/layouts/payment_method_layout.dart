import 'package:fixit_user/models/app_setting_model.dart';

import '../../../../config.dart';
import '../../../../config.dart';

class PaymentMethodLayout extends StatelessWidget {
  final PaymentMethods? data;
  final int? index, selectIndex;
  final GestureTapCallback? onTap;

  const PaymentMethodLayout({
    super.key,
    this.data,
    this.onTap,
    this.index,
    this.selectIndex,
  });

  @override
  Widget build(BuildContext context) {
    final value = Provider.of<PaymentProvider>(context, listen: true);

    // Determine if it's Card Payment (Stripe or Card)
    bool isCardPayment = data!.slug == "stripe" || 
                        data!.slug == "card" || 
                        data!.slug.toString().toLowerCase().contains("card");

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          // Cash Payment
          if (data!.slug == "cash")
            SvgPicture.asset(
              eSvgAssets.cash,
              colorFilter: ColorFilter.mode(
                appColor(context).primary, 
                BlendMode.srcIn,
              ),
            )
                .paddingAll(Sizes.s10)
                .decorated(
                  shape: BoxShape.circle,
                  color: appColor(context).primary.withOpacity(0.15),
                )

          // Card Payment / Stripe
           else if (isCardPayment)
            Image.asset(
              eImageAssets.cardPayment,           // ← Change this if your asset name is different
              height: Sizes.s45,
              width: Sizes.s70,
              fit: BoxFit.contain,
            )

          // Other Payment Methods
          else
            CommonImageLayout(
              height: Sizes.s45,
              boxFit: BoxFit.contain,
              width: Sizes.s70,
              image: data!.image,
              assetImage: eImageAssets.noImageFound1,
            ),

          const HSpace(Sizes.s12),

          // Title & Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCardPayment 
                    ? "Card Pay"                     // Custom title for card
                    : language(context, data!.name!).capitalizeFirst(),
                style: appCss.dmDenseSemiBold16.textColor(
                  selectIndex == index
                      ? appColor(context).primary
                      : appColor(context).darkText,
                ),
              ),

              // Processing Fee (Only show for non-cash methods)
              if (data!.slug != "cash")
                Column(
                  children: [
                    SizedBox(
                      width: 184,
                      child: Text(
                        softWrap: true,
                        symbolPosition
                            ? "+ ${getSymbol(context)}${language(context, data!.processingFee.toString())} gateway fees"
                                .capitalizeFirst()
                            : "+ ${language(context, data!.processingFee.toString())}${getSymbol(context)} gateway fees"
                                .capitalizeFirst(),
                        style: appCss.dmDenseMedium14.textColor(
                          appColor(context).darkText,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          )
        ]),
        
        CommonRadio(
          index: index,
          selectedIndex: selectIndex,
          onTap: onTap,
        )
      ],
    )
        .paddingSymmetric(vertical: Insets.i12, horizontal: Insets.i15)
        .boxBorderExtension(
          context,
          bColor: selectIndex == index
              ? appColor(context).stroke
              : appColor(context).fieldCardBg,
          isShadow: selectIndex == index ? false : true,
        )
        .paddingSymmetric(vertical: Insets.i10, horizontal: Sizes.s20)
        .inkWell(onTap: onTap);
  }
}