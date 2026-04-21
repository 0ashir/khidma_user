import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../../../config.dart';

class MapBottomLayout extends StatelessWidget {
  final GoogleMapController? mapController;

  const MapBottomLayout({super.key, this.mapController});

  @override
  Widget build(BuildContext context) {
    final dash = Provider.of<DashboardProvider>(context, listen: true);
    return Consumer<ExpertServiceProvider>(builder: (context1, value, child) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
                height: Sizes.s200,
                child: Column(children: [
                  SearchTextFieldCommon(
                          controller: value.txtFeaturedSearch,
                          focusNode: value.searchFocus,
                          onChanged: (v) {
                            if (v.isEmpty) {
                              value.searchFocus.unfocus();
                              value.getFeaturedPackage();
                            } else if (v.length > 3) {
                              value.getFeaturedPackage();
                            }
                          },
                          suffixIcon: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (value.txtFeaturedSearch.text.isNotEmpty)
                                  Icon(Icons.cancel,
                                          color: appColor(context).darkText)
                                      .inkWell(onTap: () {
                                    value.txtFeaturedSearch.text = "";
                                    value.searchFocus.unfocus();
                                    value.notifyListeners();
                                    value.getFeaturedPackage();
                                  })
                              ]).paddingSymmetric(horizontal: Insets.i20),
                          onFieldSubmitted: (v) => value.getFeaturedPackage())
                      .paddingSymmetric(horizontal: 20, vertical: 20),
                  Expanded(
                      child: value.txtFeaturedSearch.text.isEmpty
                          ? FutureBuilder(
                              future: value.fetchData(context),
                              initialData: dash.highestRateList,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting &&
                                    snapshot.data!.isEmpty) {
                                  return const ExpertServiceShimmer(count: 5);
                                } else if (snapshot.error != null) {
                                  return const ExpertServiceShimmer(count: 5);
                                } else {
                                  return ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: Insets.i20),
                                      itemCount: dash.highestRateList.length,
                                      itemBuilder: (context, index) {
                                        final e = dash.highestRateList[index];
                                        return Column(children: [
                                          Row(children: [
                                            e.media != null &&
                                                    e.media!.isNotEmpty
                                                ? CommonImageLayout(
                                                        height: Sizes.s36,
                                                        width: Sizes.s36,
                                                        radius: 8,
                                                        image: e.media![0]
                                                            .originalUrl!,
                                                        assetImage: eImageAssets
                                                            .noImageFound3)
                                                    .boxShapeExtension()
                                                : CommonCachedImage(
                                                    image: eImageAssets
                                                        .noImageFound3,
                                                    assetImage: eImageAssets
                                                        .noImageFound3,
                                                    height: Sizes.s36,
                                                    width: Sizes.s36),
                                            const HSpace(Sizes.s10),
                                            Text(
                                                capitalizeFirstLetter(
                                                    e.name ?? "Provider"),
                                                style: appCss.dmDenseSemiBold15
                                                    .textColor(appColor(context)
                                                        .darkText)),
                                            const Spacer(),
                                            Row(children: [
                                              SvgPicture.asset(eSvgAssets.star),
                                              const HSpace(Sizes.s3),
                                              Text(
                                                  e.reviewRatings != null
                                                      ? e.reviewRatings!
                                                          .toStringAsFixed(1)
                                                      : "0",
                                                  style: appCss
                                                      .dmDenseSemiBold13
                                                      .textColor(
                                                          appColor(context)
                                                              .darkText))
                                            ])
                                          ]).inkWell(onTap: () async {
                                            final lat = e
                                                    .locationCordinates?.lat
                                                    ?.toDouble() ??
                                                0.0;
                                            final lng = e
                                                    .locationCordinates?.lng
                                                    ?.toDouble() ??
                                                0.0;

                                            final String imagePath = (e.media !=
                                                        null &&
                                                    e.media!.isNotEmpty &&
                                                    e.media![0].originalUrl!
                                                        .isNotEmpty)
                                                ? e.media![0].originalUrl!
                                                : eImageAssets.noImageFound3;

                                            final BitmapDescriptor customIcon =
                                                await createCustomMarker(
                                                    imagePath, context,
                                                    size: 100);

                                            value.setSelectedMarker(Marker(
                                                infoWindow: InfoWindow(
                                                    title: e.name ??
                                                        translations!.provider,
                                                    snippet:
                                                        "Tap for more info",
                                                    onTap: () {
                                                      Provider.of<ProviderDetailsProvider>(
                                                              context,
                                                              listen: false)
                                                          .getProviderById(
                                                              context, e.id);
                                                      route.pushNamed(
                                                          context,
                                                          routeName
                                                              .providerDetailsScreen,
                                                          arg: {
                                                            'providerId': e.id
                                                          });
                                                    }),
                                                markerId:
                                                    const MarkerId('selected'),
                                                position: LatLng(lat, lng),
                                                icon: customIcon));

                                            value.lat = lat;
                                            value.lng = lng;
                                            value.notifyListeners();

                                            if (mapController != null) {
                                              mapController!.animateCamera(
                                                  CameraUpdate
                                                      .newCameraPosition(
                                                          CameraPosition(
                                                              target: LatLng(
                                                                  lat, lng),
                                                              zoom: 15,
                                                              tilt: 45,
                                                              bearing: 90)));
                                            }
                                          }),
                                          Image.asset(eImageAssets.dotLine)
                                              .padding(vertical: Sizes.s8)
                                        ]);
                                      });
                                }
                              })
                          : value.searchList.isNotEmpty
                              ? ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: Insets.i20),
                                  itemCount: value.searchList.length,
                                  itemBuilder: (context, index) {
                                    final e = value.searchList[index];
                                    return ExpertServiceLayout(
                                        data: e,
                                        isHome: true,
                                        onTap: () {
                                          Provider.of<ProviderDetailsProvider>(
                                                  context,
                                                  listen: false)
                                              .getProviderById(context, e.id);

                                          route.pushNamed(context,
                                              routeName.providerDetailsScreen,
                                              arg: {'providerId': e.id});
                                        });
                                  })
                              : Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                      Text(
                                          language(context,
                                              translations!.noMatching),
                                          style: appCss.dmDenseBold18.textColor(
                                              appColor(context).darkText)),
                                      const VSpace(Sizes.s8),
                                      Text(
                                              language(
                                                  context,
                                                  translations!
                                                      .attemptYourSearch),
                                              textAlign: TextAlign.center,
                                              style: appCss.dmDenseRegular14
                                                  .textColor(appColor(context)
                                                      .lightText))
                                          .paddingSymmetric(
                                              horizontal: Insets.i10)
                                    ])))
                ]).bottomSheetExtension(context))
          ]);
    });
  }
}

Future<BitmapDescriptor> createCustomMarker(String imagePath, context,
    {int size = 50}) async {
  try {
    Uint8List imageBytes;

    if (imagePath.startsWith('http')) {
      // Load from network
      final http.Response response = await http.get(Uri.parse(imagePath));
      imageBytes = response.bodyBytes;
    } else {
      final ByteData byteData = await rootBundle.load(imagePath);
      imageBytes = byteData.buffer.asUint8List();
    }

    final ui.Codec profileCodec =
        await ui.instantiateImageCodec(imageBytes, targetWidth: size);
    final ui.FrameInfo profileFrame = await profileCodec.getNextFrame();

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final Paint paint = Paint();

    // Draw marker shape
    final double markerWidth = size.toDouble();
    final double markerHeight = size * 1.4;

    paint.color = appColor(context).primary;
    final Path markerPath = Path();
    markerPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, markerWidth, markerWidth),
      const Radius.circular(100),
    ));
    final double arrowInset = markerWidth * 0.25;

    markerPath.moveTo(markerWidth / 2, markerWidth * 1.4);
    markerPath.lineTo(arrowInset, markerWidth);
    markerPath.lineTo(markerWidth - arrowInset, markerWidth);
    markerPath.close();

    canvas.drawPath(markerPath, paint);

    // Clip circle for profile
    final double imageRadius = markerWidth / 2.2;
    final Offset center = Offset(markerWidth / 2, markerWidth / 2);
    canvas.save();
    canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: imageRadius)));
    canvas.drawImage(
        profileFrame.image,
        Offset((markerWidth - profileFrame.image.width) / 2,
            (markerWidth - profileFrame.image.height) / 2),
        Paint());
    canvas.restore();

    final ui.Image finalImage = await recorder
        .endRecording()
        .toImage(markerWidth.toInt(), markerHeight.toInt());
    final ByteData? pngBytes =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(pngBytes!.buffer.asUint8List());
  } catch (e) {
    return BitmapDescriptor.defaultMarker;
  }
}
