import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_color.dart';
import '../../../controller/admincontroller/schedule_controller.dart';
import '../../../models/admin-model/task_details_model.dart';
import '../../../shared_widgets/admin_task_complete.dart';
import '../../../shared_widgets/custom_text.dart';

class AdminCompleteTaskScreen extends StatefulWidget {
  final String? taskId;

  const AdminCompleteTaskScreen({super.key, this.taskId});

  @override
  State<AdminCompleteTaskScreen> createState() => _AdminCompleteTaskScreenState();
}

class _AdminCompleteTaskScreenState extends State<AdminCompleteTaskScreen> {
  late ScheduleController scheduleController;

  @override
  void initState() {
    super.initState();
    scheduleController = Get.find<ScheduleController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.taskId != null && widget.taskId!.isNotEmpty) {
        scheduleController.getTaskDetails(widget.taskId!);
      }
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
              text: "Task Details",
              color: AppColor.secondaryColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (scheduleController.taskDetailsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          TaskDetailsModel? taskDetails = scheduleController.taskDetailsData.value;
          if (taskDetails == null) {
            return const Center(child: Text('No task details available'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Information Card
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Customer Name:', taskDetails.customerName ?? 'N/A'),
                      _buildInfoRow('Customer Number:', taskDetails.customerNumber ?? 'N/A'),
                      _buildInfoRow('Customer Address:', taskDetails.customerAddress ?? 'N/A'),
                      _buildInfoRow('Assign Date:',
                        taskDetails.assignDate != null
                          ? DateFormat('MMM dd, yyyy').format(taskDetails.assignDate!)
                          : 'N/A'),
                      _buildInfoRow('Deadline:',
                        taskDetails.deadline != null
                          ? DateFormat('MMM dd, yyyy').format(taskDetails.deadline!)
                          : 'N/A'),
                      _buildInfoRow('Priority:', taskDetails.priority ?? 'N/A'),
                      _buildInfoRow('Difficulty:', taskDetails.difficulty ?? 'N/A'),
                      _buildInfoRow('Status:', taskDetails.status ?? 'N/A'),
                      _buildInfoRow('Total Amount:', '৳${taskDetails.totalAmount?.toStringAsFixed(2) ?? '0.00'}'),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // AdminTaskCompleteCard
                const AdminTaskCompleteCard(),

                SizedBox(height: 20.h),

                // Services Card
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Services',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.secondaryColor,
                      ),
                      SizedBox(height: 12.h),
                      ..._buildServiceItems(taskDetails.services ?? []),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Assigned To Card
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Assigned To',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.secondaryColor,
                      ),
                      SizedBox(height: 12.h),
                      _buildAssigneeInfo(taskDetails.assignTo),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Notes Card
                if (taskDetails.notes != null && taskDetails.notes!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Notes',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.secondaryColor,
                        ),
                        SizedBox(height: 12.h),
                        CustomText(
                          text: taskDetails.notes ?? 'N/A',
                          fontSize: 14.sp,
                          color: AppColor.textColor,
                        ),
                      ],
                    ),
                  ),

                // Download Task Report Button
                if (taskDetails.invoicePath != null && taskDetails.invoicePath!.isNotEmpty)
                  Column(
                    children: [
                      SizedBox(height: 30.h),
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            backgroundColor: const Color(0xFFEC526A),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          icon: const Icon(Icons.download, color: Colors.white),
                          label: const Text(
                            "Download Task Report",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            // Add download functionality
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: CustomText(
              text: label,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.textColor666666,
            ),
          ),
          Expanded(
            child: CustomText(
              text: value,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColor.textColor,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildServiceItems(List<Service> services) {
    return services.map((service) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomText(
                text: service.name ?? 'N/A',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColor.textColor,
              ),
            ),
            Expanded(
              child: CustomText(
                text: 'Qty: ${service.quantity ?? 0}',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColor.textColor,
              ),
            ),
            Expanded(
              child: CustomText(
                text: '৳${service.price?.toStringAsFixed(2) ?? '0.00'}',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColor.textColor,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildAssigneeInfo(AssignTo? assignTo) {
    if (assignTo == null) {
      return CustomText(text: 'N/A', fontSize: 14.sp);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: assignTo.fullName ?? 'N/A',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColor.textColor,
        ),
        SizedBox(height: 4.h),
        if (assignTo.email != null)
          CustomText(
            text: assignTo.email!,
            fontSize: 12.sp,
            color: AppColor.textColor666666,
          ),
        if (assignTo.phoneNumber != null)
          CustomText(
            text: assignTo.phoneNumber!,
            fontSize: 12.sp,
            color: AppColor.textColor666666,
          ),
      ],
    );
  }
}
