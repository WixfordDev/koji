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

  // Track which conversation is currently requesting messages
  String? _currentConversationId;

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

    // Initialize socket connection with enhanced configuration
    socket = IO.io(
      ApiConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // Use only WebSocket transport
          .enableReconnection() // Enable auto-reconnection
          .setReconnectionAttempts(10) // Increase reconnection attempts
          .setReconnectionDelay(3000) // Wait 3 seconds between attempts
          .setReconnectionDelayMax(30000) // Max 30 seconds between attempts
          .setTimeout(45000) // Increase timeout for slow connections
          .setExtraHeaders({
            'Authorization': 'Bearer $token', // Pass token in headers
          })
          .enableForceNew() // Force new connection
          .disableAutoConnect() // Don't connect immediately
          .build(),
    );

    // Setup listeners before connecting
    setupSocketListeners();

    // Connect manually after setting up listeners
    socket!.connect();
  }

  void setupSocketListeners() {
    socket!.onConnect((_) async {
      print('✅ Socket connected successfully: ${socket!.connected}');
      print('Socket ID: ${socket!.id}');

      String token = await PrefsHelper.getString('bearerToken');
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

    socket!.onDisconnect((reason) {
      print('⚠️ Socket disconnected: $reason');
      // Try to reconnect after a delay
      Future.delayed(const Duration(seconds: 5), () {
        if (!socket!.connected) {
          print('Attempting to reconnect after disconnection...');
          connect();
        }
      });
    });

    socket!.onReconnect((attemptNumber) {
      print('🔄 Socket reconnected on attempt: $attemptNumber');
      // After successful reconnection, send the user-connected event again
      reconnectWithToken();
    });

    socket!.onReconnectAttempt((attemptNumber) {
      print('🔄 Socket attempting to reconnect: $attemptNumber');
    });

    socket!.onReconnectFailed((_) {
      print('❌ Socket reconnection failed');
      // Try manual reconnection after longer delay
      Future.delayed(const Duration(seconds: 15), () {
        if (!socket!.connected) {
          print('Attempting manual reconnection after failure...');
          connect();
        }
      });
    });

    socket!.on('new-message', (data) {
      // Handle incoming message
      if (data != null) {
        print('📥 Received message: $data');
        try {
          Message newMessage = Message.fromJson(data);
          print(
            'Parsed message - ID: ${newMessage.id}, Text: ${newMessage.text}, ConversationId: ${newMessage.conversationId}',
          );

          // Add to messages list if it's for the current conversation and not already present
          final existingMessage = messages.indexWhere(
            (msg) => msg.id == newMessage.id,
          );
          if (existingMessage == -1) {
            print('Adding new message to list');
            messages.add(newMessage);
          } else {
            print('Updating existing message in list');
            // Update the existing temporary message with the server response
            messages[existingMessage] = newMessage;
          }
          update();
        } catch (e) {
          print('❌ Error parsing message: $e');
        }
      }
    });

    socket!.on('message', (data) {
      // Handle incoming historical messages for a conversation
      if (data != null) {
        print(
          '📥 ================================Received historical messages: $data',
        );
        try {
          List<dynamic> messagesList = [];

          if (data is List) {
            messagesList = data;
          } else if (data is Map<String, dynamic>) {
            // Handle single message or structured response that contains a list of messages
            if (data.containsKey('messages') && data['messages'] is List) {
              messagesList = data['messages'];
            } else {
              // Single message - convert to list for consistent processing
              messagesList = [data];
            }
          }

          print(
            'Processing ${messagesList.length} historical messages for conversation $_currentConversationId',
          );

          // Clear messages only when we receive a fresh set of historical messages
          // for the specific conversation we requested
          messages.clear();

          for (var msgData in messagesList) {
            Message newMessage = Message.fromJson(msgData);
            print(
              'Parsed historical message - ID: ${newMessage.id}, Text: ${newMessage.text}, ConversationId: ${newMessage.conversationId}',
            );

            // Ensure the message has the correct conversationId
            if (newMessage.conversationId == null ||
                newMessage.conversationId!.isEmpty) {
              newMessage = Message(
                id: newMessage.id,
                text: newMessage.text,
                type: newMessage.type ?? 'text',
                msgByUserId: newMessage.msgByUserId,
                createdAt: newMessage.createdAt,
                conversationId: _currentConversationId,
                seen: newMessage.seen,
                imageUrl: newMessage.imageUrl,
                videoUrl: newMessage.videoUrl,
                fileUrl: newMessage.fileUrl,
                linkUrl: newMessage.linkUrl,
              );

              print(
                'Updated message with conversationId: $_currentConversationId',
              );
            }

            // Add to messages list if not already present
            final existingMessage = messages.indexWhere(
              (msg) => msg.id == newMessage.id,
            );
            if (existingMessage == -1) {
              print('Adding historical message to list');
              messages.add(newMessage);
            } else {
              print('Historical message already exists in list, updating');
              messages[existingMessage] = newMessage;
            }
          }

          // Sort messages by creation time to ensure chronological order
          messages.sort((a, b) {
            DateTime dateA = DateTime.parse(
              a.createdAt ?? DateTime.now().toIso8601String(),
            );
            DateTime dateB = DateTime.parse(
              b.createdAt ?? DateTime.now().toIso8601String(),
            );
            return dateA.compareTo(dateB);
          });

          update();
        } catch (e) {
          print('❌ Error parsing historical message: $e');
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

    socket!.onError((error) {
      print('❌ Socket general error: $error');
      // Attempt to reconnect if there's a general error
      Future.delayed(const Duration(seconds: 3), () {
        if (!socket!.connected) {
          print('Attempting to reconnect after general error...');
          connect();
        }
      });
    });

    // socket!.on('conversation_update', (data) {
    //   // Handle conversation updates
    //   if (data != null) {
    //     print('🔄 Received conversation update: $data');
    //     try {
    //       // Update conversations list
    //       Conversation updatedConversation = Conversation.fromJson(data);
    //       int index = conversations.indexWhere(
    //         (conv) => conv.id == updatedConversation.id,
    //       );
    //       if (index != -1) {
    //         conversations[index] = updatedConversation;
    //       } else {
    //         conversations.insert(0, updatedConversation);
    //       }
    //     } catch (e) {
    //       print('❌ Error parsing conversation update: $e');
    //     }
    //   }
    // });
  }

  getChatUser() {
    socket?.emit("conversation-list", {"currentUserId": currentUserId});
    print("=====================================> get chant user called");
  }

  /// Request messages for a specific conversation
  void getMessagesForConversation(String conversationId) {
    print(
      '++++++++++++++++++++++Requesting messages for conversation: $conversationId',
    );

    // Set the current conversation ID before requesting messages
    _currentConversationId = conversationId;

    // Clear previous messages to avoid mix-up
    messages.clear();

    // Emit event to request messages for the specific conversation
    socket?.emit("message-page", {"receiver": conversationId});
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
      // Create a temporary message for immediate UI feedback
      final tempMessage = Message(
        conversationId: conversationId,
        text: text,
        type: type,
        msgByUserId: currentUserId,
        createdAt: DateTime.now().toIso8601String(),
        id: null, // Will be assigned by server
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        fileUrl: fileUrl,
        linkUrl: linkUrl,
      );
      messages.add(tempMessage);
      update();
      print('Added temporary message to UI: ${tempMessage.text}');

      // Get receiver ID from conversation ID by checking the conversation
      final conversation = conversations.firstWhere(
        (conv) => conv.id == conversationId,
        orElse: () => conversations.first,
      );
      String? receiverId;
      if (conversation.sender?.id == currentUserId) {
        receiverId = conversation.receiver?.id;
      } else {
        receiverId = conversation.sender?.id;
      }

      // Emit to socket for real-time delivery using the correct format
      final messagePayload = {
        'sender': currentUserId,
        'receiver': receiverId,
        'type': type,
        'msgByUserId': currentUserId,
      };

      // Add content based on type
      switch (type) {
        case 'text':
          messagePayload['text'] = text;
          break;
        case 'image':
          messagePayload['imageUrl'] = imageUrl;
          break;
        case 'video':
          messagePayload['videoUrl'] = videoUrl;
          break;
        case 'file':
          messagePayload['fileUrl'] = fileUrl;
          break;
        case 'link':
          messagePayload['linkUrl'] = linkUrl;
          break;
        default:
          messagePayload['text'] = text;
          break;
      }

      socket?.emit('new-message', messagePayload);
      print('Emitted message via socket: $messagePayload');
    } catch (e) {
      print('Error sending message: $e');
      // Show error to user if needed
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

  // Additional methods for socket management
  void connect() {
    if (socket != null && !socket!.connected) {
      socket!.connect();
    }
  }

  Future<void> reconnectWithToken() async {
    String token = await PrefsHelper.getString('bearerToken');
    socket!.emit("user-connected", {"userId": currentUserId, "token": token});
  }

  /// Manual reconnection method that can be called from UI to reconnect to the socket server
  Future<void> manualReconnect() async {
    print('Attempting manual reconnection...');

    // Disconnect first
    socket?.disconnect();

    // Wait a bit before reconnecting
    await Future.delayed(const Duration(seconds: 2));

    // Initialize socket again
    initializeSocket();
  }

  // /// Fetch historical messages via API as a fallback
  // Future<void> fetchHistoricalMessagesFromApi(String conversationId) async {
  //   try {
  //     print(
  //       'Fetching historical messages from API for conversation: $conversationId',
  //     );
  //     final response = await ChatService.getHistoricalMessages(
  //       conversationId: conversationId,
  //     );

  //     if (response.statusCode == 200) {
  //       final data = response.body;

  //       // Handle response structure - might be direct list or object containing messages
  //       List<dynamic> messagesList = [];
  //       if (data is List) {
  //         messagesList = data;
  //       } else if (data is Map<String, dynamic> &&
  //           data.containsKey('messages')) {
  //         messagesList = data['messages'];
  //       } else if (data is Map<String, dynamic> && data.containsKey('data')) {
  //         // Some APIs return data within a 'data' field
  //         if (data['data'] is List) {
  //           messagesList = data['data'];
  //         } else if (data['data'] is Map<String, dynamic> &&
  //             data['data'].containsKey('messages')) {
  //           messagesList = data['data']['messages'];
  //         }
  //       }

  //       print(
  //         'Received ${messagesList.length} historical messages from API for conversation $conversationId',
  //       );

  //       // Clear messages for the current conversation to avoid duplicates
  //       messages.clear();

  //       for (var msgData in messagesList) {
  //         Message newMessage = Message.fromJson(msgData);

  //         // Ensure the message has the correct conversationId
  //         if (newMessage.conversationId == null ||
  //             newMessage.conversationId!.isEmpty) {
  //           newMessage = Message(
  //             id: newMessage.id,
  //             text: newMessage.text,
  //             type: newMessage.type ?? 'text',
  //             msgByUserId: newMessage.msgByUserId,
  //             createdAt: newMessage.createdAt,
  //             conversationId: conversationId,
  //             seen: newMessage.seen,
  //             imageUrl: newMessage.imageUrl,
  //             videoUrl: newMessage.videoUrl,
  //             fileUrl: newMessage.fileUrl,
  //             linkUrl: newMessage.linkUrl,
  //           );
  //         }

  //         // Add to messages list if not already present
  //         final existingMessage = messages.indexWhere(
  //           (msg) => msg.id == newMessage.id,
  //         );
  //         if (existingMessage == -1) {
  //           messages.add(newMessage);
  //         } else {
  //           messages[existingMessage] = newMessage;
  //         }
  //       }

  //       // Sort messages by creation time to ensure chronological order
  //       messages.sort((a, b) {
  //         DateTime dateA = DateTime.parse(
  //           a.createdAt ?? DateTime.now().toIso8601String(),
  //         );
  //         DateTime dateB = DateTime.parse(
  //           b.createdAt ?? DateTime.now().toIso8601String(),
  //         );
  //         return dateA.compareTo(dateB);
  //       });

  //       update();
  //     } else {
  //       print('Failed to fetch historical messages from API: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error fetching historical messages from API: $e');
  //   }
  // }

  @override
  void onClose() {
    socket?.disconnect();
    super.onClose();
  }
}
