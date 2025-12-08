import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:koji/controller/profile_controller.dart';
import '../../../constants/app_color.dart';
import '../../../shared_widgets/custom_text.dart';

class AboutUsScreen extends StatefulWidget {
  AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  // Get your controller instance
  final controller = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    // Fetch about us content when screen loads
    controller.getAboutUs();
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
              text: "About Us",
              color: AppColor.secondaryColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
      body: Obx(() {
        // Show loading indicator
        if (controller.getAboutUsLoading.value) {
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
                if (controller.aboutUsContent.value.isNotEmpty &&
                    controller.aboutUsContent.value != 'No about us content available.')
                  Html(
                    data: controller.aboutUsContent.value,
                    style: {
                      "body": Style(
                        fontSize: FontSize(14.sp),
                        color: AppColor.secondaryColor,
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                      "h2": Style(
                        fontSize: FontSize(18.sp),
                        fontWeight: FontWeight.bold,
                        color: AppColor.secondaryColor,
                        margin: Margins(top: Margin(12.h), bottom: Margin(8.h)),
                      ),
                      "h1": Style(
                        fontSize: FontSize(20.sp),
                        fontWeight: FontWeight.bold,
                        color: AppColor.secondaryColor,
                      ),
                      "p": Style(
                        fontSize: FontSize(14.sp),
                        color: AppColor.secondaryColor,
                        lineHeight: LineHeight(1.6),
                        margin: Margins(bottom: Margin(16.h)),
                      ),
                      "strong": Style(
                        fontWeight: FontWeight.bold,
                      ),
                    },
                  )
                else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: CustomText(
                        text: controller.aboutUsContent.value,
                        fontSize: 14.sp,
                        color: AppColor.secondaryColor,
                        textAlign: TextAlign.center,
                      ),
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