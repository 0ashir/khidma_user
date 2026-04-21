
import '../../../../config.dart';

class BannerLayout extends StatefulWidget {
  final List? bannerList;
  final bool isDubai;
  final bool? isBerlin;
  final Function(int index, CarouselPageChangedReason reason)? onPageChanged;
  final Function(String, String)? onTap;

  const BannerLayout({
    super.key,
    this.bannerList,
    this.onPageChanged,
    this.onTap,this.isBerlin,
    this.isDubai = false,
  });

  @override
  State<BannerLayout> createState() => _BannerLayoutState();
}

class _BannerLayoutState extends State<BannerLayout> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final filteredList = widget.bannerList!
        .where((i) => i.media != null && i.media!.isNotEmpty)
        .toList();

    if (filteredList.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        CarouselSlider(

          carouselController: _controller,
          options: CarouselOptions(
            autoPlay: true,
            height: widget.isDubai ? Sizes.s180 : Sizes.s240,
            viewportFraction: 1,
            enlargeCenterPage: false,
            reverse: false,
            onPageChanged: (index, reason) {
              setState(() => _current = index);
              widget.onPageChanged?.call(index, reason);
            }
          ),
          items: filteredList.map((i) {
            final mediaItem = i.media!.first;

            return ClipRRect(
              borderRadius:
              BorderRadius.circular(widget.isDubai ? Sizes.s9 : 0),
              child: CachedNetworkImage(
                imageUrl: mediaItem.originalUrl!,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(eImageAssets.noImageFound2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Image.asset(
                  eImageAssets.noImageFound2,
                  width: MediaQuery.of(context).size.width,
                ),
              ).inkWell(
                onTap: () {
                  if (widget.onTap != null) {
                    widget.onTap!(i.type!, i.relatedId.toString());
                  }
                },
              ),
            );
          }).toList(),
        ).padding(top: Insets.i20, horizontal: widget.isDubai ? Insets.i20 : 0),
if(widget.isBerlin==true)
        // Left Arrow
        Positioned(
          top: widget.isDubai ? Sizes.s90 : Sizes.s120,
          left: 8,
          child: GestureDetector(
            onTap: () => _controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            ),
            child: SvgPicture.asset(
              eSvgAssets.arrowLeft,
              height: Sizes.s16,
              colorFilter: ColorFilter.mode(
                appColor(context).primary,
                BlendMode.srcIn,
              ),
            ).paddingAll(Insets.i9).decorated(
              color: appColor(context).whiteBg,
              border: Border.all(
                color: appColor(context).primary.withOpacity(0.19),
              ),
              borderRadius: BorderRadius.circular(Insets.i20),
            ),
          ),
        ),
        if(widget.isBerlin==true)

        // Right Arrow
        Positioned(
          top: widget.isDubai ? Sizes.s90 : Sizes.s120,
          right: 8,
          child: GestureDetector(
            onTap: () => _controller.nextPage(),
            child: SvgPicture.asset(
              eSvgAssets.arrowRight,
              height: Sizes.s16,
              colorFilter: ColorFilter.mode(
                appColor(context).primary,
                BlendMode.srcIn,
              ),
            ).paddingAll(Insets.i9).decorated(
              color: appColor(context).whiteBg,
              border: Border.all(
                color: appColor(context).primary.withOpacity(0.19),
              ),
              borderRadius: BorderRadius.circular(Insets.i20),
            ),
          ),
        ),
      ],
    );
  }
}
