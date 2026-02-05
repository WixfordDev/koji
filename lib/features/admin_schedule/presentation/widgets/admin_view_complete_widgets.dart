import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../global/custom_assets/assets.gen.dart';
import '../../../../shared_widgets/custom_text.dart';

class TaskCard extends StatelessWidget {
  final String taskTitle;
  final String status;
  final String time;
  final double progressPercentage;
  final String userName;
  final String userImage;
  final String date;
  final String priority;
  final String difficulty;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.taskTitle,
    required this.status,
    required this.time,
    required this.progressPercentage,
    required this.userName,
    required this.userImage,
    required this.date,
    this.priority = 'N/A',
    this.difficulty = 'N/A',
    this.onTap,
  });

  // Helper method to get status color
  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('submit') || statusLower.contains('complete')) {
      return const Color(0xFF4CD964);
    } else if (statusLower.contains('progress')) {
      return const Color(0xFFFFB800);
    } else if (statusLower.contains('pending')) {
      return const Color(0xFFFF1414);
    }
    return Colors.grey;
  }

  // Helper method to get status text
  String _getStatusText(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('submit') || statusLower.contains('complete')) {
      return 'Completed';
    } else if (statusLower.contains('progress')) {
      return 'In Progress';
    } else if (statusLower.contains('pending')) {
      return 'Pending';
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 356.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: const Color(0xFFCECECE).withOpacity(0.25),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF95555).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.flash_on,
                    size: 20.sp,
                    color: const Color(0xFFF95555),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomText(
                    textAlign: TextAlign.start,
                    text: taskTitle,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Status and Time Row
            Row(
              children: [
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: CustomText(
                    text: _getStatusText(status),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(status),
                  ),
                ),
                SizedBox(width: 12.w),

                // Time Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF95555).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14.sp,
                        color: const Color(0xFFF95555),
                      ),
                      SizedBox(width: 4.w),
                      CustomText(
                        text: time,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF95555),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Percentage
                CustomText(
                  text: '${progressPercentage.toInt()}%',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Progress Bar - Updated with new design
            Container(
              width: 324.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressPercentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF95555), Color(0xFFFF8C8C)],
                    ),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Priority and Difficulty Row
            Row(
              children: [
                // Priority Badge
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: priority.toLowerCase() == 'high'
                          ? Colors.red.withOpacity(0.1)
                          : priority.toLowerCase() == 'medium'
                          ? Colors.amber.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      border: Border.all(
                        color: priority.toLowerCase() == 'high'
                            ? Colors.red
                            : priority.toLowerCase() == 'medium'
                            ? Colors.amber
                            : Colors.green,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber,
                          size: 14.sp,
                          color: priority.toLowerCase() == 'high'
                              ? Colors.red[700]
                              : priority.toLowerCase() == 'medium'
                              ? Colors.amber[700]
                              : Colors.green[700],
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: CustomText(
                            text: 'Priority: $priority',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: priority.toLowerCase() == 'high'
                                ? Colors.red[700]!
                                : priority.toLowerCase() == 'medium'
                                ? Colors.amber[700]!
                                : Colors.green[700]!,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Difficulty Badge
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 14.sp,
                          color: Colors.blue[700],
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: CustomText(
                            text: 'Difficulty: $difficulty',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700]!,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // User Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16.r,
                      backgroundColor: const Color(0xFFE5E5E5),
                      child: Icon(
                        Icons.person,
                        size: 18.sp,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    CustomText(
                      text: userName,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4.w),
                    CustomText(
                      text: date,
                      fontSize: 12.sp,
                      color: Colors.grey[600]!,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}