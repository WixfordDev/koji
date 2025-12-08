import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:koji/controller/profile_controller.dart';
import '../../../constants/app_color.dart';
import '../../../shared_widgets/custom_text.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  // Get your controller instance
  final controller = Get.find<ProfileController>(); // Replace with your actual controller

  @override
  void initState() {
    super.initState();
    // Fetch privacy policy when screen loads
    controller.getPrivacyPolicy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.r),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 12.w),
            CustomText(
              text: "Privacy Policy",
              color: AppColor.secondaryColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
      body: Obx(() {
        // Show loading indicator
        if (controller.getPrivacyPolicyLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColor.secondaryColor,
            ),
          );
        }

        // Show content
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                // Display HTML content from API
                if (controller.privacyPolicyContent.value.isNotEmpty &&
                    controller.privacyPolicyContent.value != 'No privacy policy content available.')
                  Html(
                    data: controller.privacyPolicyContent.value,
                    style: {
                      "body": Style(
                        fontSize: FontSize(14.sp),
                        color: AppColor.secondaryColor,
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                      "h1": Style(
                        fontSize: FontSize(20.sp),
                        fontWeight: FontWeight.bold,
                        color: AppColor.secondaryColor,
                      ),
                      "p": Style(
                        fontSize: FontSize(14.sp),
                        color: AppColor.secondaryColor,
                        lineHeight: LineHeight(1.5),
                      ),
                      "strong": Style(
                        fontWeight: FontWeight.bold,
                      ),
                      "span": Style(
                        fontSize: FontSize(14.sp),
                        color: AppColor.secondaryColor,
                      ),
                    },
                  )
                else
                  Center(
                    child: CustomText(
                      text: controller.privacyPolicyContent.value,
                      fontSize: 14.sp,
                      color: AppColor.secondaryColor,
                      textAlign: TextAlign.center,
                    ),
                  ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      }),
    );
  }
}