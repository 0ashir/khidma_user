import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class MiniMapWidget extends StatefulWidget {
  const MiniMapWidget({
    super.key,
    required this.orderId,
    required this.handymanLat,
    required this.handymanLng,
    this.orderLat,
    this.orderLng,
  });

  final String orderId;
  final double handymanLat;
  final double handymanLng;
  final double? orderLat;
  final double? orderLng;

  @override
  State<MiniMapWidget> createState() => _MiniMapWidgetState();
}

class _MiniMapWidgetState extends State<MiniMapWidget> {
  BitmapDescriptor? _handymanIcon;
  BitmapDescriptor? _orderIcon;
  bool _iconsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_iconsLoaded) {
      _iconsLoaded = true;
      _loadIcons();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadIcons() async {
    final results = await Future.wait([
      _svgToMarker(AppAssets.handyman, size: 36),
      _svgToMarker(AppAssets.customerPin, size: 36),
    ]);
    if (!mounted) return;
    setState(() {
      _handymanIcon = results[0];
      _orderIcon = results[1];
    });
  }

  Future<BitmapDescriptor> _svgToMarker(
    String assetPath, {
    double size = 36,
  }) async {
    final accentColor = context.colors.textBrand;
    final data = await rootBundle.load(assetPath);
    final loader = SvgStringLoader(utf8.decode(data.buffer.asUint8List()));
    final pictureInfo = await vg.loadPicture(loader, null);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.scale(size / pictureInfo.size.width, size / pictureInfo.size.height);
    canvas.drawPicture(pictureInfo.picture);
    canvas.drawColor(accentColor, BlendMode.srcATop);
    pictureInfo.picture.dispose();
    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  static Widget _flightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          color: fromHeroContext.colors.surfaceElevated,
          borderRadius: BorderRadius.lerp(
            BorderRadius.circular(12),
            BorderRadius.zero,
            direction == HeroFlightDirection.push
                ? animation.value
                : 1 - animation.value,
          ),
        ),
      ),
    );
  }

  Widget _svgMarkerChild(String assetPath) => SvgPicture.asset(
    assetPath,
    height: 36,
    width: 36,
    colorFilter: ColorFilter.mode(
      context.colors.textBrand,
      BlendMode.srcIn,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final handymanPos = AppLatLng(widget.handymanLat, widget.handymanLng);
    final hasOrder = widget.orderLat != null && widget.orderLng != null;
    final orderPos = hasOrder
        ? AppLatLng(widget.orderLat!, widget.orderLng!)
        : null;

    final initialCenter = hasOrder
        ? AppLatLng(
            (handymanPos.latitude + orderPos!.latitude) / 2,
            (handymanPos.longitude + orderPos.longitude) / 2,
          )
        : handymanPos;
    final initialZoom = hasOrder ? 12.0 : 14.0;

    final markers = [
      AppMapMarker(
        id: 'mini_handyman',
        position: handymanPos,
        anchor: const Offset(0.5, 0.5),
        googleIcon:
            _handymanIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        osmChild: _svgMarkerChild(AppAssets.handyman),
      ),
      if (orderPos != null)
        AppMapMarker(
          id: 'mini_order',
          position: orderPos,
          googleIcon:
              _orderIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          osmChild: _svgMarkerChild(AppAssets.customerPin),
        ),
    ];

    final polylines = orderPos != null
        ? [
            AppMapPolyline(
              id: 'mini_track',
              points: [handymanPos, orderPos],
              color: Colors.blue,
              width: 3,
            ),
          ]
        : <AppMapPolyline>[];

    return Hero(
      tag: 'live-tracking-map-${widget.orderId}',
      flightShuttleBuilder: _flightShuttle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 180,
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: AppMapView(
                    liteMode: true,
                    initialCenter: initialCenter,
                    initialZoom: initialZoom,
                    markers: markers,
                    polylines: polylines,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                  ),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pushNamed(
                    context,
                    liveTrackingRoute,
                    arguments: {
                      'orderId': widget.orderId,
                      'orderLat': widget.orderLat,
                      'orderLng': widget.orderLng,
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
