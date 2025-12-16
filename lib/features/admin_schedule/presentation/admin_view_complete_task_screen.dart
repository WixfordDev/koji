import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/controller/admincontroller/schedule_controller.dart';
import 'package:koji/features/admin_home/presentation/widget/custom_loader.dart';
import 'package:koji/features/admin_schedule/presentation/widgets/admin_view_complete_widgets.dart';
import '../../../constants/app_color.dart';
import '../../../routes/route_paths.dart';
import '../../../shared_widgets/custom_text.dart';
import '../../../models/admin-model/get_alllist_task_model.dart';

class AdminCompleteViewTaskScreen extends StatefulWidget {
  final String date;
  final String assignTo;

  const AdminCompleteViewTaskScreen({
    super.key,
    required this.date,
    required this.assignTo,
  });

  @override
  State<AdminCompleteViewTaskScreen> createState() => _AdminCompleteViewTaskScreenState();
}

class _AdminCompleteViewTaskScreenState extends State<AdminCompleteViewTaskScreen> {
  String selectedTab = 'All';
  late ScheduleController scheduleController;

  @override
  void initState() {
    super.initState();
    scheduleController = Get.find<ScheduleController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduleController.getEmployeeTasks(
        date: widget.date,
        assignTo: widget.assignTo,
      );
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
              text: "Complete View Task",
              color: AppColor.secondaryColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),

            // Tab Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Obx(() {
                // Calculate counts for each status
                final taskData = scheduleController.allTaskListData.value;
                final tasks = taskData?.results ?? [];

                int pendingCount = tasks.where((task) => _getStatusString(task.status) == 'pending').length;
                int progressCount = tasks.where((task) => _getStatusString(task.status) == 'progress').length;
                int completeCount = tasks.where((task) => _getStatusString(task.status) == 'submited').length;
                int allCount = tasks.length;

                return Row(
                  children: [
                    Expanded(child: _buildTab('All', allCount)),
                    SizedBox(width: 5.w),
                    Expanded(child: _buildTab('Pending', pendingCount)),
                    SizedBox(width: 5.w),
                    Expanded(child: _buildTab('InProgress', progressCount)),
                    SizedBox(width: 5.w),
                    Expanded(child: _buildTab('Complete', completeCount)),
                  ],
                );
              }),
            ),
            SizedBox(height: 16.h),

            // Task List with loading state
            Expanded(
              child: Obx(() {
                if (scheduleController.allTaskListDataLoading.value) {
                  return const Center(child: CustomLoader());
                }

                final taskData = scheduleController.allTaskListData.value;
                final allTasks = taskData?.results ?? [];

                // Filter tasks based on selected tab
                List<Result> filteredTasks = [];
                switch (selectedTab) {
                  case 'All':
                    filteredTasks = allTasks;
                    break;
                  case 'Pending':
                    filteredTasks = allTasks.where((task) => _getStatusString(task.status) == 'pending').toList();
                    break;
                  case 'InProgress':
                    filteredTasks = allTasks.where((task) => _getStatusString(task.status) == 'progress').toList();
                    break;
                  case 'Complete':
                    filteredTasks = allTasks.where((task) => _getStatusString(task.status) == 'submited').toList();
                    break;
                  default:
                    filteredTasks = allTasks;
                    break;
                }

                if (filteredTasks.isEmpty) {
                  return const Center(
                    child: Text('No tasks found'),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: filteredTasks.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    final services = task.services ?? [];
                    final serviceNames = services.map((s) => s.name ?? '').join(', ');

                    return TaskCard(
                      taskTitle: serviceNames.isEmpty ? 'No services' : serviceNames,
                      status: task.status?.toString() ?? 'Unknown',
                      time: task.assignDate?.toString() ?? 'N/A',
                      progressPercentage: (task.progressPercent ?? 0).toDouble(),
                      userName: task.customerName ?? 'N/A',
                      userImage: 'https://via.placeholder.com/40',
                      date: task.createdAt != null
                          ? '${task.createdAt!.day} ${getMonthAbbr(task.createdAt!.month)}'
                          : 'N/A',
                      priority: task.priority?.toString() ?? 'N/A',
                      difficulty: task.difficulty?.toString() ?? 'N/A',
                      onTap: () {
                        // Navigate to AdminCompleteTaskScreen with task ID
                        String taskId = task.id ?? '';
                        if (taskId.isNotEmpty) {
                          // Navigate to task details screen using GoRouter with query parameters
                          context.pushNamed(
                            RoutePaths.adminCompleteTaskScreen,
                            pathParameters: {
                              'taskId': taskId,
                            },
                          );
                        }
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String getMonthAbbr(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildTab(String title, int count) {
    final isSelected = selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = title;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEC526A), Color(0xFFF77F6E)],
          )
              : null,
          color: isSelected ? null : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: CustomText(
          text: count > 0 ? '$title ($count)' : title,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF667085),
        ),
      ),
    );
  }

  String _getStatusString(dynamic status) {
    if (status == null) return 'pending';
    return status.toString().split('.').last.toLowerCase();
  }
}