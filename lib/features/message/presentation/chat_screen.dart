import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/constants/app_color.dart';
import 'package:koji/controller/chat_controller.dart';
import 'package:koji/models/chat_model.dart';
import 'package:koji/services/api_constants.dart';

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chatController = Get.find<ChatController>();
    conversation = widget.conversation;

    if (conversation != null) {
      otherUser = conversation!.sender?.id == chatController.currentUserId
          ? conversation!.receiver
          : conversation!.sender;

      Future.delayed(Duration.zero, () {
        chatController.getMessagesForConversation(
          conversation!.receiver?.id ?? "",
        );
      });
    } else {
      otherUser = null;
    }

    messageController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    if (conversation == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          title: Text(
            'Invalid Conversation',
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
        ),
        body: const Center(child: Text('No conversation data available')),
      );
    }

    final String initials = _getInitials(otherUser?.fullName);
    final String? avatarUrl =
        otherUser?.image != null && otherUser!.image!.isNotEmpty
            ? '${ApiConstants.imageBaseUrl}${otherUser!.image}'
            : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 1,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: _avatarColor(initials),
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Text(
                      initials,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  otherUser?.fullName ?? 'Unknown User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (otherUser?.role != null)
                  Text(
                    otherUser!.role!,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() {
              final filteredMessages = chatController.messages
                  .where((m) => m.conversationId == conversation!.id)
                  .toList();

              if (filteredMessages.isEmpty &&
                  chatController.messages.isNotEmpty) {
                return Center(
                  child: CircularProgressIndicator(color: AppColor.primaryColor),
                );
              } else if (filteredMessages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 48.r, color: Colors.grey[300]),
                      SizedBox(height: 12.h),
                      Text(
                        'Say hello! 👋',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (filteredMessages.isNotEmpty) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }

              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                itemCount: filteredMessages.length,
                itemBuilder: (context, index) {
                  final Message message = filteredMessages[index];
                  final bool isMe =
                      message.msgByUserId == chatController.currentUserId;

                  // Date separator
                  final bool showDate = index == 0 ||
                      !_isSameDay(
                        filteredMessages[index - 1].createdAt,
                        message.createdAt,
                      );

                  return Column(
                    children: [
                      if (showDate) _buildDateChip(message.createdAt),
                      _buildMessageBubble(message, isMe),
                    ],
                  );
                },
              );
            }),
          ),

          // Input bar
          _buildMessageInput(messageController, conversation!.id!),
        ],
      ),
    );
  }

  Widget _buildDateChip(String? dateString) {
    String label = '';
    if (dateString != null) {
      try {
        final date = DateTime.parse(dateString).toLocal();
        final now = DateTime.now();
        if (now.day == date.day && now.month == date.month &&
            now.year == date.year) {
          label = 'Today';
        } else {
          label =
              '${date.day} ${_monthName(date.month)} ${date.year}';
        }
      } catch (_) {}
    }
    if (label.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 4.h,
        left: isMe ? 48.w : 0,
        right: isMe ? 0 : 48.w,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: 280.w),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isMe ? AppColor.primaryColor : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.r),
              topRight: Radius.circular(18.r),
              bottomLeft:
                  Radius.circular(isMe ? 18.r : 4.r),
              bottomRight:
                  Radius.circular(isMe ? 4.r : 18.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network(
                    '${ApiConstants.imageBaseUrl}${message.imageUrl}',
                    width: 220.w,
                    height: 160.h,
                    fit: BoxFit.cover,
                  ),
                ),
              if (message.text != null && message.text!.isNotEmpty) ...[
                if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
                  SizedBox(height: 6.h),
                Text(
                  message.text!,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 14.sp,
                    height: 1.4,
                  ),
                ),
              ],
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isMe
                          ? Colors.white.withOpacity(0.65)
                          : Colors.grey[400],
                    ),
                  ),
                  if (isMe) ...[
                    SizedBox(width: 4.w),
                    Icon(
                      message.seen == true
                          ? Icons.done_all
                          : Icons.done,
                      size: 13.r,
                      color: message.seen == true
                          ? Colors.blue[200]
                          : Colors.white.withOpacity(0.65),
                    ),
                  ],
                ],
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
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle:
                        TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Obx(() {
              if (chatController.isSendingMessage.value) {
                return SizedBox(
                  width: 44.w,
                  height: 44.h,
                  child: Center(
                    child: SizedBox(
                      width: 22.w,
                      height: 22.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
                );
              }
              return GestureDetector(
                onTap: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    chatController.sendMessage(
                      conversationId: conversationId,
                      text: text,
                    );
                    controller.clear();
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  }
                },
                child: Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF234176), Color(0xFF2D8BE5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primaryColor.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(Icons.send_rounded,
                      color: Colors.white, size: 20.r),
                ),
              );
            }),
          ],
        ),
      ),
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
    ];
    final idx = initials.isEmpty ? 0 : initials.codeUnitAt(0) % colors.length;
    return colors[idx];
  }

  bool _isSameDay(String? a, String? b) {
    if (a == null || b == null) return false;
    try {
      final da = DateTime.parse(a).toLocal();
      final db = DateTime.parse(b).toLocal();
      return da.day == db.day && da.month == db.month && da.year == db.year;
    } catch (_) {
      return false;
    }
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString).toLocal();
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
