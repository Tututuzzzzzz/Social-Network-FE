import 'package:dio/dio.dart';

import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/message_media_upload_file.dart';
import '../models/message_model.dart';

abstract class MessageRemoteDataSource {
  Future<MessageHistoryPageModel> fetchConversationHistory({
    required String conversationId,
    int limit,
    String? cursor,
  });

  Future<MessageModel> sendDirectText({
    required String conversationId,
    required String recipientId,
    required String content,
  });

  Future<MessageActionResultModel> sendDirectMedia({
    required String conversationId,
    required String recipientId,
    required List<MessageMediaUploadFile> files,
    String? content,
  });

  Future<MessageModel> sendGroupText({
    required String conversationId,
    required String content,
  });

  Future<MessageActionResultModel> sendGroupMedia({
    required String conversationId,
    required List<MessageMediaUploadFile> files,
    String? content,
  });

  Future<MessageModel> sendDirectMessage({
    required String conversationId,
    String? content,
    List<Map<String, dynamic>>? media,
  });

  Future<MessageModel> sendGroupMessage({
    required String conversationId,
    String? content,
    List<Map<String, dynamic>>? media,
  });

  Future<MessageActionResultModel> addReaction({
    required String messageId,
    required String emoji,
  });

  Future<MessageActionResultModel> removeReaction({
    required String messageId,
    required String emoji,
  });

  Future<MessageActionResultModel> markMessageAsRead({
    required String conversationId,
    required String messageId,
  });

  Future<MessageActionResultModel> markAllMessagesAsRead({
    required String conversationId,
    String? lastMessageId,
  });

  Future<MessageActionResultModel> deleteMessage({
    required String conversationId,
    required String messageId,
  });
}

class MessageRemoteDataSourceImpl implements MessageRemoteDataSource {
  final ApiHelper _apiHelper;

  const MessageRemoteDataSourceImpl(this._apiHelper);

  @override
  Future<MessageHistoryPageModel> fetchConversationHistory({
    required String conversationId,
    int limit = 30,
    String? cursor,
  }) async {
    try {
      final response = await _apiHelper.execute(
        url: ApiConstants.messagesHistory(
          conversationId,
          limit: limit,
          cursor: cursor,
        ),
        method: Method.get,
      );

      return MessageHistoryPageModel.fromApiJson(response);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  MessageModel _extractMessage(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];

      if (data is Map<String, dynamic> && data['message'] is Map) {
        return MessageModel.fromJson(
          Map<String, dynamic>.from(data['message'] as Map),
        );
      }

      if (data is Map<String, dynamic>) {
        return MessageModel.fromJson(data);
      }

      if (response['message'] is Map) {
        return MessageModel.fromJson(
          Map<String, dynamic>.from(response['message'] as Map),
        );
      }

      return MessageModel.fromJson(response);
    }

    throw Exception('Invalid message response format');
  }

  MessageActionResultModel _extractActionResult(dynamic response) {
    if (response is Map<String, dynamic>) {
      return MessageActionResultModel.fromJson(response);
    }

    return MessageActionResultModel(message: response?.toString() ?? 'Success');
  }

  @override
  Future<MessageModel> sendDirectText({
    required String conversationId,
    required String recipientId,
    required String content,
  }) async {
    try {
      final response = await _apiHelper.execute(
        url: ApiConstants.messagesDirectText,
        method: Method.post,
        data: {
          'conversationId': conversationId,
          'recipientId': recipientId,
          'content': content,
        },
      );
      return _extractMessage(response);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<MessageActionResultModel> sendDirectMedia({
    required String conversationId,
    required String recipientId,
    required List<MessageMediaUploadFile> files,
    String? content,
  }) async {
    try {
      final response = await _apiHelper.execute(
        url: ApiConstants.messagesDirectMedia,
        method: Method.post,
        data: await _mediaFormData(
          conversationId: conversationId,
          recipientId: recipientId,
          files: files,
          content: content,
        ),
      );
      return _extractActionResult(response);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<MessageModel> sendGroupText({
    required String conversationId,
    required String content,
  }) async {
    try {
      final response = await _apiHelper.execute(
        url: ApiConstants.messagesGroupText,
        method: Method.post,
        data: {'conversationId': conversationId, 'content': content},
      );
      return _extractMessage(response);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<MessageActionResultModel> sendGroupMedia({
    required String conversationId,
    required List<MessageMediaUploadFile> files,
    String? content,
  }) async {
    try {
      final response = await _apiHelper.execute(
        url: ApiConstants.messagesGroupMedia,
        method: Method.post,
        data: await _mediaFormData(
          conversationId: conversationId,
          files: files,
          content: content,
        ),
      );
      return _extractActionResult(response);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  Future<FormData> _mediaFormData({
    required String conversationId,
    String recipientId = '',
    required List<MessageMediaUploadFile> files,
    String? content,
  }) async {
    final multipartFiles = <MultipartFile>[];

    for (final file in files) {
      if (file.hasBytes) {
        multipartFiles.add(
          MultipartFile.fromBytes(file.bytes!, filename: file.name),
        );
        continue;
      }

      if (file.hasPath) {
        multipartFiles.add(
          await MultipartFile.fromFile(file.path!, filename: file.name),
        );
      }
    }

    return FormData.fromMap({
      'conversationId': conversationId,
      if (recipientId.trim().isNotEmpty) 'recipientId': recipientId.trim(),
      if (content != null && content.trim().isNotEmpty)
        'content': content.trim(),
      'files': multipartFiles,
    });
  }

  @override
  Future<MessageModel> sendDirectMessage({
    required String conversationId,
    String? content,
    List<Map<String, dynamic>>? media,
  }) async {
    try {
      final payload = <String, dynamic>{
        'conversationId': conversationId,
        'content': content,
        'media': media,
      }..removeWhere((_, value) => value == null);

      final response = await _apiHelper.execute(
        url: ApiConstants.messages,
        method: Method.post,
        data: payload,
      );
      return _extractMessage(response);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<MessageModel> sendGroupMessage({
    required String conversationId,
    String? content,
    List<Map<String, dynamic>>? media,
  }) async {
    try {
      final payload = <String, dynamic>{
        'conversationId': conversationId,
        'content': content,
        'media': media,
      }..removeWhere((_, value) => value == null);

      final response = await _apiHelper.execute(
        url: ApiConstants.groups,
        method: Method.post,
        data: payload,
      );
      return _extractMessage(response);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<MessageActionResultModel> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final response = await _apiHelper.execute(
        url: ApiConstants.messageReaction(messageId),
        method: Method.put,
        data: {'emoji': emoji},
      );
      return _extractActionResult(response);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<MessageActionResultModel> removeReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final response = await _apiHelper.execute(
        url: ApiConstants.messageReaction(messageId),
        method: Method.delete,
        data: {'emoji': emoji},
      );
      return _extractActionResult(response);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<MessageActionResultModel> markMessageAsRead({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      final response = await _apiHelper.execute(
        url: ApiConstants.messageRead(conversationId, messageId),
        method: Method.patch,
      );
      return _extractActionResult(response);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<MessageActionResultModel> markAllMessagesAsRead({
    required String conversationId,
    String? lastMessageId,
  }) async {
    try {
      final response = await _apiHelper.execute(
        url: ApiConstants.messagesReadAll(conversationId),
        method: Method.patch,
        data: {
          if (lastMessageId != null && lastMessageId.trim().isNotEmpty)
            'lastMessageId': lastMessageId,
        },
      );
      return _extractActionResult(response);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<MessageActionResultModel> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      final response = await _apiHelper.execute(
        url: ApiConstants.messageDelete(conversationId, messageId),
        method: Method.delete,
      );
      return _extractActionResult(response);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }
}
