import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koji/shared_widgets/custom_button.dart';
import '../../../constants/app_color.dart';
import '../../../shared_widgets/custom_auth_text_field.dart';
import '../../../shared_widgets/custom_text.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController issueCtrl = TextEditingController();
  final TextEditingController desCtrl = TextEditingController();
  final TextEditingController attachFileCtrl = TextEditingController();

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
              text: "Help & Support",
              color: AppColor.secondaryColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),

              /// Issue Title
              CustomText(
                text: 'Issue Title',
                fontSize: 12.sp,
                color: AppColor.secondaryColor,
              ),
              SizedBox(height: 4.h),
              CustomAuthTextField(
                controller: issueCtrl,
                hintText: "Password Change Problem Issue",
              ),

              SizedBox(height: 12.h),

              /// Description
              CustomText(
                text: 'Description',
                fontSize: 12.sp,
                color: AppColor.secondaryColor,
              ),
              SizedBox(height: 4.h),
              CustomAuthTextField(
                maxLines: 6,
                controller: desCtrl,
                hintText:
                "Users are unable to update their password due to validation or system error, preventing successful password change.",
              ),

              SizedBox(height: 12.h),

              /// Attach
              CustomText(
                text: 'Attach',
                fontSize: 12.sp,
                color: AppColor.secondaryColor,
              ),
              SizedBox(height: 4.h),
              GestureDetector(
                onTap: () {

                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/attach.svg',
                      width: 24.w,
                      height: 24.h,
                      color: AppColor.secondaryColor,
                    ),
                    SizedBox(width: 10.w),
                    CustomText(
                      text: 'Attach File',
                      color: AppColor.secondaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              CustomButton(
                title: 'Submit',
                onpress: () {
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
