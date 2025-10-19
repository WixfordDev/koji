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
        width: 293.w,
        height: 350.h,
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: CustomText(
                  text: "You finished your 2:00 PM shift.",
                  color: Colors.grey.shade600,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            CustomText(
              text: title,
              color: AppColor.secondaryColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                CustomText(
                  text: "Category:",
                  color: Colors.grey.shade600,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(width: 6.w),
                CustomText(
                  text: category,
                  color: AppColor.secondaryColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                CustomText(
                  text: "Time:",
                  color: Colors.grey.shade600,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(width: 6.w),
                CustomText(
                  text: time,
                  color: AppColor.secondaryColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                CustomText(
                  text: "Break:",
                  color: Colors.grey.shade600,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(width: 6.w),
                CustomText(
                  text: breakTime,
                  color: AppColor.secondaryColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // avatar row
                Row(
                  children: [
                    for (int i = 0; i < 3; i++)
                      Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: CircleAvatar(
                          radius: 14.r,
                          backgroundImage:
                          const AssetImage("assets/images/profile.jpg"),
                        ),
                      ),
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: CustomText(
                        text: "+2",
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // completed tag
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: CustomText(
                    text: completed ? "• Completed" : "• Pending",
                    color: completed
                        ? Colors.grey.shade700
                        : AppColor.primaryColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
