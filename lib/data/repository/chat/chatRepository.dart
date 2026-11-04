import 'package:dio/dio.dart';
import 'package:e_demand/data/model/chat/blockUserList.dart';
import 'package:e_demand/data/model/chat/reportReasonModel.dart';

import 'package:path/path.dart' as p;

import '../../../app/generalImports.dart';

class ChatRepository {
  String getChatType(String value) {
    final Map<String, String> mapping = {
      'enquiryChats': ApiParam.preBookingChats,
      'bookingChats': ApiParam.bookingChats,
    };

    return mapping[value] ?? 'Unknown';
  }

  Future<Map<String, dynamic>> fetchChatUsers({
    required int offset,
    String? searchString,
    required String filterType,
  }) async {
    try {
      final response = await ApiClient.post(
        url: ApiUrl.getChatUsers,
        useAuthToken: true,
        parameter: {
          ApiParam.offset: offset.toString(),
          ApiParam.limit: UiUtils.chatLimit.toString(),
          ApiParam.filterType: getChatType(filterType),
          if (searchString != null) ApiParam.search: searchString.trim(),
        },
      );

      final List<ChatUser> chatUsers = [];

      for (int i = 0; i < response['data'].length; i++) {
        chatUsers.add(ChatUser.fromJson(response['data'][i]));
      }

      return {
        "chatUsers": chatUsers,
        "totalItems": int.tryParse((response['total'] ?? "1").toString()),
        "totalUnreadUsers":
            int.tryParse(response['total_unread_users']?.toString() ?? "0") ??
            0,
      };
    } catch (error) {
      if (kDebugMode) {}
      throw ApiException(error.toString());
    }
  }

  Future<Map<String, dynamic>> fetchChatMessages({
    required int offset,
    String? bookingId,
    String? providerId,
    bool toAdmin = false,
  }) async {
    try {
      final Map<String, dynamic> parameter = {
        ApiParam.offset: offset.toString(),
        ApiParam.limit: UiUtils.chatLimit.toString(),
        ApiParam.bookingId: ?bookingId,
        ApiParam.type: toAdmin ? '0' : '1',
        if (!toAdmin) ApiParam.providerId: ?providerId,
      };

      final response = await ApiClient.post(
        url: ApiUrl.getChatMessages,
        useAuthToken: true,
        parameter: parameter,
      );

      final List<ChatMessage> chatMessage = [];

      for (int i = 0; i < response['data'].length; i++) {
        chatMessage.add(ChatMessage.fromJson(response['data'][i]));
      }

      final handymanJson = response['handyman_details'];
      final ChatParticipant? handyman =
          (handymanJson is Map && handymanJson.isNotEmpty)
          ? ChatParticipant.fromJson(Map<String, dynamic>.from(handymanJson))
          : null;

      final List<ChatParticipant> bookingServices =
          ((response['services'] as List?) ?? [])
              .map(
                (final v) =>
                    ChatParticipant.fromService(Map<String, dynamic>.from(v)),
              )
              .toList();

      return {
        "chatMessages": chatMessage,
        "totalItems": int.tryParse((response['total'] ?? "0").toString()),
        "isBlockedByUser": response['is_block_by_user'].toString() == "1",
        "isBlockedByProvider":
            response['is_block_by_provider'].toString() == "1",
        "handyman": handyman,
        "bookingServices": bookingServices,
        "bookingStartDate": response['booking_start_date']?.toString() ?? '',
        "bookingStartTime": response['booking_start_time']?.toString() ?? '',
        "bookingStatus": response['booking_status']?.toString() ?? '',
      };
    } catch (error) {
      if (kDebugMode) {}
      throw ApiException(error.toString());
    }
  }

  Future<void> markMessageAsRead({
    String? bookingId,
    String? providerId,
    bool toAdmin = false,
  }) async {
    try {
      final Map<String, dynamic> parameter = {
        ApiParam.bookingId: ?bookingId,
        ApiParam.type: toAdmin ? '0' : '1',
        if (!toAdmin) ApiParam.providerId: ?providerId,
      };
      await ApiClient.post(
        url: ApiUrl.markMessageAsRead,
        useAuthToken: true,
        parameter: parameter,
      );
    } catch (error) {
      throw ApiException(error.toString());
    }
  }

  Future<ChatMessage> sendChatMessage({
    required String message,
    List<String> filePaths = const [],
    String? receiverId,
    String? bookingId,
    bool toAdmin = false,
  }) async {
    try {
      ///0: Admin 1: Provider
      final Map<String, dynamic> parameter = {
        if (!toAdmin) ApiParam.receiverId: ?receiverId,
        ApiParam.message: message,
        ApiParam.receiverType: toAdmin ? '0' : '1',
        ApiParam.type: toAdmin ? '0' : '1',
        ApiParam.bookingId: ?bookingId,
      };
      if (message.isEmpty) {
        parameter.remove(ApiParam.message);
      }
      if (filePaths.isNotEmpty) {
        for (int i = 0; i < filePaths.length; i++) {
          final mimeType = lookupMimeType(filePaths[i]);
          final extension = mimeType!.split("/");

          final imagePart = await MultipartFile.fromFile(
            filePaths[i],
            filename: p.basename(filePaths[i]),
            contentType: MediaType(extension[0], extension[1]),
          );
          parameter["attachment[$i]"] = imagePart;
        }
      }

      final response = await ApiClient.post(
        url: ApiUrl.sendChatMessage,
        parameter: parameter,
        useAuthToken: true,
      );

      return ChatMessage.fromJson(response['data']);
    } catch (e) {
      throw ApiException("somethingWentWrong");
    }
  }

  Future<String> blockUserWitReport({
    required String reasonId,
    required String additionalInfo,
    required String providerId,
  }) async {
    try {
      final Map<String, dynamic> parameter = {
        ApiParam.partnerId: providerId,
        ApiParam.reasonId: reasonId,
        ApiParam.additionalInfo: additionalInfo,
      };
      parameter.removeWhere(
        (key, value) => value == "null" || value == null || value == '',
      );
      final response = await ApiClient.post(
        url: ApiUrl.blockUser,
        parameter: parameter,
        useAuthToken: true,
      );

      return response['message'] as String;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<ReportReasonModel>> getReportReasons() async {
    try {
      final response = await ApiClient.get(
        url: ApiUrl.getReportReasons,
        useAuthToken: true,
      );
      if (response['data'].isEmpty) {
        return [];
      }
      return (response['data'] as List<dynamic>)
          .map((e) => ReportReasonModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<String> unblockUser({required String providerId}) async {
    try {
      final response = await ApiClient.post(
        url: ApiUrl.unblockUser,
        parameter: {ApiParam.partnerId: providerId},
        useAuthToken: true,
      );
      return response['message'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<String> deleteChat({
    required String partnerId,
    required String bookingId,
  }) async {
    try {
      final Map<String, dynamic> parameter = {
        ApiParam.partnerId: partnerId,
        ApiParam.bookingId: bookingId,
      };
      parameter.removeWhere(
        (key, value) =>
            value == "null" || value == null || value == '' || value == "0",
      );
      final response = await ApiClient.post(
        url: ApiUrl.deleteChat,
        parameter: parameter,
        useAuthToken: true,
      );
      return response['message'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<BlockedUserModel>> getBlockedProviders() async {
    try {
      final response = await ApiClient.get(
        url: ApiUrl.getBlockedProvider,
        useAuthToken: true,
      );
      if (response['data'].isEmpty) {
        return [];
      }
      return (response['data'] as List<dynamic>)
          .map((e) => BlockedUserModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<ChatQuestion>> fetchChatQuestions({required String type}) async {
    try {
      final response = await ApiClient.post(
        url: ApiUrl.getChatQuestions,
        parameter: {ApiParam.type: type},
        useAuthToken: true,
      );

      final List<ChatQuestion> questions = [];
      for (int i = 0; i < (response['data'] as List).length; i++) {
        questions.add(ChatQuestion.fromJson(response['data'][i]));
      }
      return questions;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
