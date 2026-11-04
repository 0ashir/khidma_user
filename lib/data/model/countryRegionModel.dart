/// Bounding box (`boundary` in `get_countries` / `get_regions`). Language
/// independent, so used to detect the country/region of a coordinate.
class GeoBoundary {
  const GeoBoundary({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  /// Null when [json] is missing or any bound is not a number.
  static GeoBoundary? tryParse(final dynamic json) {
    if (json is! Map) return null;
    final double? minLat = double.tryParse('${json['min_lat']}');
    final double? maxLat = double.tryParse('${json['max_lat']}');
    final double? minLng = double.tryParse('${json['min_lng']}');
    final double? maxLng = double.tryParse('${json['max_lng']}');
    if (minLat == null || maxLat == null || minLng == null || maxLng == null) {
      return null;
    }
    return GeoBoundary(
      minLat: minLat,
      maxLat: maxLat,
      minLng: minLng,
      maxLng: maxLng,
    );
  }

  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  double get area => (maxLat - minLat) * (maxLng - minLng);

  bool contains(final double lat, final double lng) =>
      lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
}

/// Picks the item whose boundary contains the point. Boxes can overlap, so the
/// smallest (most specific) one wins.
T? findByBoundary<T>(
  final List<T> items,
  final double lat,
  final double lng,
  final GeoBoundary? Function(T) boundaryOf,
) {
  T? best;
  double bestArea = double.infinity;
  for (final T item in items) {
    final GeoBoundary? b = boundaryOf(item);
    if (b == null || !b.contains(lat, lng) || b.area >= bestArea) continue;
    best = item;
    bestArea = b.area;
  }
  return best;
}

/// Active country from `get_countries`. Names follow the `Content-Language`
/// header; [flag] is an empty string when the country has no flag image.
class Country {
  Country({
    required this.id,
    required this.name,
    this.flag = '',
    this.boundary,
  });

  Country.fromJson(final Map<String, dynamic> json)
    : id = json['id']?.toString() ?? '',
      name = json['name']?.toString() ?? '',
      flag = json['flag']?.toString() ?? '',
      boundary = GeoBoundary.tryParse(json['boundary']);

  final String id;
  final String name;
  final String flag;
  final GeoBoundary? boundary;
}

/// Region (state/province) of a [Country], from `get_regions`.
class Region {
  Region({required this.id, required this.name, this.boundary});

  Region.fromJson(final Map<String, dynamic> json)
    : id = json['id']?.toString() ?? '',
      name = json['name']?.toString() ?? '',
      boundary = GeoBoundary.tryParse(json['boundary']);

  final String id;
  final String name;
  final GeoBoundary? boundary;
}
