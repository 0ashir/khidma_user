import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({
    super.key,
    required this.orderId,
    this.orderLat,
    this.orderLng,
  });

  final String orderId;
  final double? orderLat;
  final double? orderLng;

  static Route route(RouteSettings settings) {
    final args = settings.arguments as Map;
    final String orderId = args['orderId'] as String;
    final double? orderLat = args['orderLat'] as double?;
    final double? orderLng = args['orderLng'] as double?;

    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => GetLiveTrackingDataCubit(),
        child: LiveTrackingScreen(
          orderId: orderId,
          orderLat: orderLat,
          orderLng: orderLng,
        ),
      ),
    );
  }

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  AppMapController? _mapController;
  List<AppMapMarker> _markers = [];
  List<AppMapPolyline> _polylines = [];
  GetLiveTrackingDataCubit? _cubit;
  bool _iconsLoaded = false;

  BitmapDescriptor? _providerIcon;
  BitmapDescriptor? _orderIcon;

  bool get _hasOrderPosition =>
      widget.orderLat != null && widget.orderLng != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_iconsLoaded) {
      _iconsLoaded = true;
      _loadMarkerIcons();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit = context.read<GetLiveTrackingDataCubit>();
      _cubit!.startPolling(orderId: widget.orderId);
      _cubit!.onTransientError = () {
        if (!context.mounted) return;
        UiUtils.showMessage(
          context,
          'locationUpdateFailed'.translate(context: context),
          ToastificationType.warning,
        );
      };
    });
  }

  Future<void> _loadMarkerIcons() async {
    final results = await Future.wait([
      _svgToMarker(AppAssets.customerPin, size: 48),
      _svgToMarker(AppAssets.handyman, size: 48),
    ]);
    if (!mounted) return;
    setState(() {
      _orderIcon = results[0];
      _providerIcon = results[1];
    });
  }

  Future<BitmapDescriptor> _svgToMarker(
    String assetPath, {
    double size = 48,
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

  @override
  void dispose() {
    _cubit?.onTransientError = null;
    _cubit?.stopPolling();
    _mapController?.dispose();
    super.dispose();
  }

  Widget _svgMarkerChild(String assetPath) => SvgPicture.asset(
    assetPath,
    height: 48,
    width: 48,
    colorFilter: ColorFilter.mode(
      context.colors.textBrand,
      BlendMode.srcIn,
    ),
  );

  void _updateMap(LiveTrackingDataModel data) {
    final providerPos = AppLatLng(data.latitude, data.longitude);

    if (_hasOrderPosition) {
      final orderPos = AppLatLng(widget.orderLat!, widget.orderLng!);
      final markers = [
        AppMapMarker(
          id: 'order_location',
          position: orderPos,
          googleIcon:
              _orderIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          osmChild: _svgMarkerChild(AppAssets.customerPin),
          infoWindowTitle: 'serviceLocation'.translate(context: context),
        ),
        AppMapMarker(
          id: 'provider_location',
          position: providerPos,
          anchor: const Offset(0.5, 0.5),
          googleIcon:
              _providerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          osmChild: _svgMarkerChild(AppAssets.handyman),
          infoWindowTitle: 'providerLocation'.translate(context: context),
        ),
      ];

      final polylines = [
        AppMapPolyline(
          id: 'tracking_line',
          points: [providerPos, orderPos],
          color: Colors.blue,
          width: 4,
        ),
      ];

      _mapController?.fitBounds(providerPos, orderPos);

      setState(() {
        _markers = markers;
        _polylines = polylines;
      });
    } else {
      setState(() {
        _markers = [
          AppMapMarker(
            id: 'provider_location',
            position: providerPos,
            anchor: const Offset(0.5, 0.5),
            googleIcon:
                _providerIcon ??
                BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange,
                ),
            osmChild: _svgMarkerChild(AppAssets.handyman),
            infoWindowTitle: 'providerLocation'.translate(context: context),
          ),
        ];
        _polylines = [];
      });
      _mapController?.animateTo(providerPos, zoom: 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.colors.backgroundSecondary,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'liveTracking'.translate(context: context),
        ),
        body: Hero(
          tag: 'live-tracking-map-${widget.orderId}',
          flightShuttleBuilder: (_, animation, direction, fromCtx, __) =>
              AnimatedBuilder(
                animation: animation,
                builder: (ctx, _) => Container(
                  decoration: BoxDecoration(
                    color: fromCtx.colors.surfaceElevated,
                    borderRadius: BorderRadius.lerp(
                      BorderRadius.circular(12),
                      BorderRadius.zero,
                      direction == HeroFlightDirection.push
                          ? animation.value
                          : 1 - animation.value,
                    ),
                  ),
                ),
              ),
          child: _buildMap(),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return BlocConsumer<GetLiveTrackingDataCubit, GetLiveTrackingDataState>(
      listener: (context, state) {
        if (state is GetLiveTrackingDataSuccess) {
          _updateMap(state.data);
        }
      },
      builder: (context, state) {
        if (state is GetLiveTrackingDataFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: state.errorMessage.translate(context: context),
              onTapRetry: () => context
                  .read<GetLiveTrackingDataCubit>()
                  .startPolling(orderId: widget.orderId),
            ),
          );
        }

        final LiveTrackingDataModel? data = state is GetLiveTrackingDataSuccess
            ? state.data
            : null;

        final initialCenter = data != null
            ? AppLatLng(data.latitude, data.longitude)
            : _hasOrderPosition
            ? AppLatLng(widget.orderLat!, widget.orderLng!)
            : const AppLatLng(0, 0);
        final initialZoom = data != null || _hasOrderPosition ? 14.0 : 2.0;

        return Stack(
          children: [
            AppMapView(
              initialCenter: initialCenter,
              initialZoom: initialZoom,
              markers: _markers,
              polylines: _polylines,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              onMapReady: (controller) {
                _mapController = controller;
                if (data != null) _updateMap(data);
              },
            ),
            if (state is GetLiveTrackingDataLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        );
      },
    );
  }
}
