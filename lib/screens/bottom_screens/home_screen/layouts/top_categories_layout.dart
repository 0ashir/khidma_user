import '../../../../config.dart';

class TopCategoriesLayout extends StatelessWidget {
  final data;
  final GestureTapCallback? onTap;
  final int? index, selectedIndex;
  final double? rPadding;
  final bool isCategories, isExapnded, isCircle;

  const TopCategoriesLayout(
      {super.key,
      this.onTap,
      this.data,
      this.index,
      this.selectedIndex,
      this.isCategories = false,
      this.isExapnded = true,
      this.isCircle = false,
      this.rPadding});

  @override
  Widget build(BuildContext context) {
    // log("data data ${data?.title}");
    return Column(children: [
      Container(
          height: Sizes.s60,
          width: Sizes.s60,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: isCircle == true
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedIndex == index
                      ? appColor(context).primary.withValues(alpha: 0.2)
                      : isCategories == true
                          ? appColor(context).whiteBg
                          : appColor(context).fieldCardBg,
                  border: Border.all(
                      color: selectedIndex == index
                          ? appColor(context).primary.withValues(alpha: 0.2)
                          : isCategories == true
                              ? appColor(context).whiteBg
                              : appColor(context).fieldCardBg,
                      width: 2,
                      style: BorderStyle.solid))
              : ShapeDecoration(
                  color: selectedIndex == index
                      ? appColor(context).primary.withOpacity(0.2)
                      : isCategories == true
                          ? appColor(context).whiteBg
                          : appColor(context).fieldCardBg,
                  shape: SmoothRectangleBorder(
                      side: BorderSide(
                          color: selectedIndex == index
                              ? appColor(context).primary
                              : appColor(context).trans),
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: AppRadius.r10, cornerSmoothing: 1))),
          child: data!.media != null && data!.media!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: data?.media?.first.originalUrl ?? "",
                  imageBuilder: (context, imageProvider) => Container(
                    padding: const EdgeInsets.all(
                        Insets.i1), // ← Reduced from i14 to i8 (or i10)
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.contain, // Better than cover for icons
                      height: Sizes.s28, // Slightly bigger image
                      width: Sizes.s28,
                    ),
                  ),
                  placeholder: (context, url) => Image.asset(
                    eImageAssets.noImageFound1,
                    fit: BoxFit.contain,
                    height: Sizes.s28,
                    width: Sizes.s28,
                  ), // Keep consistent padding
                  errorWidget: (context, url, error) => Image.asset(
                    data?.title == "All"
                        ? eImageAssets.all
                        : eImageAssets.noImageFound1,
                    fit: BoxFit.contain,
                    height: Sizes.s28,
                    width: Sizes.s28,
                  ),
                )
              : selectedIndex == index
                  ? Image.asset(
                      data?.title == "All"
                          ? eImageAssets.all
                          : eImageAssets.noImageFound1,
                      color: appColor(context).primary,
                      fit: BoxFit.cover,
                      height: Sizes.s22,
                      width: Sizes.s22)
                  : Image.asset(
                      data?.title == "All"
                          ? eImageAssets.all
                          : eImageAssets.noImageFound1,
                      fit: BoxFit.cover,
                      height: Sizes.s22,
                      width: Sizes.s22)),
      const VSpace(Sizes.s8),
      if (isExapnded)
        Text(data?.title ?? "",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: appCss.dmDenseRegular12.textColor(selectedIndex == index
                    ? appColor(context).primary
                    : appColor(context).darkText))
            .width(isCategories ? Sizes.s76 : Sizes.s60)
            .paddingDirectional(horizontal: Sizes.s5),
      if (!isExapnded)
        Text(data?.title ?? "",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: appCss.dmDenseRegular11.textColor(selectedIndex == index
                    ? appColor(context).primary
                    : appColor(context).darkText))
            .width(isCategories ? Sizes.s76 : Sizes.s60)
            .paddingDirectional(horizontal: Sizes.s5)
    ]).inkWell(onTap: onTap);
  }
}
