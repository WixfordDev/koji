import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:koji/constants/app_color.dart';
import 'package:koji/controller/chat_controller.dart';
import 'package:koji/features/message/presentation/chat_screen.dart';
import 'package:koji/models/chat_model.dart';
import 'package:koji/routes/route_paths.dart';
import 'package:koji/services/api_constants.dart';
import 'package:koji/shared_widgets/custom_text.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  ChatController chatController = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();
    chatController.initializeSocket();

    chatController.getChatUser();
  }

  @override
  Widget build(BuildContext context) {
    ChatController chatController = Get.find<ChatController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: CustomText(
          text: "Messages",
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Obx(() {
        if (chatController.isLoadingConversations.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatController.conversations.isEmpty) {
          return const Center(child: Text("No conversations yet"));
        }

        return ListView.builder(
          itemCount: chatController.conversations.length,
          itemBuilder: (context, index) {
            Conversation conversation = chatController.conversations[index];
            User? otherUser =
                conversation.sender?.id ==
                    Get.find<ChatController>().currentUserId
                ? conversation.receiver
                : conversation.sender;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    otherUser?.image != null && otherUser!.image!.isNotEmpty
                    ? NetworkImage(
                        '${ApiConstants.imageBaseUrl}$otherUser.image',
                      )
                    : null,
                child: otherUser?.image == null
                    ? Icon(Icons.person, color: Colors.grey[600])
                    : null,
              ),
              title: CustomText(
                text: otherUser?.fullName ?? 'Unknown User',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.left,
              ),
              subtitle: conversation.lastMsg != null
                  ? Text(
                      conversation.lastMsg!.text ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text('Start a conversation'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (conversation.lastMsg != null)
                    Text(
                      _formatTime(conversation.lastMsg!.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  if (conversation.unseenMsg != null &&
                      conversation.unseenMsg! > 0)
                    Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        conversation.unseenMsg.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () {
                // Navigate to chat screen using GoRouter with extra data
                context.pushNamed(
                  RoutePaths.chatScreen,
                  extra: conversation,
                );
              },
            );
          },
        );
      }),
    );
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '';

    try {
      DateTime date = DateTime.parse(dateString);
      if (DateTime.now().day == date.day) {
        return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        return '${date.day}/${date.month}/${date.year % 100}';
      }
    } catch (e) {
      return '';
    }
  }
}
