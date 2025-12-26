import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koji/controller/profile_controller.dart';
import 'package:koji/shared_widgets/custom_auth_text_field.dart';
import 'package:koji/helpers/toast_message_helper.dart';
import '../../../constants/app_color.dart';
import '../../../global/custom_assets/assets.gen.dart';
import '../../../services/api_constants.dart';
import '../../../shared_widgets/custom_button.dart';
import '../../../shared_widgets/custom_text.dart';





class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late ProfileController profileController;

  @override
  void initState() {
    super.initState();
    profileController = Get.find<ProfileController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.getProfile();
    });
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

          ],
        ),

      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(

          child: Obx(()=>
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 24.h),
                          Center(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                GestureDetector(
                                  onTap: _showImagePickerOptions,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100.r),
                                    child: _pickedImage != null
                                        ? Image.file(
                                      _pickedImage!,
                                      width: 100.r,
                                      height: 100.r,
                                      fit: BoxFit.cover,
                                    )
                                        : profileController.profile.value.user?.image != null
                                        ? Image.network(
                                      "${ApiConstants.imageBaseUrl}${profileController.profile.value.user!.image!}",
                                      width: 100.r,
                                      height: 100.r,
                                      fit: BoxFit.cover,
                                    )
                                        : Image.asset(
                                      "assets/images/profile.png",
                                      width: 100.r,
                                      height: 100.r,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -4.h,
                                  right: -4.w,
                                  child: Container(
                                    width: 24.w,
                                    height: 24.h,
                                    padding: EdgeInsets.fromLTRB(5.6.w, 4.h, 5.6.w, 4.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: const Color(0xFFEFEFEF),
                                        width: 0.86.w,
                                      ),
                                    ),
                                    child: Assets.icons.camera.svg(
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          CustomText(
                            text: profileController.profile.value.user?.firstName ?? 'N/A',
                            fontSize: 24.sp,
                            color: AppColor.secondaryColor,
                          ),
                          CustomText(
                            text: profileController.profile.value.user?.role ?? 'N/A',
                            fontSize: 14.sp,
                            color: AppColor.textColor707070,
                          ),
                          SizedBox(height: 4.h),
                          CustomText(
                            text: 'ID: ${profileController.profile.value.user?.id ?? 'N/A'}',
                            fontSize: 14.sp,
                            color: AppColor.textColor707070,
                          ),
                          SizedBox(height: 12.h),
                          CustomText(
                            text: 'My Profile',
                            fontSize: 16.sp,
                            color: AppColor.secondaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),
                  CustomText(
                    text: 'Employee ID',
                    fontSize: 14.sp,
                    color: AppColor.secondaryColor,
                  ),
                  SizedBox(height: 4.h),
                  CustomAuthTextField(
                    controller: employeeIdCtrl,
                    hintText: 'ID: ${profileController.profile.value.user?.id ?? 'N/A'}',

                  ),

                  SizedBox(height: 16.h),
                  CustomText(
                    text: 'Your Name',
                    fontSize: 14.sp,
                    color: AppColor.secondaryColor,
                  ),
                  SizedBox(height: 4.h),
                  CustomAuthTextField(
                    controller: nameCtrl,
                    hintText: profileController.profile.value.user?.firstName ?? 'N/A',
                  ),

                  SizedBox(height: 16.h),
                  CustomText(
                    text: 'E-mail',
                    fontSize: 14.sp,
                    color: AppColor.secondaryColor,
                  ),
                  SizedBox(height: 4.h),
                  CustomAuthTextField(
                    controller: emailCtrl,
                    hintText: profileController.profile.value.user?.email ?? 'N/A',
                  ),


                  SizedBox(height: 16.h),

                  CustomText(
                    text: 'Gender',
                    fontSize: 14.sp,
                    color: AppColor.secondaryColor,
                  ),
                  SizedBox(height: 4.h),
                  CustomAuthTextField(
                    controller: genderCtrl,
                    hintText: "Male",
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF9E9E9E),
                      size: 20.sp,
                    ),
                    onSuffixTap: _showGenderSelector,
                  ),



                  SizedBox(height: 16.h),

                  CustomText(
                    text: 'Date of Birth',
                    fontSize: 14.sp,
                    color: AppColor.secondaryColor,

                  ),
                  SizedBox(height: 4.h),
                  CustomAuthTextField(
                    controller: dateOfBirthCtrl,
                    hintText: profileController.profile.value.user?.dateOfBirth ?? 'N/A',
                    suffixIcon: Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF9E9E9E),
                      size: 18.sp,
                    ),
                    onSuffixTap: _pickDateOfBirth,
                  ),


                  SizedBox(height: 16.h),

                  CustomText(
                    text: 'Marital Status',
                    fontSize: 14.sp,
                    color: AppColor.secondaryColor,
                  ),
                  SizedBox(height: 4.h),
                  CustomAuthTextField(
                    controller: maritalCtrl,
                    hintText: "Unmarried",
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF9E9E9E),
                      size: 20.sp,
                    ),
                    onSuffixTap: _showMaritalStatusSelector,
                  ),


                  SizedBox(height: 16.h),

                  CustomText(
                    text: 'Phone No.',
                    fontSize: 14.sp,
                    color: AppColor.secondaryColor,
                  ),
                  SizedBox(height: 4.h),
                  CustomAuthTextField(
                    controller: phoneCtrl,
                    hintText: profileController.profile.value.user?.phoneNumber ?? 'N/A',
                  ),


                  SizedBox(height: 16.h),

                  CustomText(
                    text: 'Address',
                    fontSize: 14.sp,
                    color: AppColor.secondaryColor,
                  ),
                  SizedBox(height: 4.h),
                  CustomAuthTextField(
                    controller: addressCtrl,
                    hintText: profileController.profile.value.user?.address ?? 'N/A',
                  ),
                  SizedBox(height: 24.h),
                  Obx(() =>
                      CustomButton(
                        title: profileController.updateProfileLoading.value ? 'Updating...' : 'Update',
                        onpress: () {
                          if (!profileController.updateProfileLoading.value) {
                            _updateProfile();
                          }
                        },
                      ),
                  ),
                  SizedBox(height: 80.h),
                ],
              ),
          ),
        ),
      ),
    );
  }



  final TextEditingController employeeIdCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController genderCtrl = TextEditingController(text: "Male");
  final TextEditingController dateOfBirthCtrl =
  TextEditingController(text: "1 January, 2000");
  final TextEditingController maritalCtrl =
  TextEditingController(text: "Unmarried");


  File? _pickedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
    Navigator.pop(context);
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.black),
                title: const Text("Take a Photo"),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.black),
                title: const Text("Choose from Gallery"),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }


  // ---- GENDER SELECT ----
  void _showGenderSelector() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Male'),
              onTap: () {
                genderCtrl.text = 'Male';
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Female'),
              onTap: () {
                genderCtrl.text = 'Female';
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Other'),
              onTap: () {
                genderCtrl.text = 'Other';
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---- MARITAL STATUS SELECT ----
  void _showMaritalStatusSelector() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Unmarried'),
              onTap: () {
                maritalCtrl.text = 'Unmarried';
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Married'),
              onTap: () {
                maritalCtrl.text = 'Married';
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Divorced'),
              onTap: () {
                maritalCtrl.text = 'Divorced';
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---- DATE PICKER ----
  Future<void> _pickDateOfBirth() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final formatted = "${pickedDate.day} ${_monthName(pickedDate.month)}, ${pickedDate.year}";
      dateOfBirthCtrl.text = formatted;
    }
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Future<void> _updateProfile() async {
    // Validate required fields
    if (nameCtrl.text.trim().isEmpty) {
      ToastMessageHelper.showToastMessage(
        "Please enter your name",
        title: 'Error',
      );
      return;
    }

    if (phoneCtrl.text.trim().isEmpty) {
      ToastMessageHelper.showToastMessage(
        "Please enter your phone number",
        title: 'Error',
      );
      return;
    }

    // Call the profile update method from the controller
    await profileController.profileUpdate(
      firstName: nameCtrl.text.trim(),
      phoneNumber: phoneCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      file: _pickedImage,
      screenType: 'update',
    );
  }

}

