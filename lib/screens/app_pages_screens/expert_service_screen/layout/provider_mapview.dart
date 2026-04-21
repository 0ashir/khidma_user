
import '../../../../config.dart';
import 'map_bottom_layout.dart';

class ProviderMapView extends StatefulWidget {
  const ProviderMapView({super.key});

  @override
  State<ProviderMapView> createState() => _ProviderMapViewState();
}

class _ProviderMapViewState extends State<ProviderMapView> {
  GoogleMapController? mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MapBottomLayout(),
      isDismissible: false, // Prevent dismissing by tapping outside
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpertServiceProvider, DashboardProvider>(
        builder: (context, provider, dash, child) {
          return Scaffold(
              resizeToAvoidBottomInset:
              true, // Ensure the body resizes when the keyboard is visible
              body: Stack(children: [
                GoogleMap(
                    zoomGesturesEnabled: true,
                    myLocationButtonEnabled: true,
                    fortyFiveDegreeImageryEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(provider.lat?.toDouble() ?? 21.1981476,
                          provider.lng?.toDouble() ?? 72.7960464),
                      zoom: 15,
                    ),
                    markers: provider.selectedMarker != null
                        ? {provider.selectedMarker!}
                        : {},
/*markers: {
                      Marker(
                          markerId: const MarkerId('selected'),
                          position: LatLng(provider.lat?.toDouble() ?? 72.7960464,
                              provider.lng?.toDouble() ?? 72.7960464))
                    },*/
                    mapType: MapType.normal,
                    onMapCreated: _onMapCreated),
                Positioned(
                    bottom: MediaQuery.of(context).viewInsets.bottom / 50,
                    left: 0,
                    right: 0,
                    child: MapBottomLayout(mapController: mapController))
              ]));
        });
  }
}
