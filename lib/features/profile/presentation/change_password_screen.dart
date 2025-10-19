import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/shared_widgets/custom_auth_text_field.dart';
import '../../../constants/app_color.dart';
import '../../../shared_widgets/custom_button.dart';
import '../../../shared_widgets/custom_text.dart';





class ChangePasswordScreen extends StatefulWidget {
  ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
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
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     Future.delayed(Duration.zero, () => isMatched.value = false);
                //     return 'Please enter your confirm password';
                //   } else if (setNewPassCtrl.text == value) {
                //     Future.delayed(Duration.zero, () => isMatched.value = true);
                //     return null;
                //   } else {
                //     Future.delayed(Duration.zero, () => isMatched.value = false);
                //     return 'Password Not Matching';
                //   }
                // },
                // onChanged: (value) {
                //   isMatched.value = setNewPassCtrl.text == value;
                // },
              ),
              // Obx(() => Align(
              //     alignment: Alignment.centerLeft,
              //     child: CustomText(
              //       text: isMatched.value ? 'Password Matched' : "",
              //       color: Colors.green,
              //       fontsize: 14.sp,
              //     ))),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {

                },
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















              CustomButton(
                title: 'Update',
                onpress: () {

                },),
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );


  }








  final TextEditingController oldPassCtrl = TextEditingController();
  final TextEditingController setNewPassCtrl = TextEditingController();
  final TextEditingController reenterNewPassCtrl = TextEditingController();


}


