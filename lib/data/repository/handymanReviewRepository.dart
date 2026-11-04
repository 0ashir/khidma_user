import 'package:dio/dio.dart';
import 'package:e_demand/app/generalImports.dart';
import 'package:path/path.dart' as p;

class HandymanReviewRepository {
  Future<Map<String, dynamic>> saveHandymanReview({
    String? ratingId,
    required String orderId,
    required String handymanId,
    required String rating,
    required String review,
    List<XFile?>? reviewImages,
    List<String>? deletedPastReviewImages,
  }) async {
    try {
      final parameter = <String, dynamic>{
        if (ratingId != null && ratingId.isNotEmpty) ApiParam.id: ratingId,
        ApiParam.orderId: orderId,
        ApiParam.handymanId: handymanId,
        ApiParam.rating: rating,
        ApiParam.review: review,
        if (deletedPastReviewImages != null &&
            deletedPastReviewImages.isNotEmpty)
          ApiParam.imagesToDelete: deletedPastReviewImages,
      };

      if (reviewImages != null) {
        for (int i = 0; i < reviewImages.length; i++) {
          final XFile? element = reviewImages[i];
          final mimeType = lookupMimeType(element!.path);
          final extension = mimeType!.split("/");

          final imagePart = await MultipartFile.fromFile(
            element.path,
            filename: p.basename(element.path),
            contentType: MediaType('image', extension[1]),
          );
          parameter["images[$i]"] = imagePart;
        }
      }

      final response = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.saveHandymanReview,
        useAuthToken: true,
      );
      if (response['error'] == true) {
        return {"error": response['error'], "message": response['message']};
      }
      return {
        "error": response['error'],
        "message": response['message'],
        "data": response["data"],
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteHandymanReview({required String ratingId}) async {
    try {
      final response = await ApiClient.post(
        parameter: {ApiParam.id: ratingId},
        url: ApiUrl.deleteHandymanReview,
        useAuthToken: true,
      );
      if (response['error'] == true) {
        throw ApiException(response['message']?.toString() ?? 'deleteFailed');
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
