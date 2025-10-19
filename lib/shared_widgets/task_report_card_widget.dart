import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/app_color.dart';
import '../../../../shared_widgets/custom_text.dart';

class TaskReportCard extends StatelessWidget {
  const TaskReportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F9EE),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: const Text(
                "You Finished Your 2:00 PM Shift.",
                style: TextStyle(
                  color: Color(0xFF249E58),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: "Handy Man Staff",
            color: AppColor.secondaryColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 10.h),
          buildRow("Category:", "Plumbing Service"),
          buildRow("Service List:", "Plumbing Service\nPlumbing Service\nPlumbing Service"),
          buildRow("Customer Name:", "Najibur Rahman"),
          buildRow("Customer Number:", "+6515484854"),
          buildRow("Customer Address:", "Dhaka, Bangladesh"),
          buildRow("Assign To:", "Koji Tech 123"),
          buildRow("Time:", "2:00 PM - 9:00 PM"),
          buildRow("Priority:", "Important"),
          buildRow("Difficulty:", "Medium"),
          buildRow("Invoice No.:", "#Koji6565418166"),
          buildRow("Amount:", "\$2500"),
          SizedBox(height: 8.h),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.asset('assets/images/task.png',
                    width: 40.w, height: 40.w, fit: BoxFit.cover),
              ),
              SizedBox(width: 6.w),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.asset('assets/images/task.png',
                    width: 40.w, height: 40.w, fit: BoxFit.cover),
              ),
              SizedBox(width: 6.w),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.asset('assets/images/task.png',
                    width: 40.w, height: 40.w, fit: BoxFit.cover),
              ),
              const Spacer(),
              Container(
                padding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F9EE),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: const Text(
                  "● Completed",
                  style: TextStyle(
                      color: Color(0xFF249E58),
                      fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 3,
              child: Text(
                title,
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500),
              )),
          Expanded(
              flex: 5,
              child: Text(
                value,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500),
              )),
        ],
      ),
    );
  }
}
