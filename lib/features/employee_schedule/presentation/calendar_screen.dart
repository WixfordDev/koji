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

  static const Color primaryDark = Color(0xFF162238);
  static const Color primaryBlue = Color(0xFF4082FB);
  static const Color accentBlue = Color(0xFF125BAC);
  static const Color completedColor = Color(0xFF4CD964);
  static const Color pendingColor = Color(0xFFFF1414);
  static const Color inProgressColor = Color(0xFFFF9500);

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onDaySelected(_selectedDay!, _selectedDay!);
      // Fetch all dates of current month in background for calendar indicators
      _employeeScheduleController.fetchMonthTasks(
        _focusedDay.year,
        _focusedDay.month,
      );
    });
  }

  void _updateTabs() {
    final allCount =
        _employeeScheduleController.getTaskCountByStatus('all');
    final pendingCount =
        _employeeScheduleController.getTaskCountByStatus('pending');
    final inProgressCount =
        _employeeScheduleController.getTaskCountByStatus('inprogress');
    final completedCount =
        _employeeScheduleController.getTaskCountByStatus('complete');

    setState(() {
      tabs = [
        "All ($allCount)",
        "Pending ($pendingCount)",
        "InProgress ($inProgressCount)",
        "Completed ($completedCount)",
      ];
      if (selectedTab >= tabs.length) selectedTab = 0;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    final formattedDate =
        "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

    await _employeeScheduleController.fetchTasksForDate(formattedDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTabs();
    });
  }

  Widget _buildDayIndicator(EmployeeScheduleController controller, DateTime day) {
    final dayTasks = controller.getTasksForDay(day);
    if (dayTasks.isEmpty) return const SizedBox.shrink();

    final completedCount = dayTasks.where((t) =>
        t.isSubmited == true ||
        t.status?.toLowerCase() == 'complete' ||
        t.status?.toLowerCase() == 'done' ||
        t.status?.toLowerCase() == 'completed').length;

    final inProgressCount = dayTasks.where((t) =>
        t.isSubmited != true &&
        (t.status?.toLowerCase() == 'inprogress' ||
            t.status?.toLowerCase() == 'in progress' ||
            t.status?.toLowerCase() == 'progress')).length;

    final pendingCount = dayTasks.where((t) =>
        t.isSubmited != true &&
        (t.status?.toLowerCase() == 'pending' ||
            t.status?.toLowerCase() == 'upcoming')).length;

    if (completedCount == 0 && inProgressCount == 0 && pendingCount == 0) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (pendingCount > 0) ...[
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: pendingColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 1),
          Text(
            '$pendingCount',
            style: const TextStyle(
              fontSize: 9,
              color: pendingColor,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
        if (pendingCount > 0 && inProgressCount > 0) const SizedBox(width: 3),
        if (inProgressCount > 0) ...[
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: inProgressColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 1),
          Text(
            '$inProgressCount',
            style: const TextStyle(
              fontSize: 9,
              color: inProgressColor,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
        if (inProgressCount > 0 && completedCount > 0) const SizedBox(width: 3),
        if (completedCount > 0) ...[
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: completedColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 1),
          Text(
            '$completedCount',
            style: const TextStyle(
              fontSize: 9,
              color: completedColor,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ],
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
                    SizedBox(height: 16.h),

                    /// Header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              final prev = DateTime(_focusedDay.year, _focusedDay.month - 1);
                              setState(() => _focusedDay = prev);
                              _employeeScheduleController.fetchMonthTasks(prev.year, prev.month);
                            },
                            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
                          ),
                          Text(
                            DateFormat.yMMMM().format(_focusedDay),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              final next = DateTime(_focusedDay.year, _focusedDay.month + 1);
                              setState(() => _focusedDay = next);
                              _employeeScheduleController.fetchMonthTasks(next.year, next.month);
                            },
                            child: const Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    /// Table Calendar
                    TableCalendar(
                      focusedDay: _focusedDay,
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      calendarFormat: CalendarFormat.month,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        _onDaySelected(selectedDay, focusedDay);
                      },
                      onPageChanged: (focusedDay) {
                        setState(() => _focusedDay = focusedDay);
                        _employeeScheduleController.fetchMonthTasks(focusedDay.year, focusedDay.month);
                      },
                      headerVisible: false,
                      rowHeight: 58,
                      daysOfWeekHeight: 32,
                      calendarBuilders: CalendarBuilders(
                        // Normal day
                        defaultBuilder: (context, day, focusedDay) {
                          return _dayCell(
                            label: '${day.day}',
                            labelColor: Colors.black87,
                            indicator: _buildDayIndicator(controller, day),
                          );
                        },
                        // Selected day — solid blue circle
                        selectedBuilder: (context, day, focusedDay) {
                          return _dayCell(
                            label: '${day.day}',
                            labelColor: Colors.white,
                            circleColor: primaryBlue,
                            indicator: _buildDayIndicator(controller, day),
                          );
                        },
                        // Today
                        todayBuilder: (context, day, focusedDay) {
                          final sel = isSameDay(_selectedDay, day);
                          return _dayCell(
                            label: '${day.day}',
                            labelColor: sel ? Colors.white : primaryBlue,
                            circleColor: sel ? primaryBlue : primaryBlue.withOpacity(0.12),
                            indicator: _buildDayIndicator(controller, day),
                          );
                        },
                      ),
                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: false,
                        cellMargin: EdgeInsets.zero,
                        cellPadding: EdgeInsets.zero,
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w500,
                        ),
                        weekendStyle: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 6.h),

                    /// Divider
                    Divider(color: Colors.grey.shade200, thickness: 1),

                    SizedBox(height: 10.h),

                    /// Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legendDot(pendingColor, "Pending"),
                        const SizedBox(width: 12),
                        _legendDot(inProgressColor, "Inprogress"),
                        const SizedBox(width: 12),
                        _legendDot(completedColor, "Completed"),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    /// Tab Swipe Bar
                    if (tabs.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(tabs.length, (index) {
                            final isSelected = selectedTab == index;
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
                                    color: isSelected
                                        ? null
                                        : Colors.transparent,
                                    borderRadius:
                                        BorderRadius.circular(24.r),
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
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return _buildTaskList(controller);
                    }),

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

  /// Reusable day cell for calendar builders
  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
      ],
    );
  }

  Widget _dayCell({
    required String label,
    required Color labelColor,
    Color? circleColor,
    required Widget indicator,
  }) {
    final hasCircle = circleColor != null;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          hasCircle
              ? Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : SizedBox(
                  width: 34,
                  height: 34,
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: labelColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
          indicator,
        ],
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
            Row(
              children: [
                Container(
                  width: 28.w,
                  height: 28.h,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        _CalendarScreenState.primaryDark,
                        _CalendarScreenState.primaryBlue,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.flash_on, color: Colors.white, size: 16.sp),
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

            Row(
              children: [
                _buildTag(status, color),
                SizedBox(width: 8.w),
                _buildPriorityTag(priority),
              ],
            ),

            SizedBox(height: 10.h),

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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    services != null && services.isNotEmpty
                        ? services.map((s) => s.name).join(', ')
                        : 'No services specified',
                    style:
                        TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
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
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.grey[500]),
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
      const statusFilters = ['', 'pending', 'inprogress', 'complete'];
      final statusFilter = statusFilters[selectedTab];
      tasks = tasks
          .where(
              (task) => _effectiveStatus(task).toLowerCase() == statusFilter)
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
        final statusColor = _getStatusColor(effectiveStatus);
        final progress =
            task.isSubmited == true ? 100 : (task.progressPercent ?? 0);

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

  String _effectiveStatus(TaskModel.TaskModel task) {
    if (task.isSubmited == true) return 'complete';
    final s = task.status?.toLowerCase() ?? '';
    if (s == 'completed' || s == 'done') return 'complete';
    if (s == 'progress') return 'inprogress';
    return task.status ?? '';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) =>
            word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

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
      case 'progress':
        return inProgressColor;
      case 'pending':
      case 'upcoming':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
