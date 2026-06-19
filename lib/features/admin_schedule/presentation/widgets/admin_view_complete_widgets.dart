import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_color.dart';
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

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('submit') || s.contains('complete')) return Colors.green;
    if (s.contains('progress')) return Colors.orange;
    return Colors.orange;
  }

  Color _getStatusBorderColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('submit') || s.contains('complete')) return Colors.green.shade200;
    return Colors.orange.shade200;
  }

  Color _getStatusLightColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('submit') || s.contains('complete')) return Colors.green.shade50;
    return Colors.orange.shade50;
  }

  Color _getStatusDarkColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('submit') || s.contains('complete')) return Colors.green.shade700;
    return Colors.orange.shade700;
  }

  String _getStatusText(String status) {
    final s = status.toLowerCase();
    if (s.contains('submit') || s.contains('complete')) return 'Completed';
    if (s.contains('progress')) return 'In Progress';
    if (s.contains('pending')) return 'Pending';
    return status;
  }

  IconData _getStatusIcon(String status) {
    final s = status.toLowerCase();
    if (s.contains('submit') || s.contains('complete')) return Icons.check_circle_outline;
    if (s.contains('progress')) return Icons.hourglass_bottom;
    return Icons.pending_outlined;
  }

  Color _getPriorityColor(String priority) {
    final p = priority.toLowerCase();
    if (p == 'high') return const Color(0xFFF04438);
    if (p == 'medium') return const Color(0xFFF79009);
    if (p == 'low') return const Color(0xFF12B76A);
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _getStatusBorderColor(status), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: serial + name + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (serialNumber != null) ...[
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$serialNumber',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                Expanded(
                  child: CustomText(
                    textAlign: TextAlign.start,
                    text: taskTitle,
                    color: AppColor.secondaryColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusLightColor(status),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: _getStatusBorderColor(status), width: 1),
                  ),
                  child: CustomText(
                    text: _getStatusText(status),
                    color: _getStatusDarkColor(status),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Service row
            _buildInfoRow(
              icon: Icons.miscellaneous_services_outlined,
              title: 'Service',
              value: userName,
            ),
            SizedBox(height: 8.h),

            // Date row
            _buildInfoRow(
              icon: Icons.calendar_today,
              title: 'Date',
              value: date,
            ),
            SizedBox(height: 8.h),

            // Time row
            _buildInfoRow(
              icon: Icons.access_time_outlined,
              title: 'Time',
              value: time,
            ),

            SizedBox(height: 12.h),

            // Bottom progress container
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _getStatusLightColor(status),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        color: _getStatusColor(status),
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      CustomText(
                        text: 'Progress',
                        color: _getStatusDarkColor(status),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  CustomText(
                    text: '${progressPercentage.toInt()}%',
                    color: _getStatusColor(status),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColor.primaryColor, size: 16.sp),
        SizedBox(width: 8.w),
        CustomText(
          text: '$title: ',
          color: Colors.grey.shade600,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        Expanded(
          child: CustomText(
            text: value,
            color: AppColor.secondaryColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
