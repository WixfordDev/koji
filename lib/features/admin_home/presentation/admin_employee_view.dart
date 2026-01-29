import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/controller/admincontroller/admin_home_controller.dart';
import 'package:koji/models/admin-model/all_employee_model.dart';
import 'package:koji/shared_widgets/custom_network_image.dart';
import 'package:koji/helpers/toast_message_helper.dart';

class AdminEmployeeView extends StatefulWidget {
  final Employee employee;

  const AdminEmployeeView({super.key, required this.employee});

  @override
  State<AdminEmployeeView> createState() => _AdminEmployeeViewState();
}

class _AdminEmployeeViewState extends State<AdminEmployeeView> {
  bool isPersonalDetailsExpanded = true;
  bool isContactInfoExpanded = false;
  bool isServiceDetailsExpanded = false;
  bool isShiftChangeExpanded = false;

  @override
  Widget build(BuildContext context) {
    final adminHomeController = Get.find<AdminHomeController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Employee Details',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // Employee Profile Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 100.w,
                      width: 100.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade300,
                      ),
                      child: ClipOval(
                        child: CustomNetworkImage(
                          imageUrl: widget.employee.image ?? '',
                          height: 100.w,
                          width: 100.w,
                          boxShape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      widget.employee.fullName ?? widget.employee.firstName ?? 'N/A',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.employee.role ?? 'employee',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Personal Details Section
              _buildExpandableSection(
                title: "Personal Details",
                isExpanded: isPersonalDetailsExpanded,
                onTap: () {
                  setState(() {
                    isPersonalDetailsExpanded = !isPersonalDetailsExpanded;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Personal Information",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          _buildInfoRow("Employee Code", widget.employee.id?.substring(0, 12) ?? "Koji Tech 123"),
                          _buildDivider(),
                          _buildInfoRow("Gender", widget.employee.gender ?? "N/A"),
                          _buildDivider(),
                          _buildInfoRow("Date of Birth", "01 January 2000"),
                          _buildDivider(),
                          _buildInfoRow("Marital Status", "Unmarried"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Contact Information Section
              _buildExpandableSection(
                title: "Contact Information",
                isExpanded: isContactInfoExpanded,
                onTap: () {
                  setState(() {
                    isContactInfoExpanded = !isContactInfoExpanded;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow("Email", widget.employee.email ?? "N/A"),
                      _buildDivider(),
                      _buildInfoRow("Phone", widget.employee.phoneNumber ?? "N/A"),
                      _buildDivider(),
                      _buildInfoRow("Address", widget.employee.address?.toString() ?? "N/A"),
                      _buildDivider(),
                      _buildInfoRow("Location", widget.employee.location?.locationName ?? "N/A"),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Service Details Section
              _buildExpandableSection(
                title: "Service Details",
                isExpanded: isServiceDetailsExpanded,
                onTap: () {
                  setState(() {
                    isServiceDetailsExpanded = !isServiceDetailsExpanded;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow("Role", widget.employee.role ?? "N/A"),
                      _buildDivider(),
                      _buildInfoRow("Shift", widget.employee.shift ?? "N/A"),
                      _buildDivider(),
                      _buildInfoRow("Created Date", widget.employee.createdAt != null
                          ? '${widget.employee.createdAt!.day}/${widget.employee.createdAt!.month}/${widget.employee.createdAt!.year}'
                          : 'N/A'),
                      _buildDivider(),
                      _buildInfoRow("Profile Completed", widget.employee.isProfileCompleted?.toString() ?? "false"),
                      _buildDivider(),
                      _buildInfoRow("Admin Approved", widget.employee.isAdminApproved?.toString() ?? "true"),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Shift Change Section
              _buildExpandableSection(
                title: "Shift Change",
                isExpanded: isShiftChangeExpanded,
                onTap: () {
                  setState(() {
                    isShiftChangeExpanded = !isShiftChangeExpanded;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow("Current Shift", widget.employee.shift ?? "N/A"),
                      _buildDivider(),
                      _buildInfoRow("Available Shifts", "Morning, Evening, Night"),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 100.h), // Space for bottom buttons
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Reject Button
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: Color(0xFFEB0000)),
                  ),
                  child: Center(
                    child: Text(
                      "Reject",
                      style: TextStyle(
                        color: Color(0xFFEB0000),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Accept Button
            Expanded(
              child: Obx(() => GestureDetector(
                onTap: adminHomeController.approveEmployeeLoading.value
                    ? null
                    : () async {
                  bool result = await adminHomeController.approveEmployee(
                    employeeId: widget.employee.id ?? '',
                  );
                  if (result) {
                    ToastMessageHelper.showToastMessage(
                      "Employee approved successfully!",
                    );
                    Navigator.pop(context);
                  } else {
                    ToastMessageHelper.showToastMessage(
                      "Failed to approve employee.",
                      title: "Error",
                    );
                  }
                },
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFEC526A),
                        Color(0xFFF77F6E),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: adminHomeController.approveEmployeeLoading.value
                        ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      "Accept",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[200],
      thickness: 1,
      height: 1,
    );
  }
}