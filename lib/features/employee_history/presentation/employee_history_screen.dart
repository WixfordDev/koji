import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../../constants/app_color.dart';
import '../../../controller/employee_history_controller.dart';
import '../../../shared_widgets/custom_text.dart';
import '../../../shared_widgets/history-widget.dart';
import 'taskreport_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final EmployeeHistoryController controller = Get.put(
    EmployeeHistoryController(),
  );

  @override
  void dispose() {
    controller.taskList.value = [];
    super.dispose();
  }

  @override
  void initState() {
    controller.fetchTaskList();
    super.initState();
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              text: "Task History",
              color: AppColor.secondaryColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter tabs
              SizedBox(height: 16.h),
              _buildStatusFilter(),

              // Date and filter row
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text:
                          "Today, ${DateTime.now().day} ${DateTime.now().month.toString()}",
                      color: AppColor.secondaryColor,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    Obx(() {
                      return GestureDetector(
                        onTap: () {
                          _showFilterDialog();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColor.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_alt_outlined,
                                size: 18.sp,
                                color: AppColor.primaryColor,
                              ),
                              SizedBox(width: 6.w),
                              CustomText(
                                text: _getDisplayTextForStatus(
                                  controller.selectedStatus.value,
                                ),
                                color: AppColor.primaryColor,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColor.primaryColor,
                                size: 16.sp,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Task count summary
              Container(
                padding: EdgeInsets.all(12.w),
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          CustomText(
                            text: "Total Tasks",
                            color: AppColor.secondaryColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(height: 4.h),
                          CustomText(
                            text: controller.taskList.length.toString(),
                            color: AppColor.primaryColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          CustomText(
                            text: "Completed",
                            color: AppColor.secondaryColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(height: 4.h),
                          CustomText(
                            text: controller.taskList
                                .where(
                                  (task) =>
                                      task.status?.toLowerCase() ==
                                          'completed' ||
                                      task.status?.toLowerCase() == 'done',
                                )
                                .length
                                .toString(),
                            color: Colors.green,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          CustomText(
                            text: "Pending",
                            color: AppColor.secondaryColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(height: 4.h),
                          CustomText(
                            text: controller.taskList
                                .where(
                                  (task) =>
                                      task.status?.toLowerCase() == 'pending',
                                )
                                .length
                                .toString(),
                            color: Colors.orange,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Task list
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.taskList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_outlined,
                            size: 64.sp,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16.h),
                          CustomText(
                            text: "No tasks found",
                            color: Colors.grey.shade600,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(height: 8.h),
                          CustomText(
                            text: "Your task history will appear here",
                            color: Colors.grey.shade500,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.fetchTaskList(),
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 20.h),
                      itemCount: controller.taskList.length,
                      itemBuilder: (context, index) {
                        final task = controller.taskList[index];

                        // Map task status to completed flag
                        bool isCompleted =
                            task.status?.toLowerCase() == 'completed' ||
                            task.status?.toLowerCase() == 'done';

                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          child: HistoryCardWidget(
                            title: task.customerName ?? "",
                            category: task.serviceCategory?.name ?? "",
                            // time: "${task.assignDate?.split('T')[0]} - ${task.deadline.split('T')[0]}",
                            time: "2:00 AM - 3:00 AM",
                            breakTime:
                                task.notes ??
                                "", // Using notes as break time placeholder
                            completed: isCompleted,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TaskReportScreen(taskId: task.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Obx(() {
      return Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            _buildStatusTab("All", "", controller.selectedStatus.value == ""),
            _buildStatusTab(
              "Pending",
              "pending",
              controller.selectedStatus.value == "pending",
            ),
            _buildStatusTab(
              "Done",
              "completed",
              controller.selectedStatus.value == "completed",
            ),
            _buildStatusTab(
              "In Progress",
              "in_progress",
              controller.selectedStatus.value == "in_progress",
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatusTab(String label, String value, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.updateStatusFilter(value),
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(vertical: 4.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: CustomText(
            text: label,
            color: isSelected ? AppColor.primaryColor : Colors.grey.shade600,
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _getDisplayTextForStatus(String status) {
    switch (status) {
      case 'pending':
        return "Pending";
      case 'completed':
        return "Done";
      case 'in_progress':
        return "In Progress";
      default:
        return "All";
    }
  }

  void _showFilterDialog() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: "Filter by Status",
              color: AppColor.secondaryColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 16.h),
            _buildFilterOption("All", ""),
            _buildFilterOption("Pending", "pending"),
            _buildFilterOption("Completed", "completed"),
            _buildFilterOption("In Progress", "in_progress"),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: CustomText(
                text: "Close",
                color: Colors.grey.shade600,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) {
    return Obx(() {
      bool isSelected = controller.selectedStatus.value == value;
      return ListTile(
        title: Text(label),
        trailing: isSelected
            ? Icon(Icons.check, color: AppColor.primaryColor)
            : null,
        selected: isSelected,
        selectedColor: AppColor.primaryColor,
        onTap: () {
          controller.updateStatusFilter(value);
          Get.back();
        },
      );
    });
  }
}
