import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:koji/controller/employee_schedule_controller.dart';
import 'package:koji/features/employee_schedule/presentation/task_details_screen.dart';
import 'package:koji/models/task_model.dart' as TaskModel;
import 'package:koji/routes/route_paths.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final EmployeeScheduleController _employeeScheduleController = Get.put(
    EmployeeScheduleController(),
  );

  List<String> tabs = [];
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with today's date selected
    _selectedDay = DateTime.now();
    // Fetch tasks for the initial date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onDaySelected(_selectedDay!, _selectedDay!);
    });
  }

  void _updateTabs() {
    final allCount = _employeeScheduleController.getTaskCountByStatus('all');
    final pendingCount = _employeeScheduleController.getTaskCountByStatus(
      'pending',
    );
    final inProgressCount = _employeeScheduleController.getTaskCountByStatus(
      'inprogress',
    );
    final completedCount = _employeeScheduleController.getTaskCountByStatus(
      'complete',
    );

    setState(() {
      tabs = [
        "All ($allCount)",
        "Pending ($pendingCount)",
        "InProgress ($inProgressCount)",
        "Complete ($completedCount)",
      ];
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    // Format date as YYYY-MM-DD for API
    String formattedDate =
        "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

    // Fetch tasks for the selected date
    await _employeeScheduleController.fetchTasksForDate(formattedDate);

    // Update tabs in the next frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTabs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: GetBuilder<EmployeeScheduleController>(
            builder: (controller) {
              // The tabs will be updated via the post-frame callback outside the build method

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 12.h),

                    /// Header Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 18.sp,
                          color: Colors.black,
                        ),
                        Text(
                          DateFormat.yMMMM().format(_focusedDay),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18.sp,
                          color: Colors.black,
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    /// Table Calendar
                    TableCalendar(
                      focusedDay: _focusedDay,
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        _onDaySelected(selectedDay, focusedDay);
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      headerVisible: false,
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        outsideDaysVisible: false,
                        cellMargin: EdgeInsets.all(4.w),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black,
                        ),
                        weekendStyle: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    /// Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 8.h,
                              width: 8.w,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "Completed Appointments",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 12.w),
                        Row(
                          children: [
                            Container(
                              height: 8.h,
                              width: 8.w,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "Pending Appointments",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    /// Tab Buttons
                    SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(tabs.length, (index) {
                          bool isSelected = selectedTab == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTab = index;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.grey.shade400,
                                ),
                              ),
                              child: Text(
                                tabs[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    /// Appointments List
                    if (controller.isLoading.value)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildTaskList(controller),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required String taskId, // Add this parameter
    required String title,
    required String status,
    required String priority,
    required int progress,
    required Color color,
    String? assignDate,
    List<TaskModel.Service>? services,
  }) {
    // Format the date from ISO string to a readable format
    String displayDate = "No date";
    if (assignDate != null && assignDate.isNotEmpty) {
      try {
        DateTime date = DateTime.parse(assignDate);
        displayDate = "${date.day} ${DateFormat.MMM().format(date)}";
      } catch (e) {
        displayDate = assignDate.substring(0, 10).replaceAll('-', ' ');
      }
    }

    return GestureDetector(
      onTap: () {
        print('Tapped on task with ID: $taskId');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsScreen(taskId: taskId),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title + tags
            Row(
              children: [
                Icon(Icons.flash_on, color: Colors.blue, size: 20.sp),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.h),
            Row(
              children: [
                _buildTag(status, color.withOpacity(0.2), color),
                SizedBox(width: 8.w),
                _buildTag(priority, Colors.blue.withOpacity(0.1), Colors.blue),
              ],
            ),

            SizedBox(height: 8.h),

            /// Progress bar
            LinearProgressIndicator(
              value: progress / 100,
              minHeight: 6.h,
              backgroundColor: Colors.grey.shade200,
              color: color,
              borderRadius: BorderRadius.circular(12.r),
            ),

            SizedBox(height: 8.h),

            /// Date and service info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    services != null && services.isNotEmpty
                        ? services.map((s) => s.name).join(', ')
                        : 'No services specified',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      displayDate,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Also update the _buildTaskList method to pass the taskId
  Widget _buildTaskList(EmployeeScheduleController controller) {
    List<TaskModel.TaskModel> tasks = controller.getAllTasksForSelectedDate();

    // Filter tasks based on selected tab if needed
    if (selectedTab > 0) {
      String statusFilter = tabs[selectedTab]
          .split('(')[0]
          .trim()
          .toLowerCase();
      if (statusFilter == 'inprogress') statusFilter = 'inprogress';

      tasks = tasks
          .where((task) => task.status?.toLowerCase() == statusFilter)
          .toList();
    }

    if (tasks.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        child: Text(
          'No tasks scheduled for this day',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        Color statusColor = _getStatusColor(task.status ?? '');
        int progress = task.progressPercent ?? 0;

        return GestureDetector(
          onTap: () {
            // Navigate to task details screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailsScreen(taskId: task.id ?? ""),
              ),
            ).then((_) {
              _updateTabs();
            });
          },
          child: _buildTaskCard(
            taskId: task.id ?? "", // Pass the task ID
            title: task.customerName ?? "",
            status: task.status ?? "",
            priority: task.priority ?? "",
            progress: progress,
            color: statusColor,
            assignDate: task.assignDate?.toIso8601String(),
            services: task.services,
          ),
        );
      },
    );
  }

  /// Small Tag widget
  Widget _buildTag(String text, Color bg, Color fg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return Colors.green;
      case 'inprogress':
      case 'in progress':
        return Colors.blue;
      case 'pending':
      case 'upcoming':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
