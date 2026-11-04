class HandymanReviewModel {
  final String id;
  final String orderId;
  final String handymanId;
  final int rating;
  final String review;
  final List<String> images;

  const HandymanReviewModel({
    required this.id,
    required this.orderId,
    required this.handymanId,
    required this.rating,
    required this.review,
    required this.images,
  });

  factory HandymanReviewModel.fromJson(Map<String, dynamic> json) {
    return HandymanReviewModel(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      handymanId: json['handyman_id']?.toString() ?? '',
      rating: int.tryParse(json['rating']?.toString() ?? '') ?? 0,
      review: json['review']?.toString() ?? '',
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
