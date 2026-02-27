import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:koji/constants/app_color.dart';
import 'package:koji/controller/chat_controller.dart';
import 'package:koji/models/chat_model.dart';
import 'package:koji/routes/route_paths.dart';
import 'package:koji/services/api_constants.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Messages",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(color: Colors.white.withOpacity(0.1), height: 1.h),
        ),
      ),
      body: Obx(() {
        if (chatController.isLoadingConversations.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColor.primaryColor),
          );
        }

        if (chatController.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 64.r, color: Colors.grey[300]),
                SizedBox(height: 16.h),
                Text(
                  "No conversations yet",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: chatController.conversations.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            indent: 78.w,
            endIndent: 16.w,
            color: Colors.grey[200],
          ),
          itemBuilder: (context, index) {
            final Conversation conversation =
                chatController.conversations[index];
            final User? otherUser =
                conversation.sender?.id == chatController.currentUserId
                    ? conversation.receiver
                    : conversation.sender;

            final bool hasUnread = (conversation.unseenMsg ?? 0) > 0;
            final String initials = _getInitials(otherUser?.fullName);
            final String? imageUrl =
                otherUser?.image != null && otherUser!.image!.isNotEmpty
                    ? '${ApiConstants.imageBaseUrl}${otherUser.image}'
                    : null;

            return InkWell(
              onTap: () {
                context.pushNamed(
                  RoutePaths.chatScreen,
                  extra: conversation,
                );
              },
              child: Container(
                color: Colors.white,
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 26.r,
                          backgroundColor: _avatarColor(initials),
                          backgroundImage: imageUrl != null
                              ? NetworkImage(imageUrl)
                              : null,
                          child: imageUrl == null
                              ? Text(
                                  initials,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),

                    // Name & last message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            otherUser?.fullName ?? 'Unknown User',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            conversation.lastMsg?.text ?? 'Start a conversation',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: hasUnread
                                  ? Colors.black87
                                  : Colors.grey[500],
                              fontWeight: hasUnread
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Time & unread badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(conversation.lastMsg?.createdAt),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: hasUnread
                                ? AppColor.primaryColor
                                : Colors.grey[400],
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        if (hasUnread)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              conversation.unseenMsg.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        else
                          SizedBox(height: 18.h),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Color _avatarColor(String initials) {
    final colors = [
      const Color(0xFF234176),
      const Color(0xFF2D8BE5),
      const Color(0xFF31712B),
      const Color(0xFFEC526A),
      const Color(0xFFB060F6),
      const Color(0xFFF48201),
    ];
    final idx = initials.isEmpty ? 0 : initials.codeUnitAt(0) % colors.length;
    return colors[idx];
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString).toLocal();
      final now = DateTime.now();
      if (now.day == date.day &&
          now.month == date.month &&
          now.year == date.year) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        return '${date.day}/${date.month}/${date.year % 100}';
      }
    } catch (_) {
      return '';
    }
  }
}
