import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:koji/routes/app_routes.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:koji/controller/admincontroller/schedule_controller.dart';

import '../../../routes/route_paths.dart';


class AdminScheduleScreen extends StatelessWidget {
  const AdminScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScheduleController>(
      init: Get.find<ScheduleController>(), // Use existing instance
      builder: (controller) {
        return _AdminScheduleScreenContent(controller: controller);
      },
    );
  }
}

class _AdminScheduleScreenContent extends StatefulWidget {
  final ScheduleController controller;

  const _AdminScheduleScreenContent({required this.controller});

  @override
  State<_AdminScheduleScreenContent> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<_AdminScheduleScreenContent> {

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Dynamic event data from API
  Map<DateTime, Map<String, int>> _events = {};

  // Dynamic teams data from API
  List<Map<String, dynamic>> _teams = [];

  ScheduleController get _scheduleController => widget.controller;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load data for the current month
    String currentMonth = DateFormat('yyyy-MM').format(_focusedDay);
    _loadMonthlyData(currentMonth);

    // Load employee task data for today
    String currentDay = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadEmployeeTaskData(currentDay);
  }

  void _loadMonthlyData(String month) {
    _scheduleController.getMonthlyTaskSummary(month).then((data) {
      if (data?.data?.attributes?.monthCalendarData != null) {
        _events = {};
        for (var item in data!.data!.attributes!.monthCalendarData!) {
          if (item.date != null) {
            DateTime date = DateTime.parse(item.date!);
            _events[date] = {
              'completed': item.complitTaskCount ?? 0,
              'pending': item.pandingtaskCount ?? 0,
            };
          }
        }
        setState(() {});
      }
    });
  }

  void _loadEmployeeTaskData(String date) {
    _scheduleController.getEmployeeTaskData(date: date).then((data) {
      if (data?.data?.attributes?.results != null) {
        _teams = [];
        for (var item in data!.data!.attributes!.results!) {
          _teams.add({'teamName': 'Team (${item.touchesCount ?? 0} touches)',
            'members': [
              {
                'name': item.fullName ?? 'N/A',
                'taskCount': '${item.totalPendingTask ?? 0} Pending Tasks',
                'location': (item.location?.locationName == "Default Location") ? "Response" : item.location?.locationName ?? 'N/A',
                'assignTo': item.assignTo ?? '', // Use the employee ID for assignTo
                'timeSlots': _formatTimeSlots(item.touches),
                'stats': {
                  'completed': item.totalCompliteTask ?? 0,
                  'inProgress': item.totalProgressTask ?? 0,
                  'pending': item.totalPendingTask ?? 0,
                },
              }
            ],
          });
        }
        setState(() {});
      }
    });
  }

  List<Map<String, String>> _formatTimeSlots(List<String>? timeSlots) {
    if (timeSlots == null || timeSlots.isEmpty) {
      return [
        {'time': 'No scheduled tasks', 'type': 'work'}
      ];
    }

    List<Map<String, String>> formattedSlots = [];
    for (var slot in timeSlots) {
      // Assuming the format is "HH:MM-HH:MM"
      formattedSlots.add({
        'time': _formatTimeRange(slot),
        'type': 'work' // Default to work, could be enhanced based on actual data
      });
    }
    return formattedSlots;
  }

  String _formatTimeRange(String timeRange) {
    // Convert 24-hour format to 12-hour format with AM/PM
    if (timeRange.contains('-')) {
      List<String> parts = timeRange.split('-');
      if (parts.length == 2) {
        String start = parts[0].trim();
        String end = parts[1].trim();
        return '${_convertTo12Hour(start)} - ${_convertTo12Hour(end)}';
      }
    }
    return timeRange;
  }

  String _convertTo12Hour(String time24) {
    try {
      DateTime parsedTime = DateFormat('HH:mm').parse(time24);
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (e) {
      return time24; // Return original if parsing fails
    }
  }

  List<Widget> _buildEventMarkers(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final events = _events[normalizedDay];

    if (events == null) return [];

    List<Widget> markers = [];

    if (events['completed'] != null && events['completed']! > 0) {
      markers.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4.w,
              height: 4.h,
              decoration: const BoxDecoration(
                color: Color(0xFF4CD964),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              '${events['completed']}',
              style: TextStyle(
                fontSize: 9.sp,
                color: Color(0xFF4CD964),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (events['pending'] != null && events['pending']! > 0) {
      if (markers.isNotEmpty) markers.add(SizedBox(width: 3.w));
      markers.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4.w,
              height: 4.h,
              decoration: const BoxDecoration(
                color: Color(0xFFFF1414),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              '${events['pending']}',
              style: TextStyle(
                fontSize: 9.sp,
                color: Color(0xFFFF1414),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),

                /// Header Section
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

                          // Load data for the new month
                          String month = DateFormat('yyyy-MM').format(_focusedDay);
                          _loadMonthlyData(month);
                        });
                      },
                      child: Icon(Icons.arrow_back_ios, size: 18.sp, color: Colors.black),
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

                          // Load data for the new month
                          String month = DateFormat('yyyy-MM').format(_focusedDay);
                          _loadMonthlyData(month);
                        });
                      },
                      child: Icon(Icons.arrow_forward_ios, size: 18.sp, color: Colors.black),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                /// Table Calendar
                TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;

                      // Load employee task data for the selected day
                      String date = DateFormat('yyyy-MM-dd').format(selectedDay);
                      _loadEmployeeTaskData(date);
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
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
                      fontWeight: FontWeight.w500,
                    ),
                    weekendStyle: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  daysOfWeekHeight: 40.h,
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      final markers = _buildEventMarkers(date);
                      if (markers.isEmpty) return const SizedBox.shrink();

                      return Positioned(
                        bottom: 2.h,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: markers,
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 16.h),

                /// Legend
                Obx(() {
                  int totalCompleted = widget.controller.allEmployeeTaskData.value?.data?.attributes?.results
                          ?.fold<int>(0, (sum, item) => sum + (item.totalCompliteTask ?? 0)) ?? 0;
                  int totalInProgress = widget.controller.allEmployeeTaskData.value?.data?.attributes?.results
                          ?.fold<int>(0, (sum, item) => sum + (item.totalProgressTask ?? 0)) ?? 0;
                  int totalPending = widget.controller.allEmployeeTaskData.value?.data?.attributes?.results
                          ?.fold<int>(0, (sum, item) => sum + (item.totalPendingTask ?? 0)) ?? 0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 8.h,
                            width: 8.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CD964),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "Completed ($totalCompleted)",
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
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
                              color: Color(0xFFFFB509),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "InProgress ($totalInProgress)",
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
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
                              color: Color(0xFFFF1414),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "Pending ($totalPending)",
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  );
                }),

                SizedBox(height: 16.h),

                /// Teams Section
                widget.controller.employeeTaskDataLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : _teams.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No employee task data available',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ..._teams.map((team) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Team Header
                                  Container(
                                    width: 160.w,
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF95555),
                                      borderRadius: BorderRadius.circular(100.r),
                                    ),
                                    child: Text(
                                      team['teamName'],
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 12.h),

                                  /// Team Members
                                  ...team['members'].map<Widget>((member) => Container(
                                        width: 356.w,
                                        margin: EdgeInsets.only(bottom: 16.h),
                                        padding: EdgeInsets.all(16.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(14.r),
                                          border: Border.all(
                                            color: const Color(0xFFCECECE).withOpacity(0.25),
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x1A000000),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            /// Member Header
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 16.r,
                                                      backgroundColor: Color(0xFFFFE5E5),
                                                      child: Icon(
                                                        Icons.person,
                                                        size: 18.sp,
                                                        color: Color(0xFFF95555),
                                                      ),
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          member['name'],
                                                          style: TextStyle(
                                                            fontSize: 15.sp,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        Text(
                                                          member['taskCount'],
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                                /// ==================================== View ===========================
                                                GestureDetector(
                                                  onTap: () {
                                                    // Get the date for the selected day or use today's date
                                                    String selectedDate = _selectedDay != null
                                                        ? DateFormat('yyyy-MM-dd').format(_selectedDay!)
                                                        : DateFormat('yyyy-MM-dd').format(DateTime.now());

                                                    // Get the member's assignTo ID
                                                    String assignTo = member['assignTo'] ?? '';

                                                    // Navigate using named route with parameters
                                                    context.pushNamed(
                                                      'adminCompleteViewTaskScreenWithParams',
                                                      pathParameters: {
                                                        'date': selectedDate,
                                                        'assignTo': assignTo,
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 12.w,
                                                      vertical: 6.h,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFF0626B).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(100.r),
                                                    ),
                                                    child: Text(
                                                      'View',
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        fontWeight: FontWeight.w500,
                                                        color: Color(0xFFF95555),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 8.h),

                                            /// Location
                                            Row(
                                              children: [
                                                Text(
                                                  'Current Location: ',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  member['location'],
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 12.h),

                                            /// Time Slots
                                            Wrap(
                                              spacing: 8.w,
                                              runSpacing: 8.h,
                                              children: member['timeSlots'].map<Widget>((slot) {
                                                bool isBreak = slot['type'] == 'break';
                                                return Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 6.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isBreak
                                                        ? Color(0xFFFF6B6B).withOpacity(0.1)
                                                        : Color(0xFFF95555),
                                                    borderRadius: BorderRadius.circular(100.r),
                                                  ),
                                                  child: Text(
                                                    slot['time'],
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      fontWeight: FontWeight.w500,
                                                      color: isBreak ? Color(0xFFF95555) : Colors.white,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),

                                            SizedBox(height: 12.h),

                                            /// Stats
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                _buildStatItem(
                                                  '● Completed (${member['stats']['completed']})',
                                                  Color(0xFF4CD964),
                                                ),
                                                _buildStatItem(
                                                  '● In progress (${member['stats']['inProgress']})',
                                                  Color(0xFFFFB800),
                                                ),
                                                _buildStatItem(
                                                  '● Pending (${member['stats']['pending']})',
                                                  Color(0xFFFF1414),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )).toList(),
                                ],
                              )).toList(),
                            ],
                          ),

                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          text.replaceAll('● ', ''),
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}