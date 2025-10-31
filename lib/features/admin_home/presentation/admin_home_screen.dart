import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage('assets/profile.png'),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Parvej Hossain", style: AppTextStyle.semiBold(16.sp)),
                  Text(
                    "Admin",
                    style: AppTextStyle.regular(
                      12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.notifications_none_rounded, color: Colors.black),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoCard(
                      title: "Total Employee",
                      value: "1502",
                      color: Colors.red,
                      icon: Icons.person,
                    ),
                    _buildInfoCard(
                      title: "Attendance",
                      value: "96%",
                      color: Colors.blue,
                      icon: Icons.group,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                Text("Quick Action", style: AppTextStyle.semiBold(16.sp)),
                SizedBox(height: 12.h),

                /// Quick Action Cards
                Wrap(
                  spacing: 14.w,
                  runSpacing: 14.h,
                  children: [
                    _buildQuickCard("Task\nManage", [
                      const Color(0xFFF9B128),
                      const Color(0xFFF48201),
                    ], Icons.task_alt_rounded),
                    _buildQuickCard("Employee\nRequest", [
                      const Color(0xFF136AB7),
                      const Color(0xFF2D8BE5),
                    ], Icons.assignment_ind_rounded),
                    _buildQuickCard("View\nAttendence", [
                      const Color(0xFFEC526A),
                      const Color(0xFFF77F6E),
                    ], Icons.calendar_month_rounded),
                    _buildQuickCard("Transaction\nReport", [
                      const Color(0xFFB060F6),
                      const Color(0xFFE6AAF5),
                    ], Icons.receipt_long_rounded),
                  ],
                ),

                SizedBox(height: 24.h),

                Text(
                  "Today’s Attendance Summary",
                  style: AppTextStyle.semiBold(15.sp),
                ),
                SizedBox(height: 10.h),

                _buildSummaryCard([
                  _summaryRow(
                    "Employees Arrived On Time",
                    "1050",
                    Colors.green,
                  ),
                  _summaryRow("Late Comers Today", "120", Colors.orange),
                  _summaryRow("Absent Employees Today", "50", Colors.red),
                  _summaryRow("Working Employees Today", "1200", Colors.blue),
                ]),

                SizedBox(height: 20.h),

                Text(
                  "Today’s Task Summary",
                  style: AppTextStyle.semiBold(15.sp),
                ),
                SizedBox(height: 10.h),

                _buildSummaryCard([
                  _summaryRow("Total Task", "20", Colors.green),
                  _summaryRow("Complete Task", "05", Colors.orange),
                  _summaryRow("Pending Task", "15", Colors.red),
                  _summaryRow("In - Progress Task", "09", Colors.blue),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 165.w,
      height: 100.h,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: 10.w),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTextStyle.medium(12.sp)),
                Text(value, style: AppTextStyle.bold(18.sp, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard(String title, List<Color> gradient, IconData icon) {
    return Container(
      width: 165.w,
      height: 220.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 2, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 40.sp),
              Text(
                title,
                style: AppTextStyle.semiBold(16.sp, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children
            .map(
              (child) => Column(
                children: [
                  child,
                  Divider(thickness: 0.4, color: Colors.grey[300]),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _summaryRow(String title, String value, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 10.sp),
        SizedBox(width: 8.w),
        Expanded(child: Text(title, style: AppTextStyle.medium(13.sp))),
        Text(value, style: AppTextStyle.semiBold(13.sp, color: color)),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    );
  }
}

class AppTextStyle {
  static TextStyle regular(double size, {Color color = Colors.black}) =>
      TextStyle(fontSize: size, fontWeight: FontWeight.w400, color: color);

  static TextStyle medium(double size, {Color color = Colors.black}) =>
      TextStyle(fontSize: size, fontWeight: FontWeight.w500, color: color);

  static TextStyle semiBold(double size, {Color color = Colors.black}) =>
      TextStyle(fontSize: size, fontWeight: FontWeight.w600, color: color);

  static TextStyle bold(double size, {Color color = Colors.black}) =>
      TextStyle(fontSize: size, fontWeight: FontWeight.w700, color: color);
}
