import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../app/generalImports.dart';

class MapUtils {
  // Update provider markers on map
  static List<AppMapMarker> updateProviderMarkers(
    List<Providers> providers,
    List<AppMapMarker> existingMarkers,
    ValueNotifier<int> selectedProviderIndex,
    CarouselSliderController providerCarouselController,
  ) {
    final providerMarkers = <AppMapMarker>[];
    for (int index = 0; index < providers.length; index++) {
      final provider = providers[index];
      final double? latitude = double.tryParse(provider.latitude ?? '');
      final double? longitude = double.tryParse(provider.longitude ?? '');
      if (latitude == null || longitude == null) continue;

      providerMarkers.add(
        AppMapMarker(
          id: "provider_${provider.id}",
          position: AppLatLng(latitude, longitude),
          googleIcon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          osmChild: const Icon(Icons.location_on, color: Colors.blue, size: 40),
          onTap: () {
            selectedProviderIndex.value = index;
            providerCarouselController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      );
    }

    final nonProviderMarkers = existingMarkers
        .where((marker) => !marker.id.startsWith("provider_"))
        .toList();

    return [...nonProviderMarkers, ...providerMarkers];
  }

  // Create address from coordinates
  static Future<Map<String, String>> createAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final List<Placemark> placeMark = await Geocoding()
          .placemarkFromCoordinates(latitude, longitude);
      final name = placeMark[0].name;
      final subLocality = placeMark[0].subLocality;
      final locality = placeMark[0].locality;
      final country = placeMark[0].country;
      final administrativeArea = placeMark[0].administrativeArea;
      final String? postalCode = placeMark[0].postalCode;

      String clean(final String? v) {
        final String t = (v ?? '').trim();
        // Plus codes ("8H54+C7P") and the literal "null" are not names.
        return (t.toLowerCase() == 'null' || t.contains('+')) ? '' : t;
      }

      // First usable value across all placemarks (the first one often lacks
      // the street or area that a later one has).
      String firstOf(final String? Function(Placemark) pick) {
        for (final Placemark p in placeMark) {
          final String v = clean(pick(p));
          if (v.isNotEmpty) return v;
        }
        return '';
      }

      final String city = firstOf(
        (p) =>
            (p.locality ?? '').isNotEmpty ? p.locality : p.administrativeArea,
      );
      String area = firstOf((p) => p.subLocality);
      if (area == city) area = '';

      return {
        // Structured parts for the address form (pin decides Area / City).
        "street": firstOf((p) => p.thoroughfare),
        "area": area,
        "city": city,
        "country": clean(country),
        "lineOneAddress": _filterAddressString(
          "$name,$subLocality,$locality,$country",
        ),
        "lineTwoAddress": _filterAddressString(
          "$postalCode,$locality,$administrativeArea",
        ),
        "selectedCity": locality ?? '',
      };
    } catch (e) {
      debugPrint("Error in createAddressFromCoordinates: $e");
      return {
        "lineOneAddress": '',
        "lineTwoAddress": '',
        "selectedCity": '',
        "street": '',
        "area": '',
        "city": '',
        "country": '',
      };
    }
  }

  // Helper method to filter address string
  static String _filterAddressString(String address) {
    return address
        .split(',')
        .where((part) => part.trim().isNotEmpty)
        .join(', ');
  }

  // Create location marker
  static AppMapMarker createLocationMarker(
    double latitude,
    double longitude, {
    bool isFromProviderMap = false,
    VoidCallback? onTap,
  }) {
    return AppMapMarker(
      id: "1",
      position: AppLatLng(latitude, longitude),
      googleIcon: BitmapDescriptor.defaultMarkerWithHue(
        isFromProviderMap ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed,
      ),
      osmChild: Icon(
        Icons.location_on,
        color: isFromProviderMap ? Colors.blue : Colors.red,
        size: 40,
      ),
      onTap: onTap,
    );
  }
}
