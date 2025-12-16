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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 356.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEC526A), Color(0xFFF77F6E)],
                  ),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Assets.icons.completename.svg()
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomText(
                   textAlign: TextAlign.start,
                  text: taskTitle,
                  fontSize: 14.sp,
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
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAECF0),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: CustomText(
                  text: status,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF344054),
                ),
              ),
              SizedBox(width: 6.w),

              // Time Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEC526A), Color(0xFFF77F6E)],
                  ),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white, size: 12),
                    SizedBox(width: 2.w),
                    CustomText(
                      text: time,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Percentage
              CustomText(
                text: '${progressPercentage.toInt()}%',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Progress Bar
          Container(
            width: double.infinity,
            height: 12.h,
            decoration: BoxDecoration(
              color: const Color(0xFFEAECF0),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Stack(
              children: [
                Container(
                  width: (332.w * progressPercentage / 100),
                  height: 12.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEC526A), Color(0xFFF77F6E)],
                    ),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          // Priority and Difficulty Row
          Row(
            children: [
              // Priority Badge
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: priority == 'high' ? const Color(0xFFFFE5E5) :
                          priority == 'medium' ? const Color(0xFFFFF4E6) :
                          const Color(0xFFF0FDF4), // Default for low or unknown
                    border: Border.all(
                      color: priority == 'high' ? const Color(0xFFD92D20) :
                            priority == 'medium' ? const Color(0xFFFFB800) :
                            const Color(0xFF4CD964), // Default for low or unknown
                    ),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        priority == 'high' ? Icons.priority_high :
                        priority == 'medium' ? Icons.warning :
                        Icons.low_priority,
                        size: 12,
                        color: priority == 'high' ? const Color(0xFFD92D20) :
                              priority == 'medium' ? const Color(0xFFFFB800) :
                              const Color(0xFF4CD964),
                      ),
                      SizedBox(width: 4.w),
                      CustomText(
                        text: 'Priority: $priority',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: priority == 'high' ? const Color(0xFFD92D20) :
                              priority == 'medium' ? const Color(0xFFFFB800) :
                              const Color(0xFF4CD964),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Difficulty Badge
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7FF),
                    border: Border.all(color: const Color(0xFF7ED3F6)),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.assessment,
                        size: 12,
                        color: const Color(0xFF2D8BE5),
                      ),
                      SizedBox(width: 4.w),
                      CustomText(
                        text: 'Difficulty: $difficulty',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2D8BE5),
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
                    radius: 14.r,
                    backgroundImage: NetworkImage(userImage),
                  ),
                  SizedBox(width: 8.w),
                  CustomText(
                    text: userName,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14.r,
                    color: const Color(0xFF98A2B3),
                  ),
                  SizedBox(width: 4.w),
                  CustomText(
                    text: date,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF667085),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.message_outlined,
                    size: 14.r,
                    color: const Color(0xFF98A2B3),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}