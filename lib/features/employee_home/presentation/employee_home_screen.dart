import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/constants/app_color.dart';
import 'package:koji/shared_widgets/custom_button.dart';
import 'package:koji/shared_widgets/custom_network_image.dart';
import 'package:koji/shared_widgets/custom_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  bool isCheckedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Profile Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomNetworkImage(
                        imageUrl: "https://example.com/image.jpg",
                        height: 40.h,
                        width: 40.w,
                        boxShape: BoxShape.circle,
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: "Good Morning,",
                            color: const Color(0xff8F8F8F),
                            fontSize: 12.sp,
                          ),
                          CustomText(
                            text: "Najibur Rahman",
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      context.push('/notificationScreen');
                    },
                    child: Icon(
                      Icons.notifications_none_outlined,
                      color: const Color(0xff8F8F8F),
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 96.h),

              // Center Clock and Date
              Center(
                child: Column(
                  children: [
                    CustomText(
                      text: "09:12",
                      fontWeight: FontWeight.bold,
                      fontSize: 60.sp,
                    ),
                    CustomText(
                      text: "Sunday, Sept 16",
                      color: const Color(0xff8F8F8F),
                      fontSize: 26.sp,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 60.h),

              // Check In / Check Out Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (isCheckedIn) {
                      _showConfirmCheckOutDialog();
                    } else {
                      setState(() => isCheckedIn = true);
                    }
                  },
                  child: Container(
                    height: 229.h,
                    width: 229.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isCheckedIn
                            ? [Colors.redAccent, Colors.red]
                            : [Colors.blueAccent, Colors.blue],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/hand.svg',
                          height: 60,
                          width: 60,
                        ),

                        SizedBox(height: 5.h),
                        CustomText(
                          text: isCheckedIn ? "CHECK OUT" : "CHECK IN",
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Location Text
              Center(
                child: CustomText(
                  text: isCheckedIn
                      ? "Location: You are not in Office reach"
                      : "Location: Singapore, Adam Park",
                  color: const Color(0xff8F8F8F),
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 62.h),

              // Bottom Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _infoItem("09:12", "Clock In"),
                  _infoItem(isCheckedIn ? "--:--" : "10:12", "Clock Out"),
                  _infoItem(isCheckedIn ? "--:--" : "01:12", "Total Hours"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String time, String label) {
    return Column(
      children: [
        CustomText(text: time, fontWeight: FontWeight.w600, fontSize: 14.sp),
        SizedBox(height: 4.h),
        CustomText(
          text: label,
          color: const Color(0xff8F8F8F),
          fontSize: 12.sp,
        ),
      ],
    );
  }

  void _showConfirmCheckOutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 90.h,
                  width: 90.w,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(15.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.access_time, color: Colors.white),
                ),

                SizedBox(height: 10.h),
                CustomText(
                  text: "Confirm Check Out",
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  maxline: 5,

                  text:
                      "Once you Check out, you won’t be able to edit this time. Please double-check your hours before proceeding.",
                  color: Colors.grey,
                  fontSize: 12.sp,
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _timeBox("Today", "08:00:00 Hrs"),
                    _timeBox("Overtime", "00:00:00 Hrs"),
                  ],
                ),
                SizedBox(height: 20.h),

                CustomButton(
                  title: "Yes Check Out",
                  onpress: () {
                    Navigator.pop(context);
                    _showCheckoutNoteDialog();
                  },
                ),

                SizedBox(height: 10.h),

                CustomButton(
                  color: Colors.transparent,
                  boderColor: AppColor.primaryColor,
                  titlecolor: AppColor.primaryColor,
                  title: "No, Let Me Check",
                  onpress: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCheckoutNoteDialog() {
    TextEditingController noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: "Daily Checkout Note",
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
                SizedBox(height: 10.h),
                CustomText(
                  text:
                      "Before You End Your Day, Please Take A Moment To Write Your Daily Checkout Note. Summarize The Tasks You Completed, Highlight Any Pending Work, And Mention If You Faced Any Challenges.",
                  color: Colors.grey,
                  fontSize: 12.sp,
                  maxline: 5,
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 15.h),
                TextField(
                  controller: noteCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Write your note here...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 15.h),

                CustomButton(
                  title: "Submit",
                  onpress: () {
                    Navigator.pop(context);
                    setState(() => isCheckedIn = false);
                  },
                ),

                SizedBox(height: 10.h),

                CustomButton(
                  color: Colors.transparent,
                  boderColor: AppColor.primaryColor,
                  titlecolor: AppColor.primaryColor,
                  title: "Skip",
                  onpress: () {
                    Navigator.pop(context);
                    setState(() => isCheckedIn = false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _timeBox(String label, String time) {
    return Container(
      width: 120.w,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.grey.shade100,
      ),
      child: Column(
        children: [
          CustomText(text: label, fontWeight: FontWeight.w500),
          SizedBox(height: 5.h),
          CustomText(text: time, color: Colors.grey),
        ],
      ),
    );
  }
}
