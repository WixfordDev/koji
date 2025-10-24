import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_color.dart';
import '../../../shared_widgets/custom_text.dart';

class ScheduleCard extends StatelessWidget {
  final String staffName;
  final String category;
  final String time;
  final String breakTime;
  final DateTime date;
  final bool isCompleted;
  final VoidCallback? onTap;

  const ScheduleCard({
    super.key,
    required this.staffName,
    required this.category,
    required this.time,
    required this.breakTime,
    required this.date,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 👈 Makes the entire card clickable
      child: Container(
        width: 357.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFCECECE).withOpacity(0.25)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000), // #0000001A
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== Date =====
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFCECECE).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  DateFormat('dd-MM-yyyy').format(date),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColor.secondaryColor,
                  ),
                ),
              ),
            ),

            SizedBox(height: 8.h),

            /// ===== Title & Category =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: staffName,
                  color: AppColor.secondaryColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                CustomText(
                  text: category,
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 14.sp,
                ),
              ],
            ),

            SizedBox(height: 8.h),

            /// ===== Time =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: 'Time:',
                  color: Colors.grey,
                  fontSize: 13.sp,
                ),
                CustomText(
                  text: time,
                  color: Colors.black,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),

            SizedBox(height: 4.h),

            /// ===== Break =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: 'Break:',
                  color: Colors.grey,
                  fontSize: 13.sp,
                ),
                CustomText(
                  text: breakTime,
                  color: Colors.black,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),

            SizedBox(height: 12.h),
            Divider(color: AppColor.textColorF4F4F5),

            /// ===== Status =====
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF4CD964).withOpacity(0.25)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? const Color(0xFF4CD964)
                            : Colors.redAccent,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      isCompleted ? "Completed" : "Pending",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: isCompleted
                            ? const Color(0xFF4CD964)
                            : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
