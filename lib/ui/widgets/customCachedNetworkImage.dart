import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  const CustomCachedNetworkImage({
    required this.networkImageUrl,
    final Key? key,
    this.width,
    this.height,
    this.fit,
    this.isFile,
    this.defaultColourFilter = true,
    this.avoideResponsive = false,
    this.avoidImageCache = true,
  }) : super(key: key);
  final String networkImageUrl;
  final double? width, height;
  final BoxFit? fit;
  final bool? isFile;
  final bool defaultColourFilter;
  final bool avoideResponsive;
  final bool avoidImageCache;
  @override
  Widget build(final BuildContext context) {
    if (networkImageUrl.startsWith('assets/')) {
      return CustomSvgPicture(
        svgImage: networkImageUrl,
        width: width,
        height: height,
        avoideResponsive: avoideResponsive,
        boxFit: fit ?? BoxFit.contain,
      );
    }
    return networkImageUrl.endsWith('.svg')
        ? SvgPicture.network(
            networkImageUrl,
            fit: fit ?? BoxFit.fill,
            width: avoideResponsive ? width : width?.rs(context),
            height: avoideResponsive ? height : height?.rs(context),
            colorFilter: defaultColourFilter
                ? ColorFilter.mode(context.colors.textBrand, BlendMode.srcIn)
                : null,
            placeholderBuilder: (final BuildContext context) => Center(
              child: CustomSvgPicture(
                avoideResponsive: avoideResponsive,
                svgImage: AppAssets.placeHolder,
                width: width,
                height: height,
                boxFit: BoxFit.contain,
              ),
            ),
          )
        : CachedNetworkImage(
            imageUrl: networkImageUrl,
            imageBuilder: (context, imageProvider) {
              return CustomContainer(
                avoideResponsive: avoideResponsive,
                height: height,
                width: width,
                image: DecorationImage(
                  image: imageProvider,
                  fit: fit ?? BoxFit.contain,
                ),
              );
            },
            maxWidthDiskCache: avoidImageCache ? 500 : null,
            maxHeightDiskCache: avoidImageCache ? 500 : null,
            memCacheWidth: avoidImageCache ? 150 : null,
            memCacheHeight: avoidImageCache ? 150 : null,
            fit: fit ?? BoxFit.contain,
            errorWidget: (BuildContext context, String url, final error) =>
                Center(
                  child: Center(
                    child: CustomSvgPicture(
                      avoideResponsive: avoideResponsive,
                      svgImage: AppAssets.noImageFound,
                      width: width,
                      height: height,
                      boxFit: BoxFit.contain,
                    ),
                  ),
                ),
            placeholder: (final BuildContext context, final String url) =>
                Center(
                  child: CustomSvgPicture(
                    avoideResponsive: avoideResponsive,
                    svgImage: AppAssets.placeHolder,
                    width: width,
                    height: height,
                    boxFit: BoxFit.cover,
                  ),
                ),
          );
  }
}
