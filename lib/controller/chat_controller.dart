import 'dart:convert';
import 'package:get/get.dart';
import 'package:koji/helpers/prefs_helper.dart';
import 'package:koji/models/chat_model.dart';
import 'package:koji/services/api_constants.dart';
import 'package:koji/services/chat_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatController extends GetxController {
  RxList<Conversation> conversations = <Conversation>[].obs;
  RxList<Message> messages = <Message>[].obs;
  RxBool isLoadingConversations = false.obs;
  RxBool isLoadingMessages = false.obs;
  RxBool isSendingMessage = false.obs;

  IO.Socket? socket;
  String? currentUserId;

  @override
  void onInit() {
    super.onInit();
    initializeSocket();
    loadConversations();
  }

  Future<void> initializeSocket() async {
    // Get current user ID from preferences
    currentUserId = await PrefsHelper.getString('userId');
    String token = await PrefsHelper.getString('bearerToken');

    // Initialize socket connection
    socket = IO.io(
      ApiConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .enableForceNew()
          .setTimeout(30000)
          .build(),
    );

    socket!.onConnect((_) {
      print('✅ Socket connected successfully: ${socket!.connected}');
      print('Socket ID: ${socket!.id}');
      // Emit user connection with token
      socket!.emit("user-connected", {
        "userId": currentUserId,
        "token": token, // Include token for authentication
      });

      // Request conversation list after connection
      socket!.emit("conversation-list", {"currentUserId": currentUserId});
    });

    socket!.onConnectError((err) {
      print('❌ Socket connect error: $err');
    });

    // socket!.onConnectTimeout((err) {
    //   print('❌ Socket connect timeout: $err');
    // });

    socket!.onDisconnect((reason) {
      print('⚠️ Socket disconnected: $reason');
    });

    socket!.onReconnect((attemptNumber) {
      print('🔄 Socket reconnected on attempt: $attemptNumber');
    });

    socket!.onReconnectAttempt((attemptNumber) {
      print('🔄 Socket attempting to reconnect: $attemptNumber');
    });

    socket!.onReconnectFailed((_) {
      print('❌ Socket reconnection failed');
    });

    socket!.on('message', (data) {
      // Handle incoming message
      if (data != null) {
        print('📥 Received message: $data');
        try {
          Message newMessage = Message.fromJson(data);
          // Add to messages list if it's for the current conversation
          messages.add(newMessage);
        } catch (e) {
          print('❌ Error parsing message: $e');
        }
      }
    });

    socket!.on('conversation', (data) {
      // Handle conversation list from socket
      if (data != null) {
        print('📋 Received conversation list from socket: $data');
        try {
          List<dynamic> conversationsData = data;
          conversations.assignAll(
            conversationsData
                .map((json) => Conversation.fromJson(json))
                .toList(),
          );
        } catch (e) {
          print('❌ Error parsing conversation list: $e');
        }
      }
    });

    socket!.on('conversation_update', (data) {
      // Handle conversation updates
      if (data != null) {
        print('🔄 Received conversation update: $data');
        try {
          // Update conversations list
          Conversation updatedConversation = Conversation.fromJson(data);
          int index = conversations.indexWhere(
            (conv) => conv.id == updatedConversation.id,
          );
          if (index != -1) {
            conversations[index] = updatedConversation;
          } else {
            conversations.insert(0, updatedConversation);
          }
        } catch (e) {
          print('❌ Error parsing conversation update: $e');
        }
      }
    });
  }

  getChatUser() {
    if (socket != null && socket!.connected) {
      socket!.emit("conversation-list", {"currentUserId": currentUserId});
    }
  }

  Future<void> loadConversations() async {
    // For socket-based messaging, we rely on socket events to get conversation data
    // So we don't need to make a separate API call
    // The conversations will be populated via the 'conversation' socket event
    isLoadingConversations.value = false;
  }

  Future<void> sendMessage({
    required String conversationId,
    required String text,
    String? imageUrl,
    String? videoUrl,
    String? fileUrl,
    String? linkUrl,
    String type = 'text',
  }) async {
    if (text.trim().isEmpty && imageUrl == null && fileUrl == null) return;

    isSendingMessage.value = true;
    try {
      final response = await ChatService.sendMessage(
        conversationId: conversationId,
        text: text,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        fileUrl: fileUrl,
        linkUrl: linkUrl,
        type: type,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Add message to local list and emit via socket
        Message newMessage = Message.fromJson(response.body);
        messages.add(newMessage);

        // Emit to socket for real-time delivery
        socket?.emit('send_message', response.body);

        update();
      }
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      isSendingMessage.value = false;
    }
  }

  Future<String?> createConversation(String receiverId) async {
    try {
      final response = await ChatService.createConversation(
        receiverId: receiverId,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Add new conversation to list
        Conversation newConversation = Conversation.fromJson(response.body);
        conversations.insert(0, newConversation);
        return newConversation.id;
      }
    } catch (e) {
      print('Error creating conversation: $e');
    }
    return null;
  }

  @override
  void onClose() {
    socket?.disconnect();
    super.onClose();
  }
}
