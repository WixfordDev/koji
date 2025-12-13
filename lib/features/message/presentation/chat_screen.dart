import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/constants/app_color.dart';
import 'package:koji/controller/chat_controller.dart';
import 'package:koji/models/chat_model.dart';
import 'package:koji/services/api_constants.dart';
import 'package:koji/shared_widgets/custom_text.dart';

class ChatScreen extends StatefulWidget {
  final Conversation? conversation;
  const ChatScreen({super.key, this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatController chatController;
  late TextEditingController messageController;
  Conversation? conversation;
  User? otherUser;

  @override
  void initState() {
    super.initState();
    chatController = Get.find<ChatController>();
    conversation = widget.conversation;

    print('ChatScreen init - Conversation ID: ${conversation?.id}');

    // Only set otherUser if conversation is not null
    if (conversation != null) {
      otherUser = conversation!.sender?.id == chatController.currentUserId
          ? conversation!.receiver
          : conversation!.sender;

      // Request historical messages for this conversation after a short delay
      // to ensure the socket is properly connected
      Future.delayed(Duration.zero, () {
        chatController.getMessagesForConversation(
          conversation!.receiver?.id ?? "",
        );

        // Add a fallback timer to fetch via API if socket messages haven't loaded
        Future.delayed(const Duration(seconds: 3), () {
          if (chatController.messages.isEmpty) {
            // print('Socket did not load messages, attempting API fallback');
            // chatController.fetchHistoricalMessagesFromApi(conversation!.id!);
          }
        });
      });
    } else {
      otherUser = null;
    }

    messageController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    print('Rebuilding ChatScreen - Conversation ID: ${conversation?.id}');
    print('Current messages count: ${chatController.messages.length}');

    // Handle the case when no conversation is provided
    if (conversation == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: CustomText(
            text: 'Invalid Conversation',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        body: const Center(child: Text('No conversation data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  otherUser?.image != null && otherUser!.image!.isNotEmpty
                  ? NetworkImage(
                      '${ApiConstants.imageBaseUrl}${otherUser!.image}',
                    )
                  : null,
              child: otherUser?.image == null || otherUser!.image!.isEmpty
                  ? Icon(Icons.person, color: Colors.grey[600])
                  : null,
            ),
            SizedBox(width: 10.w),
            CustomText(
              text: otherUser?.fullName ?? 'Unknown User',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() {
              print(
                'Messages list rebuild - Count: ${chatController.messages.length}',
              );

              // Filter messages for current conversation
              final filteredMessages = chatController.messages
                  .where(
                    (message) => message.conversationId == conversation!.id,
                  )
                  .toList();

              print(
                'Filtered messages for conversation ${conversation!.id}: ${filteredMessages.length}',
              );

              if (filteredMessages.isEmpty &&
                  chatController.messages.isNotEmpty) {
                // If no messages match the current conversation but we have messages for other conversations,
                // that means the messages haven't loaded yet for this conversation
                return const Center(child: CircularProgressIndicator());
              } else if (filteredMessages.isEmpty) {
                // No messages at all, either for this conversation or any other
                return const Center(child: Text('No messages yet'));
              }

              return ListView.builder(
                reverse: false, // Show messages from top to bottom
                itemCount: filteredMessages.length,
                itemBuilder: (context, index) {
                  Message message = filteredMessages[index];
                  bool isMe =
                      message.msgByUserId == chatController.currentUserId;

                  print(
                    'Building message bubble for: ${message.text} - isMe: $isMe',
                  );

                  return _buildMessageBubble(message, isMe);
                },
              );
            }),
          ),

          // Message input
          _buildMessageInput(messageController, conversation!.id!),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    print('Drawing message bubble: ${message.text}');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isMe ? AppColor.primaryColor : Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
              bottomLeft: !isMe ? Radius.circular(4.r) : Radius.circular(12.r),
              bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(12.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.text != null && message.text!.isNotEmpty)
                Text(
                  message.text!,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: 14.sp,
                  ),
                ),
              if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
                Container(
                  width: 200.w,
                  height: 150.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    image: DecorationImage(
                      image: NetworkImage(
                        '${ApiConstants.imageBaseUrl}${message.imageUrl}',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: 4.h),
              Text(
                _formatTime(message.createdAt),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isMe ? Colors.blue[100] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(
    TextEditingController controller,
    String conversationId,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Obx(() {
            if (chatController.isSendingMessage.value) {
              return Container(
                width: 40.w,
                height: 40.h,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white, size: 20.sp),
                onPressed: () {
                  String text = controller.text.trim();
                  if (text.isNotEmpty) {
                    chatController.sendMessage(
                      conversationId: conversationId,
                      text: text,
                    );
                    controller.clear();
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '';

    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Error parsing date: $e');
      return '';
    }
  }
}
