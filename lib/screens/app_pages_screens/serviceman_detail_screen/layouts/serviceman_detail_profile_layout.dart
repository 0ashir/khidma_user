import '../../../../config.dart';

class ServicemanDetailProfileLayout extends StatelessWidget {
  final String? image;
  const ServicemanDetailProfileLayout({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Image.asset(eImageAssets.servicemanBg,
              height: Sizes.s66, width: MediaQuery.of(context).size.width)
          .paddingOnly(bottom: Insets.i40),
      Container(
        alignment: Alignment.center,
        height: Sizes.s90,
        width: Sizes.s90,
        decoration: BoxDecoration(
          border: Border.all(color: appColor(context).whiteColor, width: 4),
          shape: BoxShape.circle,
          /*  image: DecorationImage(
          decoration: BoxDecoration(
          decoration: BoxDecoration(
                  image: AssetImage(image!)) */
        ),
        child: CachedNetworkImage(
            imageUrl: image ?? "" /* data!.media![0].originalUrl! */,
            imageBuilder: (context, imageProvider) => Container(
                height: Sizes.s90,
                width: Sizes.s90,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover, image: imageProvider))),
            errorWidget: (context, url, error) => Container(
                height: Sizes.s40,
                width: Sizes.s40,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(eImageAssets.noImageFound3))))),
      ).paddingOnly(top: Insets.i12)
    ]);
  }
}
