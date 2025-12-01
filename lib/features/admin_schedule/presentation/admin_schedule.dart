import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:koji/shared_widgets/custom_text.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../constants/app_color.dart';
import '../../../shared_widgets/admin_man_staff.dart';

class AdminScheduleScreen extends StatefulWidget {
  const AdminScheduleScreen({super.key});

  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Sample event data - Replace with your actual data
  Map<DateTime, Map<String, int>> _events = {
    DateTime(2025, 9, 1): {'completed': 2, 'pending': 6},
    DateTime(2025, 9, 13): {'completed': 2, 'pending': 6},
  };

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
              '+${events['completed']}',
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
              '+${events['pending']}',
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
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SingleChildScrollView(
            child: Column(
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
                  daysOfWeekHeight: 40.h, // Added proper height for day headers
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

                SizedBox(height: 12.h),

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
                            color: Color(0xFF4CD964),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "Completed Appointments",
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
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
                          "Pending Appointments",
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                Divider(
                  color: AppColor.textColorF4F4F5,
                ),

                SizedBox(height: 8.h),

                /// ========================> Handy Man Staff =============================>
                ScheduleCard(
                  staffName: 'Handy Man Staff',
                  category: 'Plumbing Service',
                  time: '2:00 PM - 9:00 PM',
                  breakTime: '4:30 PM - 5:00 PM',
                  date: DateTime(2025, 9, 1),
                  isCompleted: true,
                  onTap: () {
                    context.push('/adminCompleteTaskScreen');
                  },
                ),

                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}