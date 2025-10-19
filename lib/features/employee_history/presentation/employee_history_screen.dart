import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_color.dart';
import '../../../shared_widgets/custom_text.dart';
import '../../../shared_widgets/history-widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              text: "History",
              color: AppColor.secondaryColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Filter Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: "Friday, 16 June, 2025",
                    color: AppColor.secondaryColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Row(
                      children: [
                        CustomText(
                          text: "All",
                          color: AppColor.secondaryColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.black, size: 20.sp),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.builder(
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return HistoryCardWidget(
                      title: "Maintenance Staff",
                      category: "Maintenance & Complexity",
                      time: "2:00 PM – 9:00 PM",
                      breakTime: "4:30 PM – 5:00 PM",
                      completed: true,
                      onTap: () {
                        context.push('/taskReportScreen');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
