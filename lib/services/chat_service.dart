import 'dart:convert';
import 'package:get/get_connect/http/src/response/response.dart';
import 'api_client.dart';

class ChatService {
  // Send a message
  static Future<Response> sendMessage({
    required String conversationId,
    required String text,
    String? imageUrl,
    String? videoUrl,
    String? fileUrl,
    String? linkUrl,
    String type = 'text',
  }) async {
    final body = jsonEncode({
      'conversationId': conversationId,
      'text': text,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (fileUrl != null) 'fileUrl': fileUrl,
      if (linkUrl != null) 'linkUrl': linkUrl,
      'type': type,
    });

    return await ApiClient.postData('/messages', body);
  }

  // Create a new conversation
  static Future<Response> createConversation({
    required String receiverId,
  }) async {
    final body = jsonEncode({'receiverId': receiverId});

    return await ApiClient.postData('/chats/conversations', body);
  }
}
