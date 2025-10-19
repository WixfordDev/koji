import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_color.dart';
import '../../../shared_widgets/custom_text.dart';





class TermsConditionScreen extends StatefulWidget {
  TermsConditionScreen({super.key});

  @override
  State<TermsConditionScreen> createState() => _TermsConditionScreenState();
}

class _TermsConditionScreenState extends State<TermsConditionScreen> {
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
              text: "Terms & Condition",
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



              CustomText(
                text: 'Effective Date',
                fontSize: 12.sp,
                color: AppColor.secondaryColor,
              ),
              SizedBox(height: 4.h),
              CustomText(
                 textAlign: TextAlign.start,
                text: 'Effective Date: Premawell respects your privacy. This policy explains how we handle your information when you use our telemedicine servic',
                fontSize: 12.sp,
                color: AppColor.secondaryColor,
                maxline: 12,
              )














            ],
          ),
        ),
      ),
    );


  }


}


