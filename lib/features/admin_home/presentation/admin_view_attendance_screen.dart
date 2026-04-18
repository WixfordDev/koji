import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/shared_widgets/custom_text.dart';
import 'package:koji/shared_widgets/custom_button.dart';

import '../../../services/api_constants.dart';

class AdminViewAttendanceScreen extends StatefulWidget {
  final String employeeName;
  final String role;
  final String? employeeEmail;
  final String? image;
  final String checkIn;
  final String breakTime;
  final String checkOut;

  const AdminViewAttendanceScreen({
    super.key,
    required this.employeeName,
    required this.role,
    this.employeeEmail,
    this.image,
    required this.checkIn,
    required this.breakTime,
    required this.checkOut,
  });

  @override
  State<AdminViewAttendanceScreen> createState() => _AdminViewAttendanceScreenState();
}

class _AdminViewAttendanceScreenState extends State<AdminViewAttendanceScreen> {
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController();
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.r),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 12.w),
            CustomText(
              text: "View Attendance",
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            /// Employee Card
            Container(
              width: 228.w,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: widget.image != null &&
                        widget.image!.isNotEmpty
                        ? NetworkImage(_getImageUrl(widget.image))
                        : AssetImage('assets/images/profile.png')
                    as ImageProvider,
                    child: (widget.image == null || widget.image!.isEmpty)
                        ? Icon(Icons.person, size: 40)
                        : null,
                  ),
                  SizedBox(height: 10.h),
                  CustomText(
                    text: widget.employeeName,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    text: widget.role,
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 4.h),
                  if (widget.employeeEmail != null &&
                      widget.employeeEmail!.isNotEmpty)
                    CustomText(
                      text: widget.employeeEmail!,
                      fontSize: 12.sp,
                      color: Colors.black54,
                    ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            /// Attendance Log Header
            Align(
              alignment: Alignment.centerLeft,
              child: CustomText(
                text: "Attendance Log",
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12.h),

            /// Attendance Details Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      CustomText(
                        text: "Check In",
                        fontSize: 12.sp,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 6.h),
                      CustomText(
                        text: widget.checkIn,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      CustomText(
                        text: "Break",
                        fontSize: 12.sp,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 6.h),
                      CustomText(
                        text: widget.breakTime,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      CustomText(
                        text: "Check Out",
                        fontSize: 12.sp,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 6.h),
                      CustomText(
                        text: widget.checkOut,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            /// Attendance Log Header
            Align(
              alignment: Alignment.centerLeft,
              child: CustomText(
                text: "Attendance Log",
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12.h),

            /// Notes Text Field
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: notesController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText:
                  "Before You End Your Day, Please Take A Moment To Write Your Daily Checkout Note. Summarize The Tasks You Completed, Highlight Any Pending Work, And Mention If You Faced Any Challenges. This Helps Your Employer Stay Updated And Ensures Smoother Planning For Tomorrow.",
                  hintStyle: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black54,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // /// Action Buttons
            // Row(
            //   children: [
            //     Expanded(
            //       child: CustomButton(
            //         title: "Reject",
            //         color: Colors.white,
            //         boderColor: Color(0xFFEB0000),
            //         onpress: () {
            //           // Handle reject action
            //         },
            //       ),
            //     ),
            //     SizedBox(width: 10.w),
            //     Expanded(
            //       child: CustomButton(
            //         title: "Approved",
            //         color: Color(0xFFF77F6E),
            //         boderColor: Colors.transparent,
            //         onpress: () {
            //           // Handle approve action
            //         },
            //       ),
            //     ),
            //   ],
            // ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }



  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    String baseUrl = ApiConstants.imageBaseUrl;
    return "$baseUrl$imageUrl";
  }
}