import '../../../config.dart';

class CurrentLocationScreen extends StatelessWidget {
  const CurrentLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(builder: (context1, value, child) {
      return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            if (didPop) return;
            value.onBackMap(context);
          },
          child: StatefulWrapper(
              onInit: () => Future.delayed(DurationClass.ms50)
                  .then((value1) => value.onLocationInit(context)),
              child: Scaffold(
                  body: Stack(children: [
                GoogleMap(
                    onTap: (LatLng tappedPoint) {
                      value.newLat = tappedPoint.latitude;
                      value.newLog = tappedPoint.longitude;
                      position = tappedPoint;
                      value.getAddressFromLatLng(context);
                    },
                    zoomGesturesEnabled: true,
                    myLocationButtonEnabled: true,
                    fortyFiveDegreeImageryEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    initialCameraPosition: CameraPosition(
                        target: value.position1 == null
                            ? const LatLng(0.0, 0.0)
                            : LatLng(value.position1!.latitude,
                                value.position1!.longitude),
                        zoom: 15),
                    markers: value.markers,
                    mapType: MapType.normal,
                    onMapCreated: (controller) =>
                        value.onController(controller)),
                const BottomLocationLayout()
              ]))));
    });
  }
}
