import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:koji/constants/app_color.dart';
import 'package:koji/core/app_constants.dart';
import 'package:koji/helpers/prefs_helper.dart';
import 'package:koji/shared_widgets/custom_text.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var pageDecoration = PageDecoration(
      bodyAlignment: Alignment.centerLeft,
      titleTextStyle: TextStyle(
        color: AppColor.primaryColor,
        fontSize: 36.sp,
        fontWeight: FontWeight.bold,
      ),
      bodyTextStyle: TextStyle(color: Colors.black54, fontSize: 17.sp),
      imagePadding: EdgeInsets.only(top: 40.h),
      contentMargin: EdgeInsets.symmetric(horizontal: 20.w),
    );

    final List<PageViewModel> pages = [
      PageViewModel(
        title: "",
        body:
            "You’re not just working hours; you’re building progress and shaping success.",
        image: Image.asset('assets/images/onboarding1.png', height: 320.h),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: "",
        body:
            "track your time, manage your leave, complete your tasks, and stay connected with your employer ",
        image: Image.asset('assets/images/onboarding2.png', height: 320.h),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: "",
        body:
            "Your Journey to Productivity, Simplicity, and Success Starts Here.",
        image: Image.asset('assets/images/onboarding3.png', height: 320.h),
        decoration: pageDecoration,
      ),
    ];

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 60.h),
        child: Column(
          children: [
            SizedBox(height: 40.h),
            Expanded(
              child: IntroductionScreen(
                pages: pages,
                onDone: () async {
                  // Mark onboarding as completed
                  await PrefsHelper.setBool(AppConstants.hasCompletedOnboarding, true);
                  // Navigate to signup screen
                  context.push('/sign-up');
                },
                onSkip: () {},
                skip: Text("Skip"),

                next: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.primaryColor,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.r),
                    child: Icon(
                      Icons.keyboard_arrow_right_sharp,
                      color: Colors.white,
                    ),
                  ),
                ),
                done: CustomText(
                  text: "Done",
                  fontSize: 16.sp,
                  color: AppColor.primaryColor,
                ),
                dotsDecorator: DotsDecorator(
                  size: Size.square(10.0),
                  activeSize: Size(20.0, 10.0),
                  activeColor: AppColor.primaryColor,
                  color: Color(0xffFFD6B0),
                  spacing: EdgeInsets.symmetric(horizontal: 4.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
