class MyRequestListModel {
  String? id;
  String? title;
  String? description;
  String? categoryName;
  String? minPrice;
  String? maxPrice;
  String? status;
  int? totalBids;
  List<MyRequestBidderSummary>? bidders;

  MyRequestListModel({
    this.id,
    this.title,
    this.description,
    this.categoryName,
    this.minPrice,
    this.maxPrice,
    this.status,
    this.totalBids,
    this.bidders,
  });

  MyRequestListModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? '';
    title = json['title']?.toString() ?? '';
    description = json['description']?.toString() ?? '';
    categoryName = json['category_name']?.toString() ?? '';
    minPrice = json['min_price']?.toString() ?? '';
    maxPrice = json['max_price']?.toString() ?? '';
    status = json['status']?.toString() ?? '';
    totalBids = int.tryParse(json['total_bids']?.toString() ?? '') ?? 0;
    if (json['bidders'] is List) {
      bidders = (json['bidders'] as List)
          .map(
            (final e) =>
                MyRequestBidderSummary.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category_name': categoryName,
    'min_price': minPrice,
    'max_price': maxPrice,
    'status': status,
    'total_bids': totalBids,
    'bidders': bidders?.map((final b) => b.toJson()).toList(),
  };
}

class MyRequestBidderSummary {
  String? id;
  String? profileImage;
  String? slug;
  String? companyName;
  int? postBookingChat;
  int? isVerified;

  MyRequestBidderSummary({
    this.id,
    this.profileImage,
    this.slug,
    this.companyName,
    this.postBookingChat,
    this.isVerified,
  });

  MyRequestBidderSummary.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? '';
    profileImage = json['profile_image']?.toString() ?? '';
    slug = json['slug']?.toString();
    companyName = json['company_name']?.toString();
    postBookingChat = int.tryParse(json['post_booking_chat']?.toString() ?? '');
    isVerified = int.tryParse(json['is_verified']?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'profile_image': profileImage,
    if (slug != null) 'slug': slug,
    if (companyName != null) 'company_name': companyName,
    if (postBookingChat != null) 'post_booking_chat': postBookingChat,
    if (isVerified != null) 'is_verified': isVerified,
  };
}
