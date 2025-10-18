import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/features/admin_home/presentation/admin_attendance_screen.dart';

import '../../../shared_widgets/custom_text.dart';
import 'admin_employee_request_screen.dart';
import 'admin_task_list_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  AdminHomeScreen({super.key});

  List<Map<String, dynamic>> gridList = [
    {
      "image": "assets/images/bg1.png",
      "text1": "Task",
      "text2": "Manage",
      "icon": "assets/images/task.png",
    },
    {
      "image": "assets/images/bg2.png",
      "text1": "Employee",
      "text2": "Request",
      "icon": "assets/images/request.png",
    },
    {
      "image": "assets/images/bg3.png",
      "text1": "View",
      "text2": "Attendence",
      "icon": "assets/images/attendance.png",
    },
    {
      "image": "assets/images/b.png",
      "text1": "View",
      "text2": "Attendence",
      "icon": "assets/images/report.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset("assets/images/profile.png"),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomText(
              text: "Parvej Hossain",
              fontSize: 25.h,
              fontWeight: FontWeight.w700,
              top: 12.h,
              bottom: 0.h,
            ),
            CustomText(
              text: "Admin",
              fontSize: 18.h,
              fontWeight: FontWeight.w500,
              top: 0.h,
              bottom: 0.h,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Image.asset(
              "assets/images/notification.png",
              height: 30.h,
              width: 30.w,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  headerCardWidget(
                    text1: 'Total Employee',
                    text2: '4005',
                    img: 'assets/images/color_person.png',
                  ),
                  headerCardWidget(
                    text1: 'Attendance',
                    text2: '96%',
                    img: 'assets/images/icon_attendance.png',
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              headerTitle(text1: "Quick Action"),
              // gridCard(),
              SizedBox(
                // height: 340.h,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 4 items in one row
                    crossAxisSpacing: 8.0, // horizontal space
                    mainAxisSpacing: 8.0, // vertical space
                    childAspectRatio: 1, // width : height ratio
                  ),
                  itemCount: gridList.length,
                  // total number of items
                  shrinkWrap: true,
                  // use this if inside another scroll view
                  physics: const NeverScrollableScrollPhysics(),
                  // disable scroll if needed
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        if (index == 0) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AdminTaskListScreen(),
                            ),
                          );
                        } else if (index == 1) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AdminEmployeeRequestScreen(),
                            ),
                          );
                        } else if (index == 2) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AdminAttendanceScreen(),
                            ),
                          );
                        }
                      },
                      child: gridCard(index),
                    ); // your custom widget
                  },
                ),
              ),

              SizedBox(height: 10.h),
              headerTitle(text1: "Today's Attendance summary"),
              Container(
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      // shadow color
                      spreadRadius: 1,
                      // how much it spreads
                      blurRadius: 0,
                      // how soft the shadow looks
                      offset: Offset(0, 2), // horizontal, vertical shift
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    cardWidgerRow(
                      text1: 'Employees Arrived On Time',
                      text2: '1050',
                      color: Colors.blue,
                    ),
                    SizedBox(height: 10.h),
                    cardWidgerRow(
                      text1: 'Late Comers Today',
                      text2: '120',
                      color: Color(0xffF3934F),
                    ),
                    SizedBox(height: 10.h),
                    cardWidgerRow(
                      text1: 'Absent Employees Today',
                      text2: '50',
                      color: Color(0xffF34F4F),
                    ),
                    SizedBox(height: 10.h),
                    cardWidgerRow(
                      text1: 'Working Employees Today',
                      text2: '1200',
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              headerTitle(text1: "Today's Task summary"),
              Container(
                padding: EdgeInsets.all(5.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      // shadow color
                      spreadRadius: 1,
                      // how much it spreads
                      blurRadius: 0,
                      // how soft the shadow looks
                      offset: Offset(0, 2), // horizontal, vertical shift
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    cardWidgerRow(
                      text1: 'Total Task',
                      text2: '20',
                      color: Color(0xff3EBF5A),
                    ),
                    SizedBox(height: 10.h,),
                    cardWidgerRow(
                      text1: 'Complete Task ',
                      text2: '05',
                      color: Color(0xffF3934F),
                    ),
                    SizedBox(height: 10.h,),
                    cardWidgerRow(
                      text1: 'Pending Task',
                      text2: '15',
                      color: Color(0xffF34F4F),
                    ),SizedBox(height: 10.h,),
                    cardWidgerRow(
                      text1: 'In - Progress Task',
                      text2: '15',
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardWidgerRow({
    required String text1,
    required String text2,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              height: 20.h,
              width: 20.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(50.r),
              ),
            ),
            SizedBox(width: 10),
            CustomText(
              text: text1,
              fontSize: 20.h,
              fontWeight: FontWeight.w500,
              top: 0.h,
              bottom: 0.h,
            ),
          ],
        ),
        Row(
          children: [
            CustomText(
              text: text2,
              fontSize: 23.h,
              fontWeight: FontWeight.w700,
              color: color,
              top: 0.h,
              bottom: 0.h,
            ),
            SizedBox(width: 10.r),
            Icon(Icons.arrow_forward_ios, size: 17.sp),
          ],
        ),
      ],
    );
  }

  Widget headerCardWidget({
    required String text1,
    required String text2,
    required String img,
  }) {
    return Container(
      padding: EdgeInsets.all(5.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1), // shadow color
            spreadRadius: 1, // how much it spreads
            blurRadius: 2.r, // how soft the shadow looks
            offset: Offset(0, 2), // horizontal, vertical shift
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(img, height: 60.h, width: 60.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomText(
                text: text1,
                fontSize: 18.h,
                fontWeight: FontWeight.w500,
                top: 0.h,
                bottom: 0.h,
              ),
              CustomText(
                text: text2,
                fontSize: 40.sp,
                color: text1 == "Attendance" ? Colors.blue : Colors.red,
                fontWeight: FontWeight.w500,
                top: 0.h,
                bottom: 0.h,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget gridCard(int index) {
    return Container(
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage(gridList[index]['image']), // your image path
          fit: BoxFit.cover, // cover, contain, fill, fitWidth, fitHeight
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Image.asset(
              gridList[index]['icon'],
              height: 50.h,
              width: 50.w,
            ),
          ),

          // SizedBox(height: 1.h),
          // Expanded(
          //   child: ,
          // ),
          // Spacer(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: gridList[index]['text1'],
                  fontSize: 20.h,
                  fontWeight: FontWeight.w800,
                  top: 5.h,
                  color: Colors.white,
                  bottom: 0.h,
                ),
                CustomText(
                  text: gridList[index]['text2'],
                  fontSize: 30.h,
                  fontWeight: FontWeight.w800,
                  top: 0.h,
                  color: Colors.white,
                  bottom: 0.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget headerTitle({required String text1}) {
    return CustomText(
      text: text1,
      fontSize: 28.h,
      fontWeight: FontWeight.w500,
      top: 2.h,
      bottom: 5.h,
    );
  }
}
