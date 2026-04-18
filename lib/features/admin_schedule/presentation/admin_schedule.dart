import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:koji/controller/admincontroller/schedule_controller.dart';
import 'package:koji/models/admin-model/all_employee_task_model.dart';

class AdminScheduleScreen extends StatelessWidget {
  const AdminScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScheduleController>(
      init: Get.find<ScheduleController>(),
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

  // Dynamic teams data from API with color assignments
  List<Map<String, dynamic>> _teams = [];

  // Predefined team colors matching the reference design
  final List<Color> _teamColors = [
    const Color(0xFFF95555), // Red/Pink
    const Color(0xFF4CD964), // Green
    const Color(0xFF5856D6), // Purple
    const Color(0xFF007AFF), // Blue
    const Color(0xFFFF9500), // Orange
    const Color(0xFFFF2D55), // Deep Pink
    const Color(0xFF34C759), // Light Green
    const Color(0xFFAF52DE), // Light Purple
  ];

  ScheduleController get _scheduleController => widget.controller;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now(); // Set selected day to today initially
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
              'inProgress': item.totalProgressCount ?? 0,
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
        int colorIndex = 0;

        for (var item in data!.data!.attributes!.results!) {
          // Assign color from the predefined list, cycling through if needed
          Color teamColor = _teamColors[colorIndex % _teamColors.length];

          _teams.add({
            'teamName': '${item.fullName ?? 'Team'}',
            'touchesCount': item.touchesCount ?? 0,
            'teamColor': teamColor,
            'members': [
              {
                'name': item.fullName ?? 'N/A',
                'taskCount': '${item.totalPendingTask ?? 0} Pending Tasks',
                'location': item.location?.locationName ?? 'Default Location',
                'assignTo': item.assignTo ?? '',
                'timeSlots': _formatTimeSlots(item.touches),
                'stats': {
                  'completed': item.totalCompliteTask ?? 0,
                  'inProgress': item.totalProgressTask ?? 0,
                  'pending': item.totalPendingTask ?? 0,
                },
              }
            ],
          });

          colorIndex++;
        }
        setState(() {});
      }
    });
  }

  List<Map<String, String>> _formatTimeSlots(List<Touch>? timeSlots) {
    if (timeSlots == null || timeSlots.isEmpty) {
      return [
        {'time': 'No scheduled tasks', 'type': 'empty'}
      ];
    }

    List<Map<String, String>> formattedSlots = [];
    final limitedSlots = timeSlots.take(3).toList();
    for (var slot in limitedSlots) {
      String timeDisplay = '';
      if (slot.assignDate != null && slot.deadline != null) {
        timeDisplay = '${_formatDateTime(slot.assignDate!)} - ${_formatDateTime(slot.deadline!)}';
      } else if (slot.assignDate != null) {
        timeDisplay = _formatDateTime(slot.assignDate!);
      } else if (slot.time != null && slot.time!.isNotEmpty) {
        timeDisplay = _formatTimeRange(slot.time!);
      }
      formattedSlots.add({
        'time': timeDisplay,
        'customerNumber': slot.customerNumber ?? '',
        'customerAddress': slot.customerAddress ?? '',
        'type': 'work'
      });
    }
    return formattedSlots;
  }

  String _formatDateTime(String isoString) {
    try {
      DateTime dt = DateTime.parse(isoString).toLocal();
      return DateFormat('hh:mm a').format(dt).toUpperCase();
    } catch (e) {
      return isoString;
    }
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
      return DateFormat('hh:mm a').format(parsedTime).toUpperCase();
    } catch (e) {
      return time24;
    }
  }

  List<Widget> _buildEventMarkers(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final events = _events[normalizedDay];

    if (events == null) return [];

    List<Widget> markers = [];

    // Completed - green number
    if ((events['completed'] ?? 0) > 0) {
      markers.add(_buildCountBadge(events['completed']!, const Color(0xFF4CD964)));
    }

    // In Progress - yellow number
    if ((events['inProgress'] ?? 0) > 0) {
      if (markers.isNotEmpty) markers.add(SizedBox(width: 2.w));
      markers.add(_buildCountBadge(events['inProgress']!, const Color(0xFFFFB509)));
    }

    // Pending - red number
    if ((events['pending'] ?? 0) > 0) {
      if (markers.isNotEmpty) markers.add(SizedBox(width: 2.w));
      markers.add(_buildCountBadge(events['pending']!, const Color(0xFFFF1414)));
    }

    return markers;
  }

  Widget _buildCountBadge(int count, Color color) {
    return Text(
      '$count',
      style: TextStyle(
        fontSize: 9.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1,
      ),
    );
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
                SizedBox(height: 16.h),

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

                          String month = DateFormat('yyyy-MM').format(_focusedDay);
                          _loadMonthlyData(month);
                        });
                      },
                      child: Icon(Icons.arrow_back_ios, size: 20.sp, color: Colors.black),
                    ),
                    Text(
                      DateFormat.yMMMM().format(_focusedDay),
                      style: TextStyle(
                        fontSize: 20.sp,
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

                          String month = DateFormat('yyyy-MM').format(_focusedDay);
                          _loadMonthlyData(month);
                        });
                      },
                      child: Icon(Icons.arrow_forward_ios, size: 20.sp, color: Colors.black),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                /// Table Calendar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TableCalendar(
                    focusedDay: _focusedDay,
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;

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
                        color: const Color(0xFF007AFF).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFF007AFF),
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      defaultTextStyle: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      weekendTextStyle: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      outsideDaysVisible: true,
                      outsideTextStyle: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[400],
                      ),
                      cellMargin: EdgeInsets.all(4.w),
                      cellPadding: EdgeInsets.zero,
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      weekendStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
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
                ),

                SizedBox(height: 20.h),

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
                      _buildLegendItem(
                        color: const Color(0xFFFF1414),
                        label: 'Pending',
                        count: totalPending,
                      ),
                      SizedBox(width: 16.w),
                      _buildLegendItem(
                        color: const Color(0xFFFFB509),
                        label: 'InProgress',
                        count: totalInProgress,
                      ),
                      SizedBox(width: 16.w),
                      _buildLegendItem(
                        color: const Color(0xFF4CD964),
                        label: 'Completed',
                        count: totalCompleted,
                      ),
                    ],
                  );
                }),

                SizedBox(height: 20.h),

                /// Teams Section
                Obx(() {
                  if (widget.controller.employeeTaskDataLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_teams.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(32.h),
                      child: Center(
                        child: Text(
                          'No employee task data available',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Teams Header - Only show once at the top
                      Text(
                        'Teams (${_teams.length.toString().padLeft(2, '0')})',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      /// All team members without individual team headers
                      ..._teams.asMap().entries.map((entry) {
                        var team = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// Team Members
                            ...team['members'].map<Widget>((member) => Container(
                              margin: EdgeInsets.only(bottom: 16.h),
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
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
                                            radius: 20.r,
                                            backgroundColor: team['teamColor'].withOpacity(0.15),
                                            child: Icon(
                                              Icons.person,
                                              size: 20.sp,
                                              color: team['teamColor'],
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                member['name'],
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 2.h),
                                              Text(
                                                member['taskCount'],
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      /// View Button
                                      GestureDetector(
                                        onTap: () {
                                          String selectedDate = _selectedDay != null
                                              ? DateFormat('yyyy-MM-dd').format(_selectedDay!)
                                              : DateFormat('yyyy-MM-dd').format(DateTime.now());

                                          String assignTo = member['assignTo'] ?? '';

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
                                            horizontal: 16.w,
                                            vertical: 8.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: team['teamColor'].withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(100.r),
                                          ),
                                          child: Text(
                                            'View',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: team['teamColor'],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // SizedBox(height: 12.h),
                                  //
                                  // /// Location
                                  // Row(
                                  //   children: [
                                  //     Text(
                                  //       'Current Location: ',
                                  //       style: TextStyle(
                                  //         fontSize: 13.sp,
                                  //         color: Colors.grey[600],
                                  //         fontWeight: FontWeight.w400,
                                  //       ),
                                  //     ),
                                  //     Expanded(
                                  //       child: Text(
                                  //         member['location'],
                                  //         style: TextStyle(
                                  //           fontSize: 13.sp,
                                  //           color: Colors.black,
                                  //           fontWeight: FontWeight.w600,
                                  //         ),
                                  //         overflow: TextOverflow.ellipsis,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),

                                  SizedBox(height: 14.h),

                                  /// Time Slots
                                  if (member['timeSlots'].isNotEmpty &&
                                      member['timeSlots'][0]['type'] != 'empty')
                                    Column(
                                      children: member['timeSlots'].map<Widget>((slot) {
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 8.h),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 14.w,
                                            vertical: 10.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: team['teamColor'].withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(12.r),
                                            border: Border.all(
                                              color: team['teamColor'].withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 36.w,
                                                height: 36.w,
                                                decoration: BoxDecoration(
                                                  color: team['teamColor'].withOpacity(0.15),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.access_time,
                                                  size: 18.sp,
                                                  color: team['teamColor'],
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      slot['time'],
                                                      style: TextStyle(
                                                        fontSize: 13.sp,
                                                        fontWeight: FontWeight.w600,
                                                        color: team['teamColor'],
                                                      ),
                                                    ),
                                                    if ((slot['customerNumber'] as String).isNotEmpty)
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 3.h),
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.phone, size: 11.sp, color: Colors.grey[600]),
                                                            SizedBox(width: 4.w),
                                                            Text(
                                                              slot['customerNumber']!,
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                color: Colors.grey[700],
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    if ((slot['customerAddress'] as String).isNotEmpty)
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 3.h),
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.location_on, size: 11.sp, color: Colors.grey[600]),
                                                            SizedBox(width: 4.w),
                                                            Expanded(
                                                              child: Text(
                                                                slot['customerAddress']!,
                                                                style: TextStyle(
                                                                  fontSize: 12.sp,
                                                                  color: Colors.grey[700],
                                                                  fontWeight: FontWeight.w400,
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),

                                  if (member['timeSlots'].isNotEmpty &&
                                      member['timeSlots'][0]['type'] != 'empty')
                                    SizedBox(height: 14.h),

                                  /// Stats
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildStatItem(
                                        'Pending (${member['stats']['pending']})',
                                        const Color(0xFFFF1414),
                                      ),
                                      _buildStatItem(
                                        'In progress (${member['stats']['inProgress']})',
                                        const Color(0xFFFFB800),
                                      ),
                                      _buildStatItem(
                                        'Completed (${member['stats']['completed']})',
                                        const Color(0xFF4CD964),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )).toList(),
                          ],
                        );
                      }).toList(),
                    ],
                  );
                }),

                SizedBox(height: 80.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
        SizedBox(width: 6.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}