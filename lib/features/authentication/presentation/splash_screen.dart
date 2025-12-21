import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/core/app_constants.dart';
import 'package:koji/helpers/prefs_helper.dart';
import 'package:koji/routes/app_routes.dart';
import 'package:koji/routes/route_helper.dart';
import 'package:koji/shared_widgets/custom_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () async {
      var token = await PrefsHelper.getString(AppConstants.bearerToken);
      var role = await PrefsHelper.getString(AppConstants.role);

      if (token != null && token.isNotEmpty) {
        if (role == 'admin') {
          RouteHelper.goToAdminBottomNav(context);
          return;
        } else if (role == 'employee') {
          RouteHelper.goToEmployeeBottomNav(context);
          return;
        }
      } else {
        context.push('/onboarding');
      }
    });

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    // dispose the animation controller to avoid ticker leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 250.h),

              //  Assets.images.logo.image(height: 200.h, width: 200.w),
              Image.asset(
                'assets/images/splash.png',
                height: 200.h,
                width: 200.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
