import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_color.dart';
import '../../../global/custom_assets/assets.gen.dart';
import '../../../shared_widgets/custom_button.dart';
import '../../../shared_widgets/custom_delete_button.dart';
import '../../../shared_widgets/custom_text.dart';





class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});





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

          ],
        ),

      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 24.h),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40.r),
                      child: Image.asset(
                        "assets/images/profile.png",
                      ),),
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: 'Ebrahim Hossen',
                    fontSize: 24.sp,
                    color: AppColor.secondaryColor,
                  ),
                  CustomText(
                    text: 'Employee',
                    fontSize: 14.sp,
                    color: AppColor.textColor707070,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    text: 'ID: Koji Tech 123',
                    fontSize: 14.sp,
                    color: AppColor.textColor707070,
                  ),

                ],
              ),
              SizedBox(height: 32.h),
          
              /// ==================================> My Profile =============================>
              GestureDetector(
                onTap: () {

                  context.push('/myProfileScreen');
          
                },
                child: Container(
                  width: 345.w,
                  height: 54.h,
                  margin: EdgeInsets.only(left: 2.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                    border: Border.all(
                      color: AppColor.borderColor,
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          children: [
                            Assets.icons.myprofile.svg(
                              width: 22.w,
                              height: 22.h,
                            ),
                            SizedBox(width: 5.w),
                            CustomText(text: 'My Profile',
                              fontSize: 16.sp,
                              color: AppColor.secondaryColor,
                              fontWeight: FontWeight.w400,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child:  Assets.icons.chevron.svg(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
          
              /// ==================================> Change password =============================>
              GestureDetector(
                onTap: () {
                  context.push('/changePasswordScreen');
          
                },
                child: Container(
                  width: 345.w,
                  height: 54.h,
                  margin: EdgeInsets.only(left: 2.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                    border: Border.all(
                      color: AppColor.borderColor,
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          children: [
                            Assets.icons.changepass.svg(
                              width: 22.w,
                              height: 22.h,
                            ),
                            SizedBox(width: 5.w),
                            CustomText(text: 'Change Password',
                              fontSize: 16.sp,
                              color: AppColor.secondaryColor,                            fontWeight: FontWeight.w500,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child:  Assets.icons.chevron.svg(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
          
              /// ==================================> My Documents =============================>
              GestureDetector(
                onTap: () {
          
                },
                child: Container(
                  width: 345.w,
                  height: 54.h,
                  margin: EdgeInsets.only(left: 2.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                    border: Border.all(
                      color: AppColor.borderColor,
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          children: [
                            Assets.icons.mydoc.svg(
                              width: 22.w,
                              height: 22.h,
                            ),
                            SizedBox(width: 5.w),
                            CustomText(text: 'My Documents',
                              fontSize: 16.sp,
                              color: AppColor.secondaryColor,
                              fontWeight: FontWeight.w400,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child:  Assets.icons.chevron.svg(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
          
              /// ==================================> Terms =============================>
              GestureDetector(
                onTap: () {
                  context.push('/termsConditionScreen');
                },
                child: Container(
                  width: 345.w,
                  height: 54.h,
                  margin: EdgeInsets.only(left: 2.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                    border: Border.all(
                      color: AppColor.borderColor,
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          children: [
                            Assets.icons.terms.svg(
                              width: 22.w,
                              height: 22.h,
                            ),
                            SizedBox(width: 5.w),
                            CustomText(text: 'Terms & Condition',
                              fontSize: 16.sp,
                              color: AppColor.secondaryColor,
                              fontWeight: FontWeight.w400,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child:  Assets.icons.chevron.svg(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
          
              /// ==================================> Privacy Policy =============================>
              GestureDetector(
                onTap: () {
                  context.push('/privacyPolicyScreen');
                },
                child: Container(
                  width: 345.w,
                  height: 54.h,
                  margin: EdgeInsets.only(left: 2.w),
                  decoration: BoxDecoration(
                    // color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                    border: Border.all(
                      color: AppColor.borderColor,
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          children: [
                            Assets.icons.terms.svg(
                              width: 22.w,
                              height: 22.h,
                            ),
                            SizedBox(width: 5.w),
                            CustomText(text: 'Privacy Policy',
                              fontSize: 16.sp,
                              color: AppColor.secondaryColor,
                              fontWeight: FontWeight.w400,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child:  Assets.icons.chevron.svg(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
          
              /// ==================================> Help and Support  =============================>
              GestureDetector(
                onTap: () {
                  context.push('/helpSupportScreen');
                },
                child: Container(
                  width: 345.w,
                  height: 54.h,
                  margin: EdgeInsets.only(left: 2.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                    border: Border.all(
                      color: AppColor.borderColor,
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          children: [
                            Assets.icons.help.svg(
                              width: 22.w,
                              height: 22.h,
                            ),
                            SizedBox(width: 5.w),
                            CustomText(text: 'Help & Support',
                              fontSize: 16.sp,
                              color: AppColor.secondaryColor,
                              fontWeight: FontWeight.w400,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child:  Assets.icons.chevron.svg(),
                      ),
                    ],
                  ),
                ),
              ),
          
              SizedBox(height: 16.h),
          
              Divider(),
          
              SizedBox(height: 50.h),
          
          
              CustomButton(
                title: 'Log out',
                onpress: () {
                  _showLogoutConfirmationDialog(context);
                },
                color: AppColor.redColor,            ),
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColor.borderColor,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 12.h),
                CustomText(
                  text: 'Ready to Log out ?',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColor.secondaryColor,                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomDeleteTwoButton(
                        title: 'Cancel',
                        bgColor: AppColor.borderColor,
                        textColor: AppColor.secondaryColor,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomDeleteTwoButton(
                        title: 'Log Out',
                        bgColor: AppColor.successColor,
                        textColor: AppColor.backgroundColor,
                        onTap: () async {

                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}


