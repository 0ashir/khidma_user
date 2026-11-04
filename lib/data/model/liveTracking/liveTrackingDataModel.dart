class LiveTrackingDataModel {
  final int id;
  final int orderId;
  final double latitude;
  final double longitude;
  final String updatedAt;

  const LiveTrackingDataModel({
    required this.id,
    required this.orderId,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  factory LiveTrackingDataModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LiveTrackingDataModel(
      id: int.tryParse(data['id']?.toString() ?? '') ?? 0,
      orderId: int.tryParse(data['order_id']?.toString() ?? '') ?? 0,
      latitude: double.tryParse(data['latitude']?.toString() ?? '') ?? 0,
      longitude: double.tryParse(data['longitude']?.toString() ?? '') ?? 0,
      updatedAt: data['updated_at']?.toString() ?? '',
    );
  }
}
