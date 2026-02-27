import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/features/admin_home/presentation/widget/custom_loader.dart';
import '../../../constants/app_color.dart';
import '../../../controller/admincontroller/admin_home_controller.dart';
import '../../../services/api_constants.dart';
import '../../../shared_widgets/custom_text.dart';
import 'admin_view_attendance_screen.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {


  late AdminHomeController adminHomeController;

  @override
  void initState() {
    super.initState();
    adminHomeController = Get.find<AdminHomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adminHomeController.getAdminAllAttendance();

    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.r),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 12.w),
            CustomText(
              text: "Attendance",
              color: AppColor.secondaryColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Search & Month
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey, size: 23.r),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: TextField(
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                hintText: "Search",
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintStyle: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    height: 40.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: "November",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(width: 6.w),
                        Icon(Icons.calendar_today_outlined,
                            color: Colors.black, size: 18.r),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              Obx(() {
                final data = adminHomeController.allAttendance.value;
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSummaryCard(
                      "${data.totalPresent ?? 0}",
                      "Present",
                      const Color(0xFFC4EAD5),
                      const Color(0xFF31712B),
                    ),
                    _buildSummaryCard(
                      "${data.totalAbsent ?? 0}",
                      "Absent",
                      const Color(0xFFD2E8F8),
                      const Color(0xFF0B59A1),
                    ),
                    _buildSummaryCard(
                      "${data.totalLateIn ?? 0}",
                      "Late In",
                      const Color(0xFFF3E8C1),
                      const Color(0xFFE3A607),
                    ),
                    _buildSummaryCard(
                      "${data.totalEarlyOut ?? 0}",
                      "Early Out",
                      const Color(0xFFFCCCCC),
                      const Color(0xFFEE3E3E),
                    ),
                  ],
                );
              }),

              SizedBox(height: 20.h),

              /// Status Filter
              Row(
                children: [
                  _buildStatusChip("Pending", selectedStatus == "Pending"),
                  SizedBox(width: 10.w),
                  _buildStatusChip("Approved", selectedStatus == "Approved"),
                  SizedBox(width: 10.w),
                  _buildStatusChip("Reject", selectedStatus == "Reject"),
                ],
              ),
              SizedBox(height: 20.h),

              /// Employee List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: "Employee List",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CustomText(
                          text: "Department",
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                        Icon(Icons.keyboard_arrow_down, size: 20.r),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              /// ===========================>  Employee Cards ===========================>
              Obx(() {
                if (adminHomeController.getAdminAllAttendanceLoading.value) {
                  return const Center(child: CustomLoader());
                }

                final attendanceList = adminHomeController.allAttendance.value.results ?? [];
                return ListView.builder(
                  itemCount: attendanceList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final attendance = attendanceList[index];

                    // Format time from DateTime
                    String checkInTime = attendance.clockIn != null
                        ? "${attendance.clockIn!.hour}:${attendance.clockIn!.minute.toString().padLeft(2, '0')}"
                        : "N/A";

                    String checkOutTime = attendance.clockOut != null
                        ? "${attendance.clockOut!.hour}:${attendance.clockOut!.minute.toString().padLeft(2, '0')}"
                        : "N/A";

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminViewAttendanceScreen(
                              employeeName: attendance.employee?.fullName ?? "Unknown",
                              role: attendance.employee?.role ?? "N/A",
                              employeeId: attendance.employee?.id ?? "",
                              image: attendance.employee?.image,
                              checkIn: checkInTime,
                              breakTime: "N/A", // Placeholder - you may want to implement break time logic
                              checkOut: checkOutTime,
                            ),
                          ),
                        );
                      },
                      child: _buildEmployeeCard(
                        attendance.employee?.fullName ?? "Unknown",
                        attendance.employee?.role ?? "N/A",
                        checkInTime,
                        checkOutTime,
                        attendance.employee?.image,
                      ),
                    );
                  },
                );
              })

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String count,
      String label,
      Color bgColor,
      Color topShadowColor,
      ) {
    return Container(
      width: 172.w,
      height: 90.h,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9.29.r),
        boxShadow: [
          BoxShadow(
            color: topShadowColor.withOpacity(0.75),
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              text: count,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0B2750), // dark navy text color
            ),
            SizedBox(height: 4.h),
            CustomText(
              text: label,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0B2750),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedStatus = text),
      child: Container(
        padding:
        EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFFEC526A), Color(0xFFF77F6E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: !isSelected ? Colors.white : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: CustomText(
          text: text,
          fontSize: 14.sp,
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(
      String name, String role, String checkIn, String checkOut, String? imageUrl) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [


          CircleAvatar(
            radius: 25,
            backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                ? NetworkImage(_getImageUrl(imageUrl))
                : AssetImage('assets/images/profile.png') as ImageProvider,
            child: imageUrl == null || imageUrl.isEmpty
                ? Icon(Icons.person)
                : null,
          ),

          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: name,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  text: role,
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    CustomText(
                      text: "Check In: ",
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                    CustomText(
                      text: checkIn,
                      fontSize: 10.sp,
                      color: Colors.green,
                    ),
                    CustomText(
                      text: " | Check Out: ",
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                    CustomText(
                      text: checkOut,
                      fontSize: 10.sp,
                      color: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.person_outline, color: Colors.redAccent),
        ],
      ),
    );
  }

  String selectedStatus = 'Pending';


  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';

    // If already a full URL, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // Otherwise, prepend your base URL
    String baseUrl = ApiConstants.imageBaseUrl; // Your API base URL
    return "$baseUrl$imageUrl";
  }


}
