import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

  List<String> tabs = ["All (15)", "Pending", "InProgress", "Complete"];
  int selectedTab = 0;

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
                    Icon(Icons.arrow_back_ios, size: 18.sp, color: Colors.black),
                    Text(
                      DateFormat.yMMMM().format(_focusedDay),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 18.sp, color: Colors.black),
                  ],
                ),

                SizedBox(height: 8.h),

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
                    weekdayStyle: TextStyle(fontSize: 13.sp, color: Colors.black),
                    weekendStyle: TextStyle(fontSize: 13.sp, color: Colors.black),
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
                            color: Colors.red,
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

                SizedBox(height: 16.h),

                /// Tab Buttons
                SingleChildScrollView(

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(tabs.length, (index) {
                      bool isSelected = selectedTab == index;
                      return GestureDetector(
                        onTap: ()
                        => context.push('/myTaskScreen'),
                        child: Container(
                          padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color:
                              isSelected ? Colors.blue : Colors.grey.shade400,
                            ),
                          ),
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
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
                _buildTaskCard(
                  title: "Plumbing Repair Service",
                  status: "Upcoming",
                  priority: "High",
                  progress: 0,
                  color: Colors.grey,
                ),
                _buildTaskCard(
                  title: "Painting Repair Service",
                  status: "In Progress",
                  priority: "High",
                  progress: 96,
                  color: Colors.blue,
                ),
                _buildTaskCard(
                  title: "AC Repair Service",
                  status: "Done",
                  priority: "High",
                  progress: 100,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Appointment Card
  Widget _buildTaskCard({
    required String title,
    required String status,
    required String priority,
    required int progress,
    required Color color,
  }) {
    return Container(
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

          /// Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("👷‍♂️👷‍♀️👷", style: TextStyle(fontSize: 16.sp)),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    "27 Sept",
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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
}
