import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/shared_widgets/custom_text.dart';
import 'package:intl/intl.dart';
import '../../../controller/notifications_controller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationController notificationController;

  @override
  void initState() {
    super.initState();
    notificationController = Get.find<NotificationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationController.getNotification();
    });
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd.MM').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
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
      body: Obx(() {
        if (notificationController.getNotificationLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final notifications = notificationController.notification.value.notifications ?? [];

        if (notifications.isEmpty) {
          return Center(
            child: CustomText(
              text: "No notifications yet",
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          );
        }

        return Padding(
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


                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: CustomText(
                                  text: item.title ?? "Notification",
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              CustomText(
                                text: formatDate(item.createdAt),
                                color: Colors.grey,
                                fontSize: 12.sp,
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          CustomText(
                            text: item.content ?? "",
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
        );
      }),
    );
  }
}