import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/features/admin_home/presentation/widget/custom_expenssion_list.dart';
import 'package:koji/models/admin-model/all_employee_model.dart';
import 'package:koji/shared_widgets/custom_network_image.dart';
import 'package:koji/shared_widgets/custom_text.dart';

class AdminEmployeeView extends StatelessWidget {
  final Employee employee;

  const AdminEmployeeView({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Employee Profile Section
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  children: [
                    Container(
                      height: 100.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade300,
                      ),
                      child: ClipOval(
                        child: CustomNetworkImage(
                          imageUrl: employee.image ?? '',
                          height: 100.h,
                          width: 100.w,
                          boxShape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      employee.fullName ?? employee.firstName ?? 'N/A',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      employee.role ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Employee Details Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem('Email', employee.email ?? 'N/A'),
                    _buildDetailItem('Phone', employee.phoneNumber ?? 'N/A'),
                    _buildDetailItem('Role', employee.role ?? 'N/A'),
                    _buildDetailItem('Gender', employee.gender ?? 'N/A'),
                    _buildDetailItem('Shift', employee.shift ?? 'N/A'),
                    _buildDetailItem('Address', employee.address?.toString() ?? 'N/A'),
                    _buildDetailItem('Location', employee.location?.locationName ?? 'N/A'),
                    _buildDetailItem('Created Date', employee.createdAt != null
                        ? '${employee.createdAt!.day}/${employee.createdAt!.month}/${employee.createdAt!.year}'
                        : 'N/A'),
                    _buildDetailItem('Profile Completed', employee.isProfileCompleted?.toString() ?? 'N/A'),
                    _buildDetailItem('Admin Approved', employee.isAdminApproved?.toString() ?? 'N/A'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        height: 80.h,
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.all(10.sp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: 50.h,
              width: 100.h,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text("Reject", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(width: 10.h),
            Container(
              alignment: Alignment.center,
              height: 50.h,
              width: 100.h,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text("Accept", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$title: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
