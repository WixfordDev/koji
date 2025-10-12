import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/features/message/presentation/chat_screen.dart';
import 'package:koji/shared_widgets/custom_network_image.dart';
import 'package:koji/shared_widgets/custom_text.dart';

class MessageListScreen extends StatelessWidget {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      {
        "name": "Rohan Mehta",
        "msg": "Hi, I just applied for the bart...",
        "time": "10:00pm",
        "img": "https://randomuser.me/api/portraits/men/10.jpg",
      },
      {
        "name": "Priya Shah",
        "msg": "Hi, I just applied for the bart...",
        "time": "10:00pm",
        "img": "https://randomuser.me/api/portraits/women/20.jpg",
      },
      {
        "name": "Aman Patel",
        "msg": "Hi, I just applied for the bart...",
        "time": "Yesterday",
        "img": "https://randomuser.me/api/portraits/men/30.jpg",
      },
      {
        "name": "Sneha Varma",
        "msg": "Hi, I just applied for the bart...",
        "time": "Yesterday",
        "img": "https://randomuser.me/api/portraits/women/40.jpg",
      },
      {
        "name": "Ravi Nair",
        "msg": "Hi, I just applied for the bart...",
        "time": "Saturday",
        "img": "https://randomuser.me/api/portraits/men/50.jpg",
      },
      {
        "name": "Anjali Desai",
        "msg": "Hi, I just applied for the bart...",
        "time": "Saturday",
        "img": "https://randomuser.me/api/portraits/women/60.jpg",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: CustomText(
          text: "Message",
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Column(
          children: [
            // 🔍 Search bar
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: const Color(0xffF5F5F5),
              ),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: "Search...",
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 15.h),

            // 🧑‍💼 Message list
            Expanded(
              child: ListView.separated(
                itemCount: messages.length,
                separatorBuilder: (_, __) =>
                    Divider(color: Colors.grey.shade200, height: 25.h),
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatDetailScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CustomNetworkImage(
                          imageUrl: msg["img"]!,
                          height: 50.h,
                          width: 50.h,
                          boxShape: BoxShape.circle,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: msg["name"]!,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                              SizedBox(height: 4.h),
                              CustomText(
                                text: msg["msg"]!,
                                color: Colors.grey,
                                fontSize: 12.sp,
                              ),
                            ],
                          ),
                        ),
                        CustomText(
                          text: msg["time"]!,
                          color: Colors.grey,
                          fontSize: 12.sp,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
