import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koji/controller/employee_schedule_controller.dart';
import 'package:koji/features/employee_schedule/presentation/task_details_screen.dart';
import 'package:koji/models/task_model.dart' as TaskModel;
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

  // Theme colors matching the gradient design
  static const Color primaryDark = Color(0xFF162238);
  static const Color primaryBlue = Color(0xFF4082FB);
  static const Color accentBlue = Color(0xFF125BAC);
  static const Color completedColor = Color(0xFF4CD964);
  static const Color pendingColor = Color(0xFFFF1414);

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onDaySelected(_selectedDay!, _selectedDay!);
    });
  }

  void _updateTabs() {
    final allCount = _employeeScheduleController.getTaskCountByStatus('all');
    final pendingCount = _employeeScheduleController.getTaskCountByStatus('pending');
    final inProgressCount = _employeeScheduleController.getTaskCountByStatus('inprogress');
    final completedCount = _employeeScheduleController.getTaskCountByStatus('complete');

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

    String formattedDate =
        "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

    await _employeeScheduleController.fetchTasksForDate(formattedDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTabs();
    });
  }

  /// Returns dot indicators for a given day based on tasks
  Widget _buildDayDots(EmployeeScheduleController controller, DateTime day) {
    // This is a simplified version — ideally you'd load all dates' tasks.
    // For now dots are shown on selected day based on loaded tasks.
    if (!isSameDay(_selectedDay, day)) return const SizedBox.shrink();

    final tasks = controller.getAllTasksForSelectedDate();
    if (tasks.isEmpty) return const SizedBox.shrink();

    final completedCount = tasks
        .where((t) =>
            t.isSubmited == true ||
            t.status?.toLowerCase() == 'complete' ||
            t.status?.toLowerCase() == 'done' ||
            t.status?.toLowerCase() == 'completed')
        .length;
    final pendingCount = tasks
        .where((t) =>
            t.isSubmited != true &&
            (t.status?.toLowerCase() == 'pending' ||
                t.status?.toLowerCase() == 'upcoming'))
        .length;

    List<Widget> dots = [];
    if (completedCount > 0) {
      dots.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6.w,
              height: 6.h,
              decoration: const BoxDecoration(
                color: completedColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 1.w),
            Text(
              '•$completedCount',
              style: TextStyle(fontSize: 8.sp, color: completedColor),
            ),
          ],
        ),
      );
    }
    if (pendingCount > 0) {
      dots.add(SizedBox(width: 4.w));
      dots.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6.w,
              height: 6.h,
              decoration: const BoxDecoration(
                color: pendingColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 1.w),
            Text(
              '•$pendingCount',
              style: TextStyle(fontSize: 8.sp, color: pendingColor),
            ),
          ],
        ),
      );
    }

    if (dots.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: dots,
    );
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
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 12.h),

                    /// Header Section with gradient text style
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _focusedDay = DateTime(
                                _focusedDay.year,
                                _focusedDay.month - 1,
                              );
                            });
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 18.sp,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          DateFormat.yMMMM().format(_focusedDay),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _focusedDay = DateTime(
                                _focusedDay.year,
                                _focusedDay.month + 1,
                              );
                            });
                          },
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 18.sp,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    /// Table Calendar with dot markers
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
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                      headerVisible: false,
                      calendarBuilders: CalendarBuilders(
                        // Custom day builder to add colored dot indicators
                        defaultBuilder: (context, day, focusedDay) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                ),
                              ),
                              _buildDayDots(controller, day),
                            ],
                          );
                        },
                        selectedBuilder: (context, day, focusedDay) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 36.w,
                                height: 36.h,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                    colors: [primaryDark, primaryBlue],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              _buildDayDots(controller, day),
                            ],
                          );
                        },
                        todayBuilder: (context, day, focusedDay) {
                          final isSelected = isSameDay(_selectedDay, day);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 36.w,
                                height: 36.h,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryBlue
                                      : primaryBlue.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: isSelected
                                        ? Colors.white
                                        : primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              _buildDayDots(controller, day),
                            ],
                          );
                        },
                      ),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        cellMargin: EdgeInsets.all(2.w),
                        cellPadding: EdgeInsets.zero,
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        weekendStyle: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),

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
                                color: completedColor,
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
                                color: pendingColor,
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
                    if (tabs.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(tabs.length, (index) {
                            bool isSelected = selectedTab == index;
                            return Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedTab = index;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 9.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                      colors: [primaryDark, primaryBlue],
                                    )
                                        : null,
                                    color: isSelected ? null : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    tabs[index],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                    SizedBox(height: 16.h),

                    /// Tasks List
                    if (controller.isLoading.value)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildTaskList(controller),

                    SizedBox(height: 24.h),
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
    required String taskId,
    required String title,
    required String status,
    required String priority,
    required int progress,
    required Color color,
    String? assignDate,
    List<TaskModel.Service>? services,
  }) {
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsScreen(taskId: taskId),
          ),
        ).then((_) {
          // Refresh tasks when returning from TaskDetailsScreen
          if (_selectedDay != null) {
            final formatted =
                "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}";
            _employeeScheduleController
                .fetchTasksForDate(formatted)
                .then((_) {
              if (mounted) _updateTabs();
            });
          }
        });
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title row
            Row(
              children: [
                Container(
                  width: 28.w,
                  height: 28.h,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [_CalendarScreenState.primaryDark, _CalendarScreenState.primaryBlue],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.flash_on, color: Colors.white, size: 16.sp),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            /// Status + Priority Tags
            Row(
              children: [
                _buildTag(status, color),
                SizedBox(width: 8.w),
                _buildPriorityTag(priority),
              ],
            ),

            SizedBox(height: 10.h),

            /// Progress bar + percentage
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 5.h,
                      backgroundColor: Colors.grey.shade200,
                      color: color,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '$progress%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            /// Services + Date row
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
                      size: 14.sp,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      displayDate,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
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

  Widget _buildTaskList(EmployeeScheduleController controller) {
    List<TaskModel.TaskModel> tasks = controller.getAllTasksForSelectedDate();

    if (selectedTab > 0) {
      final statusFilter = tabs[selectedTab]
          .split('(')[0]
          .trim()
          .toLowerCase();
      tasks = tasks
          .where((task) => _effectiveStatus(task).toLowerCase() == statusFilter)
          .toList();
    }

    if (tasks.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: Text(
          'No tasks scheduled for this day',
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
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
        final effectiveStatus = _effectiveStatus(task);
        Color statusColor = _getStatusColor(effectiveStatus);
        int progress = task.isSubmited == true
            ? 100
            : (task.progressPercent ?? 0);

        return _buildTaskCard(
          taskId: task.id ?? "",
          title: _capitalize(task.customerName ?? ""),
          status: effectiveStatus,
          priority: task.priority ?? "",
          progress: progress,
          color: statusColor,
          assignDate: task.assignDate?.toIso8601String(),
          services: task.services,
        );
      },
    );
  }

  /// Returns effective display status:
  /// if isSubmited == true → always show as "complete"
  String _effectiveStatus(TaskModel.TaskModel task) {
    if (task.isSubmited == true) return 'complete';
    return task.status ?? '';
  }

  /// Capitalize first letter of each word
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Status tag — #EAECF0 bg, dark text, pill shape (h:23, border-radius:100, px:8, py:4)
  Widget _buildTag(String text, Color color) {
    return Container(
      height: 23.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAECF0),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        _capitalize(text),
        style: TextStyle(
          color: const Color(0xFF344054),
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Priority tag — #125BAC bg, white text, pill shape (h:23, border-radius:100, px:8, py:4)
  Widget _buildPriorityTag(String text) {
    return Container(
      height: 23.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF125BAC),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 10.sp, color: Colors.white),
          SizedBox(width: 3.w),
          Text(
            _capitalize(text),
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
      case 'complete':
        return completedColor;
      case 'inprogress':
      case 'in progress':
        return primaryBlue;
      case 'pending':
      case 'upcoming':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}