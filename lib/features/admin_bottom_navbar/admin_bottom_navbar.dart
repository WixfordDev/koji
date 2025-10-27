import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/features/admin_home/presentation/admin_home_screen.dart';
import 'package:koji/features/admin_map/admin_map_screen.dart';
import 'package:koji/features/admin_schedule/presentation/admin_schedule.dart';
import 'package:koji/features/message/presentation/message_screen.dart';
import 'package:koji/features/profile/presentation/profile_screen.dart';
import '../../../../global/custom_assets/assets.gen.dart';
import '../../../constants/app_color.dart';

class AdminBottomNavBar extends StatefulWidget {
  const AdminBottomNavBar({super.key});

  @override
  State<AdminBottomNavBar> createState() => _AdminBottomNavBarState();
}

class _AdminBottomNavBarState extends State<AdminBottomNavBar> {
  final List<Widget> screens = [
    AdminHomeScreen(),
    AdminScheduleScreen(),
    MessageListScreen(),
    TrackingScreen(),
    ProfileScreen(),
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: AppColor.backgroundColor,
        type: BottomNavigationBarType.fixed,
        elevation: 1,
        selectedItemColor: AppColor.selectedColor,
        unselectedItemColor: AppColor.unSelectedColor,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Assets.icons.home.svg(
              color: AppColor.unSelectedColor,
              width: 24.w,
              height: 24.h,
            ),
            activeIcon: Assets.icons.home.svg(
              color: AppColor.selectedColor,
              width: 22.w,
              height: 22.h,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Assets.icons.schedule.svg(
              color: AppColor.unSelectedColor,
              width: 22.w,
              height: 22.h,
            ),
            activeIcon: Assets.icons.schedule.svg(
              color: AppColor.selectedColor,
              width: 22.w,
              height: 22.h,
            ),
            label: "Schedule",
          ),
          BottomNavigationBarItem(
            icon: Assets.icons.message.svg(
              color: AppColor.unSelectedColor,
              width: 22.w,
              height: 22.h,
            ),
            activeIcon: Assets.icons.message.svg(
              color: AppColor.selectedColor,
              width: 22.w,
              height: 22.h,
            ),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Assets.icons.tracking.svg(
              color: AppColor.unSelectedColor,
              width: 22.w,
              height: 22.h,
            ),
            activeIcon: Assets.icons.tracking.svg(
              color: AppColor.selectedColor,
              width: 22.w,
              height: 22.h,
            ),
            label: "Tracking",
          ),
          BottomNavigationBarItem(
            icon: Assets.icons.profile.svg(
              color: AppColor.unSelectedColor,
              width: 22.w,
              height: 22.h,
            ),
            activeIcon: Assets.icons.profile.svg(
              color: AppColor.selectedColor,
              width: 22.w,
              height: 22.h,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
