import 'dart:convert';
import 'package:get/get_connect/http/src/response/response.dart';
import 'api_client.dart';

class ChatService {
  // Create a new conversation
  static Future<Response> createConversation({
    required String receiverId,
  }) async {
    final body = jsonEncode({'receiverId': receiverId});

    return await ApiClient.postData('/chats/conversations', body);
  }

  // Fetch historical messages for a conversation
  static Future<Response> getHistoricalMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    final endpoint = '/chats/conversations/$conversationId/messages?page=$page&limit=$limit';
    return await ApiClient.getData(endpoint);
  }
}
