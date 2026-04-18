import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_color.dart';
import '../../../shared_widgets/custom_text.dart';

class HistoryCardWidget extends StatelessWidget {
  final String title;
  final String category;
  final String time;
  final String breakTime;
  final String status;
  final int progressPercent;
  final VoidCallback? onTap;

  const HistoryCardWidget({
    super.key,
    required this.title,
    required this.category,
    required this.time,
    required this.breakTime,
    this.status = 'pending',
    this.progressPercent = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status and colors based on the status string
    bool isCompleted = _isCompletedStatus(status);
    bool isInProgress = _isInProgressStatus(status);
    bool isPending = _isPendingStatus(status);

    Color statusColor = isCompleted
        ? Colors.green
        : isInProgress
        ? Colors.blue
        : Colors.orange;

    Color statusLightColor = isCompleted
        ? Colors.green.shade50
        : isInProgress
        ? Colors.blue.shade50
        : Colors.orange.shade50;

    Color statusLightBorderColor = isCompleted
        ? Colors.green.shade200
        : isInProgress
        ? Colors.blue.shade200
        : Colors.orange.shade200;

    Color statusDarkColor = isCompleted
        ? Colors.green.shade700
        : isInProgress
        ? Colors.blue.shade700
        : Colors.orange.shade700;

    String statusText = isCompleted
        ? "Completed"
        : isInProgress
        ? "In Progress"
        : "Pending";

    String progressText = "$progressPercent%";

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
          border: Border.all(color: statusLightBorderColor, width: 1),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomText(
                    textAlign: TextAlign.start,
                    text: title,
                    color: AppColor.secondaryColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusLightColor,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: statusLightBorderColor, width: 1),
                  ),
                  child: CustomText(
                    text: statusText,
                    color: statusDarkColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              icon: Icons.category_outlined,
              title: "Category",
              value: category,
            ),
            SizedBox(height: 8.h),
            _buildInfoRow(
              icon: Icons.calendar_today,
              title: "Date Range",
              value: time,
            ),
            SizedBox(height: 8.h),
            _buildInfoRow(
              icon: Icons.notes_outlined,
              title: "Notes",
              value: breakTime,
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: statusLightColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle_outline
                            : isInProgress
                            ? Icons.hourglass_bottom
                            : Icons.pending_outlined,
                        color: statusColor,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      CustomText(
                        text: "Progress",
                        color: statusDarkColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  CustomText(
                    text: progressText,
                    color: statusColor,
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

  bool _isCompletedStatus(String status) {
    final lowerStatus = status.toLowerCase();
    return lowerStatus == 'completed' ||
        lowerStatus == 'done' ||
        lowerStatus == 'finished';
  }

  bool _isInProgressStatus(String status) {
    final lowerStatus = status.toLowerCase();
    return lowerStatus == 'in_progress' ||
        lowerStatus == 'in progress' ||
        lowerStatus == 'progress' ||
        lowerStatus == 'submited' ||
        lowerStatus == 'submitted' ||
        lowerStatus == 'working';
  }

  bool _isPendingStatus(String status) {
    final lowerStatus = status.toLowerCase();
    return lowerStatus == 'pending' || lowerStatus == 'assigned';
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
          text: "$title: ",
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
