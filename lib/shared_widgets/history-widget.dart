import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_color.dart';
import '../../../shared_widgets/custom_text.dart';

class HistoryCardWidget extends StatelessWidget {
  final String title;
  final String category;
  final String time;
  final String breakTime;
  final bool completed;
  final VoidCallback? onTap;

  const HistoryCardWidget({
    super.key,
    required this.title,
    required this.category,
    required this.time,
    required this.breakTime,
    this.completed = true,
    this.onTap,
  });

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
          border: Border.all(
            color: completed ? Colors.green.shade200 : Colors.orange.shade200,
            width: 1,
          ),
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
                    text: title,
                    color: AppColor.secondaryColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: completed
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: completed
                          ? Colors.green.shade200
                          : Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: CustomText(
                    text: completed ? "Completed" : "Pending",
                    color: completed
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
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
                color: completed ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: completed ? Colors.green : Colors.orange,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      CustomText(
                        text: "Progress",
                        color: completed ? Colors.green.shade700 : Colors.orange.shade700,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  CustomText(
                    text: completed ? "100%" : "0%",
                    color: completed ? Colors.green : Colors.orange,
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

  Widget _buildInfoRow({required IconData icon, required String title, required String value}) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColor.primaryColor,
          size: 16.sp,
        ),
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