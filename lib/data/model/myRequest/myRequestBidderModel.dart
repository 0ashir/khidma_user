import 'bidProviderModel.dart';

class CustomJob {
  String? id;
  String? orderId;
  String? title;
  String? description;
  String? categoryName;
  String? status;
  String? startDateTime;
  String? endDateTime;
  String? phone;
  String? countryCode;
  Attachments? attachments;
  String? cancelReasonId;
  String? cancelReason;
  String? cancelAdditionalInfo;
  BidProvider? bidDetails;

  CustomJob({
    this.id,
    this.orderId,
    this.title,
    this.description,
    this.categoryName,
    this.status,
    this.startDateTime,
    this.endDateTime,
    this.phone,
    this.countryCode,
    this.attachments,
    this.cancelReasonId,
    this.cancelReason,
    this.cancelAdditionalInfo,
    this.bidDetails,
  });

  CustomJob.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? '';
    orderId = json['order_id']?.toString() ?? '';
    title = json['title']?.toString() ?? '';
    description = json['description']?.toString() ?? '';
    categoryName = json['category_name']?.toString() ?? '';
    status = json['status']?.toString() ?? '';
    startDateTime = json['start_date_time']?.toString() ?? '';
    endDateTime = json['end_date_time']?.toString() ?? '';
    phone = json['phone']?.toString() ?? '';
    countryCode = json['country_code']?.toString() ?? '';
    attachments = Attachments.fromJson(
      json['attachments'] is Map
          ? Map<String, dynamic>.from(json['attachments'])
          : {},
    );
    final cancellation = json['cancellation'];
    cancelReasonId = cancellation is Map
        ? cancellation['cancel_reason_id']?.toString() ?? ''
        : '';
    cancelReason = cancellation is Map
        ? cancellation['reason']?.toString() ?? ''
        : '';
    cancelAdditionalInfo = cancellation is Map
        ? cancellation['additional_info']?.toString() ?? ''
        : '';
    bidDetails = json['bid_details'] is Map
        ? BidProvider.fromJson(Map<String, dynamic>.from(json['bid_details']))
        : null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_id': orderId,
    'title': title,
    'description': description,
    'category_name': categoryName,
    'status': status,
    'start_date_time': startDateTime,
    'end_date_time': endDateTime,
    'phone': phone,
    'country_code': countryCode,
    'attachments': attachments?.toJson(),
    'cancellation': {
      'cancel_reason_id': cancelReasonId,
      'reason': cancelReason,
      'additional_info': cancelAdditionalInfo,
    },
  };
}

class Attachments {
  List<String> images;
  List<String> videos;
  List<String> others;

  Attachments({
    this.images = const [],
    this.videos = const [],
    this.others = const [],
  });

  Attachments.fromJson(Map<String, dynamic> json)
    : images = _stringList(json['images']),
      videos = _stringList(json['videos']),
      others = _stringList(json['others']);

  static List<String> _stringList(final dynamic value) => value is List
      ? value.map((final e) => e.toString()).toList()
      : <String>[];

  Map<String, dynamic> toJson() => {
    'images': images,
    'videos': videos,
    'others': others,
  };
}
