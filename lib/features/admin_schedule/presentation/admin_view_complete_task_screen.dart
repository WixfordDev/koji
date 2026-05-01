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

  // Helper method to format time to 12-hour format
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';

    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 8.w),
            CustomText(
              text: "View Task",
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

            // Tab Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Obx(() {
                // Calculate counts for each status
                final taskData = scheduleController.allTaskListData.value;
                final tasks = taskData?.results ?? [];

                int pendingCount = tasks.where((task) => _isPending(_getStatusString(task.status))).length;
                int progressCount = tasks.where((task) => _isInProgress(_getStatusString(task.status))).length;
                int completeCount = tasks.where((task) => _isCompleted(_getStatusString(task.status))).length;
                int allCount = tasks.length;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTab('All', allCount),
                      SizedBox(width: 8.w),
                      _buildTab('Pending', pendingCount),
                      SizedBox(width: 8.w),
                      _buildTab('InProgress', progressCount),
                      SizedBox(width: 8.w),
                      _buildTab('Complete', completeCount),
                    ],
                  ),
                );
              }),
            ),
            SizedBox(height: 20.h),

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
                    filteredTasks = allTasks.where((task) => _isPending(_getStatusString(task.status))).toList();
                    break;
                  case 'InProgress':
                    filteredTasks = allTasks.where((task) => _isInProgress(_getStatusString(task.status))).toList();
                    break;
                  case 'Complete':
                    filteredTasks = allTasks.where((task) => _isCompleted(_getStatusString(task.status))).toList();
                    break;
                  default:
                    filteredTasks = allTasks;
                    break;
                }

                if (filteredTasks.isEmpty) {
                  return Center(
                    child: Text(
                      'No tasks found',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: filteredTasks.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    final services = task.services ?? [];
                    final serviceNames = services.map((s) => s.name ?? '').join(', ');

                    return TaskCard(
                      serialNumber: index + 1,
                      taskTitle: task.customerName ?? 'N/A',
                      status: task.status?.toString() ?? 'Unknown',
                      time: _formatTime(task.assignDate),
                      progressPercentage: (task.progressPercent ?? 0).toDouble(),
                      userName: serviceNames.isEmpty ? 'No services' : serviceNames,
                      userImage: 'https://via.placeholder.com/40',
                      date: task.createdAt != null
                          ? '${task.createdAt!.day} ${getMonthAbbr(task.createdAt!.month)}'
                          : 'N/A',
                      priority: task.priority?.toString() ?? 'N/A',
                      difficulty: task.difficulty?.toString() ?? 'N/A',
                      onTap: () {
                        String taskId = task.id ?? '';
                        if (taskId.isNotEmpty) {
                          context.pushNamed(
                            'adminCompleteTaskScreenWithParams',
                            pathParameters: {'taskId': taskId},
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF95555) : const Color(0xFFEAECF0),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Text(
          count > 0 ? '$title ($count)' : title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF667085),
          ),
        ),
      ),
    );
  }

  String _getStatusString(dynamic status) {
    if (status == null) return 'pending';
    return status.toString().split('.').last.toLowerCase();
  }

  bool _isCompleted(String status) =>
      ['completed', 'submited', 'submitted', 'done', 'finished'].contains(status);

  bool _isInProgress(String status) =>
      ['progress', 'in_progress', 'inprogress', 'working'].contains(status);

  bool _isPending(String status) =>
      ['pending', 'assigned'].contains(status);
}