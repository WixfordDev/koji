import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/features/admin_home/presentation/widget/hotizontal_list.dart';

import '../../../shared_widgets/custom_text.dart';

class AdminTaskListScreen extends StatefulWidget {
  const AdminTaskListScreen({super.key});

  @override
  State<AdminTaskListScreen> createState() => _AdminTaskListScreenState();
}

class _AdminTaskListScreenState extends State<AdminTaskListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("My Task"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HorizontalListExample(
              items: [
                {"id": 1, "title": "ALL(20)"},
                {"id": 2, "title": "Banana"},
                {"id": 3, "title": "Orange"},
                {"id": 3, "title": "Orange"},
                {"id": 3, "title": "Orange"},
              ],
              onItemSelected: (selectedItem) {
                print(
                  "You clicked: ${selectedItem["title"]}, ID: ${selectedItem["id"]}",
                );
              },
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.r),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withValues(alpha: 0.2), // shadow color
                      //     spreadRadius: 2, // how much it spreads
                      //     blurRadius: 6, // how soft the shadow looks
                      //     offset: Offset(2, 3), // horizontal, vertical shift
                      //   ),
                      // ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              "assets/images/tasklist_buttton.png",
                              height: 40.h,
                              width: 40.w,
                            ),
                            SizedBox(width: 5.w),
                            CustomText(
                              text: "Hand Painting Service",
                              fontSize: 20.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              top: 0.h,
                              bottom: 0.h,
                            ),

                            // Text("Hand Painting Service",style: TextStyle(fontSize: 18.sp),),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/images/time_icon.png",
                                    height: 25.h,
                                    width: 25.h,
                                  ),
                                  SizedBox(width: 5.w),
                                  CustomText(
                                    text: "In Progress",
                                    fontSize: 20.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    top: 0.h,
                                    bottom: 0.h,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10.r),

                              ),

                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/images/flag.png",
                                    height: 25.h,
                                    width: 25.h,
                                  ),
                                  SizedBox(width: 5.w),
                                  CustomText(
                                    text: "High",
                                    fontSize: 20.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    top: 0.h,
                                    bottom: 0.h,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        LinearProgressIndicator(
                          value: 0.14,
                          // null = indeterminate
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(10.r),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                        SizedBox(height: 15.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.person),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.r),

                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/calendar-2.png",
                                        height: 25.h,
                                        width: 25.h,
                                      ),
                                      SizedBox(width: 5.w),
                                      CustomText(
                                        text: "27 Sept",
                                        fontSize: 20.sp,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        top: 0.h,
                                        bottom: 0.h,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.r),

                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/message.png",
                                        height: 25.h,
                                        width: 25.h,
                                      ),
                                      SizedBox(width: 5.w),
                                      CustomText(
                                        text: "2",
                                        fontSize: 20.sp,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        top: 0.h,
                                        bottom: 0.h,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        height: 80.h,
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.all(10.sp),
        child: Center(
          child: Container(
            alignment: Alignment.center,
            height: 50.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child:    CustomText(
              text: "Create Task",
              fontSize: 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              top: 0.h,
              bottom: 0.h,
            ),
            // child: Text("Create Task", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
