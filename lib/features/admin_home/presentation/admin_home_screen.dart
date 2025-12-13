import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/shared_widgets/custom_text.dart';

import '../../../constants/app_color.dart';
import '../../../controller/admincontroller/admin_home_controller.dart';
import '../../../global/custom_assets/assets.gen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});



  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {

  late AdminHomeController adminHomeController;

  @override
  void initState() {
    super.initState();
    adminHomeController = Get.find<AdminHomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adminHomeController.getAllAttendanceSummary();
      adminHomeController.getAllTaskSummary();

    });
  }

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
                backgroundImage: AssetImage('assets/images/profile.png'),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "Parvej Hossain",
                    color: AppColor.secondaryColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  CustomText(text:
                    "Admin",
                    color: AppColor.textColor4F4F4F,
                    fontSize: 12.sp,
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
            child: Obx(() {
              // Check if data is available
              final attendanceSummary = adminHomeController.allAttendanceSummary.value;
              final taskSummary = adminHomeController.allTaskSummary.value;

              bool isDataAvailable =
                  (attendanceSummary.totalEmployees != null && attendanceSummary.totalEmployees! > 0) ||
                  (attendanceSummary.employeesArrivedOnTime != null) ||
                  (attendanceSummary.lateComersToday != null) ||
                  (attendanceSummary.absentEmployeesToday != null) ||
                  (attendanceSummary.workingEmployeesToday != null) ||
                  (taskSummary.totalTask != null) ||
                  (taskSummary.completeTask != null) ||
                  (taskSummary.pendingTask != null) ||
                  (taskSummary.inProgressTask != null);

              if (!isDataAvailable) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 60.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        CustomText(
                          text: "No Data Available",
                          color: Colors.grey[600]!,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 8.h),
                        CustomText(
                          text: "There is no data to display at the moment.",
                          color: Colors.grey[500]!,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Top Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(
                        title: "Total Employee",
                        value: "${adminHomeController.allAttendanceSummary.value.totalEmployees ?? 'N/A'}",
                        color: Colors.red,
                        icon: Assets.icons.totalemployee.svg(height: 30.h, width: 30.w,),
                      ),
                      _buildInfoCard(
                        title: "Attendance",
                        value: "${adminHomeController.allAttendanceSummary.value.totalEmployees ?? 'N/A'} %",
                        color: Colors.blue,
                        icon: Assets.icons.attendanceicon.svg(height: 30.h, width: 30.w),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  CustomText(
                    text: "Quick Action",
                    color: AppColor.secondaryColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 12.h),

                  /// Quick Action Cards
                  Wrap(
                    spacing: 14.w,
                    runSpacing: 14.h,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.push("/adminMyTaskScreen");
                        },
                        child: _buildQuickCard("Task\nManage", [
                          const Color(0xFFF9B128),
                          const Color(0xFFF48201),
                        ], Assets.icons.taskmanager.svg(height: 40.h, width: 40.w),),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push("/adminEmployeeRequestScreen");
                        },
                        child: _buildQuickCard("Employee\nRequest", [
                          const Color(0xFF136AB7),
                          const Color(0xFF2D8BE5),
                        ], Assets.icons.employeerequest.svg(height: 40.h, width: 40.w),),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push("/adminAttendanceScreen");
                        },
                        child: _buildQuickCard("View\nAttendence", [
                          const Color(0xFFEC526A),
                          const Color(0xFFF77F6E),
                        ], Assets.icons.viewattendance.svg(height: 40.h, width: 40.w),),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push("/adminTransactionScreen");
                        },
                        child: _buildQuickCard("Transaction\nReport", [
                          const Color(0xFFB060F6),
                          const Color(0xFFE6AAF5),
                        ], Assets.icons.transaction.svg(height: 40.h, width: 40.w),),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

               /// =============================> Today Attendance Summary =====================>
                  Text(
                    "Today’s Attendance Summary",
                    style: AppTextStyle.semiBold(15.sp),),

                  SizedBox(height: 10.h),

                  _buildSummaryCard([
                    _summaryRow("Employees Arrived On Time", "${adminHomeController.allAttendanceSummary.value.employeesArrivedOnTime ?? 'N/A'}", Colors.green,),
                    _summaryRow("Late Comers Today", "${adminHomeController.allAttendanceSummary.value.lateComersToday ?? 'N/A'}", Colors.orange),
                    _summaryRow("Absent Employees Today", "${adminHomeController.allAttendanceSummary.value.absentEmployeesToday ?? 'N/A'}", Colors.red),
                    _summaryRow("Working Employees Today", "${adminHomeController.allAttendanceSummary.value.workingEmployeesToday ?? 'N/A'}", Colors.blue),
                  ]),

                  SizedBox(height: 20.h),

                  /// ===========================> Today Task Summary ============================>


                  Text(
                    "Today’s Task Summary",
                    style: AppTextStyle.semiBold(15.sp),
                  ),
                  SizedBox(height: 10.h),

                  _buildSummaryCard([
                    _summaryRow("Total Task", "${adminHomeController.allTaskSummary.value.totalTask ?? 'N/A'}", Colors.green),
                    _summaryRow("Complete Task", "${adminHomeController.allTaskSummary.value.completeTask ?? 'N/A'}", Colors.orange),
                    _summaryRow("Pending Task", "${adminHomeController.allTaskSummary.value.pendingTask ?? 'N/A'}", Colors.red),
                    _summaryRow("In - Progress Task", "${adminHomeController.allTaskSummary.value.inProgressTask ?? 'N/A'}", Colors.blue),
                  ]),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required Color color,
    required Widget icon,
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
            child: icon,
          ),
          SizedBox(width: 10.w),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTextStyle.medium(10.sp)),
                Text(value, style: AppTextStyle.bold(16.sp, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard(String title, List<Color> gradient, Widget icon) {
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
              icon,
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
