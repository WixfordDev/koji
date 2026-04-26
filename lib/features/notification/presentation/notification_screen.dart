import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/models/notification_model.dart' as notif_model;
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

  void _onNotificationTap(notif_model.Notification item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: const Color(0xffEEF2FF),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.description_outlined, color: const Color(0xff165DF5), size: 24.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomText(
                      text: item.title ?? "Notification",
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 22.sp, color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (item.content != null && item.content!.isNotEmpty) ...[
                SizedBox(height: 14.h),
                CustomText(
                  text: item.content!,
                  fontSize: 13.sp,
                  color: Colors.grey.shade700,
                  textAlign: TextAlign.start,
                  maxline: 100,
                ),
              ],
              SizedBox(height: 16.h),
              Divider(color: Colors.grey.shade200, height: 1),
              SizedBox(height: 14.h),
              if (item.priority != null) _detailRow(Icons.flag_outlined, "Priority", item.priority!, Colors.orange.shade700),
              if (item.type != null) _detailRow(Icons.label_outline, "Type", item.type!, Colors.blue.shade700),
              if (item.status != null) _detailRow(Icons.info_outline, "Status", item.status!, Colors.grey.shade700),
              if (item.role != null) _detailRow(Icons.person_outline, "Role", item.role!, Colors.purple.shade700),
              if (item.createdAt != null)
                _detailRow(
                  Icons.access_time,
                  "Received",
                  DateFormat("MMMM dd, yyyy 'at' hh:mm a").format(item.createdAt!),
                  Colors.grey.shade700,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 8.w),
          CustomText(text: "$label: ", fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black87),
          Expanded(
            child: CustomText(
              text: value,
              fontSize: 12.sp,
              color: Colors.grey.shade700,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
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
              return GestureDetector(
                onTap: () => _onNotificationTap(item),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22.w,
                        height: 22.w,
                        margin: EdgeInsets.only(top: 6.h, right: 10.w),
                        decoration: BoxDecoration(color: Colors.grey.shade700, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text('${index + 1}', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w700)),
                      ),
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
                ),
              );
            },
          ),
        );
         }),
    );
  }
}