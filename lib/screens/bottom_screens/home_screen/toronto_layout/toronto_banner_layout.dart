import '../../../../config.dart';

class TorontoBannerLayout extends StatelessWidget {
  final List? bannerList;
  final Function(int index, CarouselPageChangedReason reason)? onPageChanged;
  final Function(String, String)? onTap;

  const TorontoBannerLayout(
      {super.key, this.bannerList, this.onPageChanged, this.onTap});

  @override
  Widget build(BuildContext context) {
    return bannerList!.any((banner) {
      // log("banner.media !=::${banner.media?.length}");
      return banner!.media!.isNotEmpty;
    })
        ? SizedBox(
            height: Sizes.s140,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: bannerList!.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Sizes.s10),
                    child: CachedNetworkImage(
                        // fit: BoxFit.fitHeight,
                        imageUrl: bannerList![index].media!.first.originalUrl!,
                        imageBuilder: (context, imageProvider) => Container(
                            width: Sizes.s270,
                            // width: double.parse(mediaItem.size!),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.fill))),
                        placeholder: (context, url) => Container(
                            width: Sizes.s270,
                            // width: double.parse(mediaItem.size!),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        eImageAssets.noImageFound2)))),
                        errorWidget: (context, url, error) => Image.asset(
                            eImageAssets.noImageFound2,
                            width: MediaQuery.of(context).size.width)),
                  ),
                )
                    .inkWell(
                        onTap: () => onTap!(bannerList![index].type!,
                            bannerList![index].relatedId.toString()))
                    .padding(right: Insets.i20);
              },
            ),
          )

        /* CarouselSlider(
            options: CarouselOptions(
                height: Sizes.s240,
                viewportFraction: 1,
                enlargeCenterPage: false,
                reverse: false,
                onPageChanged: onPageChanged),
            items: bannerList!
                .where((i) => i.media != null && i.media!.isNotEmpty)
                .map((i) {
              log("i.media![0].originalUrl::${i.media}");
              return Builder(builder: (BuildContext context) {
                final mediaItem = i.media!.first;

                return CachedNetworkImage(
                    imageUrl: mediaItem.originalUrl!,
                    imageBuilder: (context, imageProvider) => Container(
                        // width: double.parse(mediaItem.size!),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.fill))),
                    placeholder: (context, url) => Container(
                        // width: double.parse(mediaItem.size!),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage(eImageAssets.noImageFound2)))),
                    errorWidget: (context, url, error) => Image.asset(
                        eImageAssets.noImageFound2,
                        width: MediaQuery.of(context).size.width)).inkWell(
                  onTap: () /* {} */ => onTap!(i.type!, i.relatedId.toString()),
                );
              });
            }).toList(),
          ).paddingOnly(top: Insets.i20) */
        : const SizedBox.shrink(); // Display nothing if bannerList is null or empty
  }
}
