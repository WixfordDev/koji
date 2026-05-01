import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../global/custom_assets/assets.gen.dart';
import '../../../../shared_widgets/custom_text.dart';

class TaskCard extends StatelessWidget {
  final int? serialNumber;
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
    this.serialNumber,
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
      return const Color(0xFFF95555);
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
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _getStatusBorderColor(status),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row
            Row(
              children: [
                if (serialNumber != null) ...[
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(color: Colors.grey.shade700, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text('$serialNumber', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(width: 8.w),
                ],
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 18.sp,
                    color: const Color(0xFF667085),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    taskTitle,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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
                    color: _getStatusLightColor(status),
                    borderRadius: BorderRadius.circular(100.r),
                    border: Border.all(color: _getStatusBorderColor(status), width: 1),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _getStatusDarkColor(status),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Time Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Percentage
                Text(
                  '${progressPercentage.toInt()}%',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Progress Bar
            Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: const Color(0xFFEAECF0),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressPercentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // User Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 16.r,
                        backgroundColor: const Color(0xFFEAECF0),
                        child: Icon(
                          Icons.bolt,
                          size: 20.sp,
                          color: _getStatusColor(status),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14.sp,
                      color: const Color(0xFF667085),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF667085),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Chat Icon
                    Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAECF0),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.chat_bubble_outline,
                          size: 12.sp,
                          color: const Color(0xFF667085),
                        ),
                      ),
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

  Color _getStatusBorderColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('submit') || s.contains('complete')) return Colors.green.shade200;
    if (s.contains('progress')) return Colors.orange.shade200;
    return Colors.orange.shade200;
  }

  Color _getStatusLightColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('submit') || s.contains('complete')) return Colors.green.shade50;
    if (s.contains('progress')) return Colors.orange.shade50;
    return Colors.orange.shade50;
  }

  Color _getStatusDarkColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('submit') || s.contains('complete')) return Colors.green.shade700;
    if (s.contains('progress')) return Colors.orange.shade700;
    return Colors.orange.shade700;
  }

  Color _getPriorityColor(String priority) {
    final priorityLower = priority.toLowerCase();
    if (priorityLower == 'high') {
      return const Color(0xFFF04438);
    } else if (priorityLower == 'medium') {
      return const Color(0xFFF79009);
    } else if (priorityLower == 'low') {
      return const Color(0xFF12B76A);
    }
    return Colors.grey;
  }
}