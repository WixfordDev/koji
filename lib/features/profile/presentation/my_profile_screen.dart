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

  // Theme colors
  static const Color primaryDark = Color(0xFF162238);
  static const Color primaryBlue = Color(0xFF4082FB);

  // Controllers
  final TextEditingController employeeIdCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController genderCtrl = TextEditingController(text: 'male');
  final TextEditingController dateOfBirthCtrl = TextEditingController(text: '1 January, 2000');
  final TextEditingController maritalCtrl = TextEditingController(text: 'male');

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  // Track if fields have been populated from profile
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    profileController = Get.find<ProfileController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await profileController.getProfile();
      _populateFieldsFromProfile();
    });
  }

  /// Fill text fields with existing profile data — no setState, pure GetX
  void _populateFieldsFromProfile() {
    if (_isDataLoaded) return;
    final user = profileController.profile.value.user;
    if (user == null) return;

    _isDataLoaded = true;

    final id = user.id ?? '';
    employeeIdCtrl.text = id.length >= 6
        ? 'EMP-${id.substring(id.length - 6).toUpperCase()}'
        : id.isNotEmpty ? id : 'N/A';
    nameCtrl.text    = user.firstName   ?? '';
    emailCtrl.text   = user.email       ?? '';
    phoneCtrl.text   = user.phoneNumber ?? '';
    addressCtrl.text = user.address     ?? '';

    if (user.gender != null && user.gender!.isNotEmpty) {
      genderCtrl.text = user.gender!;
    }
    if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
      // Convert ISO format (2000-01-01T00:00:00.000Z) → readable (1 January, 2000)
      dateOfBirthCtrl.text = _formatDateOfBirth(user.dateOfBirth!);
    }
    if (user.maritalStatus != null && user.maritalStatus!.isNotEmpty) {
      maritalCtrl.text = user.maritalStatus!;
    }
  }

  /// Converts ISO date string OR already-formatted string to "1 January, 2000"
  String _formatDateOfBirth(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day} ${_monthName(dt.month)}, ${dt.year}';
    } catch (_) {
      // Already in readable format like "1 January, 2000"
      return raw;
    }
  }

  @override
  void dispose() {
    employeeIdCtrl.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    genderCtrl.dispose();
    dateOfBirthCtrl.dispose();
    maritalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            Text(
              'My Profile',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        // Show full-screen loader on initial profile fetch
        if (profileController.getProfileLoading.value && !_isDataLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        // Once profile loads, populate fields (called once)
        // Populate once when data arrives
        if (!_isDataLoaded && profileController.profile.value.user != null) {
          _populateFieldsFromProfile();
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),

                // ─── Avatar Section ───
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
                            _buildImageUrl(
                              ApiConstants.imageBaseUrl,
                              profileController.profile.value.user!.image!,
                            ),
                            width: 100.r,
                            height: 100.r,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _defaultAvatar(),
                          )
                              : _defaultAvatar(),
                        ),
                      ),
                      Positioned(
                        bottom: -4.h,
                        right: -4.w,
                        child: GestureDetector(
                          onTap: _showImagePickerOptions,
                          child: Container(
                            width: 28.w,
                            height: 28.h,
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [primaryDark, primaryBlue],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Assets.icons.camera.svg(
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),

                // Name + Role
                Center(
                  child: Column(
                    children: [
                      CustomText(
                        text: profileController.profile.value.user?.firstName ?? 'N/A',
                        fontSize: 20.sp,
                        color: AppColor.secondaryColor,
                      ),
                      SizedBox(height: 2.h),
                      CustomText(
                        text: profileController.profile.value.user?.role ?? 'N/A',
                        fontSize: 13.sp,
                        color: AppColor.textColor707070,
                      ),
                      SizedBox(height: 2.h),
                      CustomText(
                        text: () {
                          final id = profileController.profile.value.user?.id;
                          if (id == null || id.length < 6) return 'ID: N/A';
                          return 'ID: EMP-${id.substring(id.length - 6).toUpperCase()}';
                        }(),
                        fontSize: 13.sp,
                        color: AppColor.textColor707070,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // ─── Divider ───
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [primaryDark, primaryBlue],
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Edit Profile Information',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // ─── Form Fields ───
                _buildLabel('Employee ID'),
                SizedBox(height: 4.h),
                CustomAuthTextField(
                  controller: employeeIdCtrl,
                  hintText: 'Employee ID',
                  readOnly: true,
                ),

                SizedBox(height: 16.h),
                _buildLabel('Your Name *'),
                SizedBox(height: 4.h),
                CustomAuthTextField(
                  controller: nameCtrl,
                  hintText: 'Enter your name',
                ),

                SizedBox(height: 16.h),
                _buildLabel('E-mail'),
                SizedBox(height: 4.h),
                CustomAuthTextField(
                  controller: emailCtrl,
                  hintText: 'Enter email address',
                  readOnly: true, // Usually email is not editable
                ),

                SizedBox(height: 16.h),
                _buildLabel('Gender'),
                SizedBox(height: 4.h),
                GestureDetector(
                  onTap: _showGenderSelector,
                  child: CustomAuthTextField(
                    controller: TextEditingController(
                      text: genderCtrl.text.isNotEmpty
                          ? genderCtrl.text[0].toUpperCase() + genderCtrl.text.substring(1)
                          : '',
                    ),
                    hintText: 'Select gender',
                    readOnly: true,
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF9E9E9E),
                      size: 20.sp,
                    ),
                    onSuffixTap: _showGenderSelector,
                  ),
                ),

                SizedBox(height: 16.h),
                _buildLabel('Date of Birth'),
                SizedBox(height: 4.h),
                // Date field - format ISO → readable on every build
                Builder(
                  builder: (context) {
                    final raw = dateOfBirthCtrl.text;
                    String display = raw;
                    try {
                      final dt = DateTime.parse(raw);
                      display = '\${dt.day} \${_monthName(dt.month)}, \${dt.year}';
                      // Also update controller so _pickDateOfBirth gets correct initialDate
                      if (dateOfBirthCtrl.text != display) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          dateOfBirthCtrl.text = display;
                        });
                      }
                    } catch (_) {}
                    return CustomAuthTextField(
                      controller: TextEditingController(text: display),
                      hintText: 'Select date of birth',
                      readOnly: true,
                      suffixIcon: Icon(
                        Icons.calendar_today_outlined,
                        color: const Color(0xFF9E9E9E),
                        size: 18.sp,
                      ),
                      onSuffixTap: _pickDateOfBirth,
                    );
                  },
                ),

                // SizedBox(height: 16.h),
                // _buildLabel('Marital Status'),
                // SizedBox(height: 4.h),
                // GestureDetector(
                //   onTap: _showMaritalStatusSelector,
                //   child: CustomAuthTextField(
                //     controller: TextEditingController(
                //       text: maritalCtrl.text.isNotEmpty
                //           ? maritalCtrl.text[0].toUpperCase() + maritalCtrl.text.substring(1)
                //           : '',
                //     ),
                //     hintText: 'Select marital status',
                //     readOnly: true,
                //     suffixIcon: Icon(
                //       Icons.keyboard_arrow_down_rounded,
                //       color: const Color(0xFF9E9E9E),
                //       size: 20.sp,
                //     ),
                //     onSuffixTap: _showMaritalStatusSelector,
                //   ),
                // ),

                SizedBox(height: 16.h),
                _buildLabel('Phone No. *'),
                SizedBox(height: 4.h),
                CustomAuthTextField(
                  controller: phoneCtrl,
                  hintText: 'Enter phone number',
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 16.h),
                _buildLabel('Address'),
                SizedBox(height: 4.h),
                CustomAuthTextField(
                  controller: addressCtrl,
                  hintText: 'Enter your address',
                ),

                SizedBox(height: 28.h),

                // ─── Update Button ───
                Obx(() {
                  final isLoading = profileController.updateProfileLoading.value;
                  return GestureDetector(
                    onTap: isLoading ? null : _updateProfile,
                    child: Container(
                      width: double.infinity,
                      height: 48.h,
                      decoration: BoxDecoration(
                        gradient: isLoading
                            ? null
                            : const LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [primaryDark, primaryBlue],
                        ),
                        color: isLoading ? Colors.grey.shade300 : null,
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      alignment: Alignment.center,
                      child: isLoading
                          ? SizedBox(
                        height: 22.h,
                        width: 22.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        'Update Profile',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }),

                SizedBox(height: 80.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─── Helpers ───

  Widget _buildLabel(String text) {
    return CustomText(
      text: text,
      fontSize: 14.sp,
      color: AppColor.secondaryColor,
    );
  }

  Widget _defaultAvatar() {
    return Image.asset(
      'assets/images/profile.png',
      width: 100.r,
      height: 100.r,
      fit: BoxFit.cover,
    );
  }

  String _buildImageUrl(String baseUrl, String imagePath) {
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final path = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '$base$path';
  }

  // ─── Validation ───

  String? _validateForm() {
    if (nameCtrl.text.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (nameCtrl.text.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (phoneCtrl.text.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    if (phoneCtrl.text.trim().length < 7) {
      return 'Please enter a valid phone number';
    }
    return null; // no error
  }

  // ─── Update Profile ───

  Future<void> _updateProfile() async {
    FocusScope.of(context).unfocus();

    final error = _validateForm();
    if (error != null) {
      ToastMessageHelper.showToastMessage(error, title: 'Validation Error');
      return;
    }

    await profileController.profileUpdate(
      firstName: nameCtrl.text.trim(),
      lastName: '',
      phoneNumber: phoneCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      gender: genderCtrl.text.trim(),
      maritalStatus: maritalCtrl.text.trim(),
      dateOfBirth: dateOfBirthCtrl.text.trim(),
      file: _pickedImage,
      screenType: 'update',
    );

    // On success show toast and go back
    if (!profileController.updateProfileLoading.value) {
      ToastMessageHelper.showToastMessage(
        'Profile update successful',
      );
      if (mounted) Navigator.pop(context);
    }
  }



  // ─── Image Picker ───

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // close bottom sheet first
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (bytes.length > 20 * 1024 * 1024) {
          ToastMessageHelper.showToastMessage('File size must be less than 20MB', title: 'Error');
          return;
        }
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ToastMessageHelper.showToastMessage(
        'Failed to pick image. Please try again.',
        title: 'Error',
      );
    }
  }

  void _showImagePickerOptions() {
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
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              'Select Profile Photo',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12.h),
            ListTile(
              leading: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt, color: primaryBlue, size: 20.sp),
              ),
              title: Text('Take a Photo', style: TextStyle(fontSize: 14.sp)),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.photo_library, color: primaryBlue, size: 20.sp),
              ),
              title: Text('Choose from Gallery', style: TextStyle(fontSize: 14.sp)),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  // ─── Gender Selector ───

  void _showGenderSelector() {
    _showOptionSelector(
      title: 'Select Gender',
      options: ['male', 'female', 'other'],
      displayOptions: ['Male', 'Female', 'Other'],
      currentValue: genderCtrl.text,
      onSelect: (val) {
        genderCtrl.text = val;
        setState(() {});
      },
    );
  }

  // ─── Marital Status Selector ───

  void _showMaritalStatusSelector() {
    _showOptionSelector(
      title: 'Select Marital Status',
      options: ['married', 'unmarried'],
      displayOptions: ['Married', 'Unmarried'],
      currentValue: maritalCtrl.text,
      onSelect: (val) {
        maritalCtrl.text = val;
        setState(() {});
      },
    );
  }

  /// Generic option selector bottom sheet
  void _showOptionSelector({
    required String title,
    required List<String> options,
    List<String>? displayOptions,
    String? currentValue,
    required Function(String) onSelect,
  }) {
    final labels = displayOptions ?? options;
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
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            ...List.generate(options.length, (i) {
              final value = options[i];
              final label = labels[i];
              final isSelected = value.toLowerCase() == (currentValue ?? '').toLowerCase();
              return ListTile(
                title: Text(label, style: TextStyle(fontSize: 14.sp)),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: primaryBlue, size: 20.sp)
                    : null,
                tileColor: isSelected ? primaryBlue.withOpacity(0.06) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                onTap: () {
                  onSelect(value);
                  Navigator.pop(context);
                },
              );
            }),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  // ─── Date Picker ───

  Future<void> _pickDateOfBirth() async {
    // Parse existing date if possible
    DateTime initialDate = DateTime(2000, 1, 1);
    try {
      final parts = dateOfBirthCtrl.text.split(' ');
      if (parts.length >= 3) {
        final day = int.tryParse(parts[0]) ?? 1;
        final month = _monthIndex(parts[1].replaceAll(',', ''));
        final year = int.tryParse(parts[2]) ?? 2000;
        initialDate = DateTime(year, month, day);
      }
    } catch (_) {}

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      dateOfBirthCtrl.text =
      '${pickedDate.day} ${_monthName(pickedDate.month)}, ${pickedDate.year}';
    }
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }

  int _monthIndex(String name) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final idx = months.indexWhere((m) => m.toLowerCase() == name.toLowerCase());
    return idx >= 0 ? idx + 1 : 1;
  }
}