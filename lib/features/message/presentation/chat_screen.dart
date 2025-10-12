import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/shared_widgets/custom_text.dart';
import 'package:koji/shared_widgets/custom_network_image.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController msgCtrl = TextEditingController();

  // Dummy messages
  List<Map<String, dynamic>> messages = [
    {
      "isSender": false,
      "text": "Hello! You're welcome. How are you feeling today?",
      "time": "1:44 PM",
      "avatar": "https://randomuser.me/api/portraits/men/10.jpg",
    },
    {
      "isSender": true,
      "text": "Hello Doctor, Thank you for accepting my appointment.",
      "time": "1:45 PM",
      "avatar": "https://randomuser.me/api/portraits/men/20.jpg",
    },
    {
      "isSender": true,
      "text":
          "I've been having headaches for the last 3 days and slight dizziness.",
      "time": "1:46 PM",
      "avatar": "https://randomuser.me/api/portraits/men/20.jpg",
    },
  ];

  void sendMessage() {
    if (msgCtrl.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "isSender": true,
        "text": msgCtrl.text.trim(),
        "time": "Now",
        "avatar": "https://randomuser.me/api/portraits/men/20.jpg",
      });
      msgCtrl.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      // Auto scroll to bottom
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: CustomText(
          text: "Message",
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(15.w),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isSender = msg["isSender"] as bool;

                return Column(
                  crossAxisAlignment: isSender
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: isSender
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isSender) ...[
                          CustomNetworkImage(
                            imageUrl: msg["avatar"],
                            height: 35.h,
                            width: 35.h,
                            boxShape: BoxShape.circle,
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Flexible(
                          child: Container(
                            width: msg["text"].length > 30 ? 250.w : null,
                            padding: EdgeInsets.all(10.w),
                            margin: EdgeInsets.symmetric(vertical: 5.h),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSender
                                    ? const Color(0xff165DF5)
                                    : Colors.grey.shade300,
                              ),
                              color: isSender
                                  ? const Color(0xff165DF5)
                                  : const Color(0xffF3F4F6),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.r),
                                topRight: Radius.circular(12.r),
                                bottomLeft: Radius.circular(
                                  isSender ? 12.r : 0,
                                ),
                                bottomRight: Radius.circular(
                                  isSender ? 0 : 12.r,
                                ),
                              ),
                            ),
                            child: CustomText(
                              text: msg["text"],
                              color: isSender ? Colors.white : Colors.black,
                              fontSize: 13.sp,
                              maxline: 1000000,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                        if (isSender) ...[
                          SizedBox(width: 8.w),
                          CustomNetworkImage(
                            imageUrl: msg["avatar"],
                            height: 35.h,
                            width: 35.h,
                            boxShape: BoxShape.circle,
                          ),
                        ],
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: isSender ? 0 : 45.w,
                        right: isSender ? 45.w : 0,
                      ),
                      child: CustomText(
                        text: msg["time"],
                        color: Colors.grey,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 📝 Message input area
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgCtrl,
                    decoration: InputDecoration(
                      hintText: "Type something...",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13.sp),
                      prefixIcon: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xffF3F4F6),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 15.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: sendMessage,
                  child: CircleAvatar(
                    radius: 23.r,
                    backgroundColor: const Color(0xff165DF5),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
