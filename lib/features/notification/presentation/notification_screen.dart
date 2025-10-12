import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/shared_widgets/custom_text.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        "title": "New Task Assigned to You!",
        "message":
            "You have new task for this sprint from Alicia, you can check your task “Create Onboarding Screen” by tap here",
        "date": "09.10",
      },
      {
        "title": "New Task Assigned to You!",
        "message":
            "You have new task for this sprint from Alicia, you can check your task “Create Onboarding Screen” by tap here",
        "date": "09.10",
      },
      {
        "title": "New Task Assigned to You!",
        "message":
            "You have new task for this sprint from Alicia, you can check your task “Create Onboarding Screen” by tap here",
        "date": "09.10",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: CustomText(
          text: "Notifications",
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: ListView.separated(
          itemCount: notifications.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final item = notifications[index];
            return Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🟣 Left icon
                  Container(
                    margin: EdgeInsets.only(top: 6.h),
                    height: 60.h,
                    width: 45.h,
                    decoration: BoxDecoration(
                      color: const Color(0xffEEF2FF),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: const Color(0xff165DF5),
                      size: 26.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // 🔤 Notification content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomText(
                                text: item["title"]!,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            CustomText(
                              text: item["date"]!,
                              color: Colors.grey,
                              fontSize: 12.sp,
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        CustomText(
                          text: item["message"]!,
                          fontSize: 12.sp,
                          color: Colors.grey.shade700,
                          textAlign: TextAlign.start,
                          maxline: 100,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
