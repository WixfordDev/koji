import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/shared_widgets/custom_auth_text_field.dart';
import '../../../constants/app_color.dart';
import '../../../controller/auth_controller.dart';
import '../../../shared_widgets/custom_button.dart';
import '../../../shared_widgets/custom_text.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  final AuthController authController = Get.put(AuthController());

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
              text: "Change Password",
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
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                CustomText(
                  text: 'Enter Old Password',
                  fontSize: 12.sp,
                  color: AppColor.secondaryColor,
                ),
                SizedBox(height: 4.h),
                CustomAuthTextField(
                    controller: oldPassCtrl,
                    hintText: "Old Password",),
                SizedBox(height: 10.h),
                CustomText(
                  text: 'Set New Password',
                  fontSize: 12.sp,
                  color: AppColor.secondaryColor,
                ),
                SizedBox(height: 4.h),
                CustomAuthTextField(
                    controller: setNewPassCtrl,
                    hintText: "Set New Password",
                    ),
                SizedBox(height: 10.h),
                CustomText(
                  text: 'Re-Enter New Password',
                  fontSize: 12.sp,
                  color: AppColor.secondaryColor,
                ),
                SizedBox(height: 4.h),
                CustomAuthTextField(
                  controller: reenterNewPassCtrl,
                  hintText: "Re-Enter New Password",
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () {},
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      textAlign: TextAlign.start,
                      text: 'Forget password?',
                      color: AppColor.primaryColor,
                      fontSize: 12.sp,

                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Obx(() => CustomButton(
                  title: authController.changePasswordLoading.value ? 'Updating...' : 'Update',
                  onpress: _handleChangePassword,
                  loading: authController.changePasswordLoading.value,
                )),
                SizedBox(height: 80.h),
              ],
            ),
          ),
        ),
      ),
    );
  }


  final TextEditingController oldPassCtrl = TextEditingController();
  final TextEditingController setNewPassCtrl = TextEditingController();
  final TextEditingController reenterNewPassCtrl = TextEditingController();

  void _handleChangePassword() {
    String oldPassword = oldPassCtrl.text.trim();
    String newPassword = setNewPassCtrl.text.trim();
    String confirmNewPassword = reenterNewPassCtrl.text.trim();

    // Validate inputs
    if (oldPassword.isEmpty) {
      Get.snackbar('Error', 'Please enter your old password');
      return;
    }

    if (newPassword.isEmpty) {
      Get.snackbar('Error', 'Please enter your new password');
      return;
    }

    if (confirmNewPassword.isEmpty) {
      Get.snackbar('Error', 'Please confirm your new password');
      return;
    }

    if (newPassword != confirmNewPassword) {
      Get.snackbar('Error', 'New password and confirmation do not match');
      return;
    }

    // Call the change password method in the controller
    authController.changePassword(oldPassword, newPassword);
  }
}


