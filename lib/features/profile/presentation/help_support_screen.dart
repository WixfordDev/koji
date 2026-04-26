import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constants/app_color.dart';
import '../../../controller/profile_controller.dart';
import '../../../helpers/toast_message_helper.dart';
import '../../../shared_widgets/custom_auth_text_field.dart';
import '../../../shared_widgets/custom_button.dart';
import '../../../shared_widgets/custom_text.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  late ProfileController profileController = Get.find<ProfileController>();

  final TextEditingController issueCtrl = TextEditingController();
  final TextEditingController desCtrl = TextEditingController();
  final TextEditingController attachFileCtrl = TextEditingController();

  File? attachedFile;
  final ImagePicker _picker = ImagePicker();

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
                onTap: _pickFile,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.borderColor),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/attach.svg',
                        width: 24.w,
                        height: 24.h,
                        color: AppColor.secondaryColor,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          attachedFile != null
                              ? attachedFile!.path.split('/').last
                              : 'Attach File',
                          style: TextStyle(
                            color: attachedFile != null
                                ? AppColor.secondaryColor
                                : Colors.grey.shade600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      if (attachedFile != null)
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 20.r,
                            color: AppColor.redColor,
                          ),
                          onPressed: _clearAttachment,
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              Obx(() => CustomButton(
                title: profileController.helpSupportLoading.value ? 'Submitting...' : 'Submit',
                onpress: _submitHelpSupport,
                loading: profileController.helpSupportLoading.value,
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _pickFile() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (bytes.length > 20 * 1024 * 1024) {
          ToastMessageHelper.showToastMessage('File size must be less than 20MB', title: 'Error');
          return;
        }
        setState(() {
          attachedFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ToastMessageHelper.showToastMessage(
        'Error picking file: $e',
        title: 'Error',
      );
    }
  }

  void _clearAttachment() {
    setState(() {
      attachedFile = null;
    });
  }

  void _submitHelpSupport() {
    String title = issueCtrl.text.trim();
    String description = desCtrl.text.trim();

    if (title.isEmpty) {
      ToastMessageHelper.showToastMessage(
        'Please enter an issue title',
        title: 'Validation Error',
      );
      return;
    }

    if (description.isEmpty) {
      ToastMessageHelper.showToastMessage(
        'Please enter a description',
        title: 'Validation Error',
      );
      return;
    }

    profileController.helpSupport(
      title: title,
      description: description,
      files: attachedFile,
      screenType: 'help_support',
    ).then((_) {
      if (!profileController.helpSupportLoading.value) {
        // Clear form after successful submission
        issueCtrl.clear();
        desCtrl.clear();
        setState(() {
          attachedFile = null;
        });
      }
    });
  }
}
