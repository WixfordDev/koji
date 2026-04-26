import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/controller/profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:koji/routes/route_helper.dart';
import 'package:shimmer/shimmer.dart';
import '../../../constants/app_color.dart';
import '../../../core/app_constants.dart';
import '../../../global/custom_assets/assets.gen.dart';
import '../../../helpers/prefs_helper.dart';
import '../../../services/api_constants.dart';
import '../../../shared_widgets/custom_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      backgroundColor: AppColor.textColorF4F4F5,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Profile Header Card ───
            _buildProfileHeader(),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),

                  // ─── Account Section ───
                  _sectionLabel('Account'),
                  SizedBox(height: 8.h),
                  _buildMenuCard([
                    _menuItem(
                      icon: Assets.icons.myprofile.svg(
                        width: 20.w,
                        height: 20.h,
                        colorFilter: const ColorFilter.mode(
                            AppColor.primaryColor, BlendMode.srcIn),
                      ),
                      label: 'My Profile',
                      onTap: () => context.push('/myProfileScreen'),
                    ),
                    _menuDivider(),
                    _menuItem(
                      icon: Assets.icons.changepass.svg(
                        width: 20.w,
                        height: 20.h,
                        colorFilter: const ColorFilter.mode(
                            AppColor.primaryColor, BlendMode.srcIn),
                      ),
                      label: 'Change Password',
                      onTap: () => context.push('/changePasswordScreen'),
                    ),
                  ]),

                  SizedBox(height: 20.h),

                  // ─── Legal Section ───
                  _sectionLabel('Legal'),
                  SizedBox(height: 8.h),
                  _buildMenuCard([
                    _menuItem(
                      icon: Assets.icons.terms.svg(
                        width: 20.w,
                        height: 20.h,
                        colorFilter: const ColorFilter.mode(
                            AppColor.primaryColor, BlendMode.srcIn),
                      ),
                      label: 'Terms & Condition',
                      onTap: () => context.push('/termsConditionScreen'),
                    ),
                    _menuDivider(),
                    _menuItem(
                      icon: Assets.icons.privacy.svg(
                        width: 20.w,
                        height: 20.h,
                        colorFilter: const ColorFilter.mode(
                            AppColor.primaryColor, BlendMode.srcIn),
                      ),
                      label: 'Privacy Policy',
                      onTap: () => context.push('/privacyPolicyScreen'),
                    ),
                    _menuDivider(),
                    _menuItem(
                      icon: Assets.icons.terms.svg(
                        width: 20.w,
                        height: 20.h,
                        colorFilter: const ColorFilter.mode(
                            AppColor.primaryColor, BlendMode.srcIn),
                      ),
                      label: 'About Us',
                      onTap: () => context.push('/aboutUsScreen'),
                    ),
                  ]),

                  SizedBox(height: 20.h),

                  // ─── Support Section ───
                  _sectionLabel('Support'),
                  SizedBox(height: 8.h),
                  _buildMenuCard([
                    _menuItem(
                      icon: Assets.icons.help.svg(
                        width: 20.w,
                        height: 20.h,
                        colorFilter: const ColorFilter.mode(
                            AppColor.primaryColor, BlendMode.srcIn),
                      ),
                      label: 'Help & Support',
                      onTap: () => context.push('/helpSupportScreen'),
                    ),
                  ]),

                  SizedBox(height: 32.h),

                  // ─── Logout Button ───
                  _buildLogoutButton(),

                  SizedBox(height: 90.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Profile Header ───────────────────────────────────────────────────────

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppColor.borderColor.withOpacity(0.6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 32.h),
          child: Obx(
            () => Column(
              children: [
                // Avatar with ring
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.primaryColor,
                          width: 2.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(44.r),
                        child: profileController
                                    .profile.value.user?.image !=
                                null
                            ? CachedNetworkImage(
                                imageUrl:
                                    "${ApiConstants.imageBaseUrl}${profileController.profile.value.user!.image!}",
                                width: 88.r,
                                height: 88.r,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: AppColor.borderColor,
                                  highlightColor: AppColor.backgroundColor,
                                  child: Container(
                                    width: 88.r,
                                    height: 88.r,
                                    color: AppColor.borderColor,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Assets.images.profile.image(
                                  width: 88.r,
                                  height: 88.r,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Assets.images.profile.image(
                                width: 88.r,
                                height: 88.r,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    // Online dot indicator
                    Container(
                      width: 16.r,
                      height: 16.r,
                      margin: EdgeInsets.only(bottom: 2.h, right: 2.w),
                      decoration: BoxDecoration(
                        color: AppColor.successColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.backgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // Name
                CustomText(
                  text: profileController.profile.value.user?.firstName ??
                      'N/A',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.secondaryColor,
                ),

                SizedBox(height: 6.h),

                // Role badge
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColor.primaryColor.withOpacity(0.25),
                    ),
                  ),
                  child: Text(
                    (profileController.profile.value.user?.role ?? 'N/A')
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primaryColor,
                      letterSpacing: 0.8,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),

                SizedBox(height: 6.h),

                // ID
                CustomText(
                  text: () {
                    final id = profileController.profile.value.user?.id;
                    if (id == null || id.length < 6) return 'ID: N/A';
                    return 'ID: EMP-${id.substring(id.length - 6).toUpperCase()}';
                  }(),
                  fontSize: 12.sp,
                  color: AppColor.textColor707070,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Section Label ────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColor.textColor707070,
          letterSpacing: 1.4,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  // ─── Menu Card ────────────────────────────────────────────────────────────

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.borderColor.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // ─── Menu Item ────────────────────────────────────────────────────────────

  Widget _menuItem({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        splashColor: AppColor.primaryColor.withOpacity(0.04),
        highlightColor: AppColor.primaryColor.withOpacity(0.03),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: icon,
              ),

              SizedBox(width: 14.w),

              // Label
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColor.secondaryColor,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

              // Chevron
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: AppColor.textColor707070,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuDivider() {
    return Divider(
      height: 1,
      indent: 70.w,
      endIndent: 0,
      color: AppColor.borderColor,
    );
  }

  // ─── Logout Button ────────────────────────────────────────────────────────

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => _showLogoutConfirmationDialog(context),
      child: Container(
        width: double.infinity,
        height: 54.h,
        decoration: BoxDecoration(
          color: AppColor.redColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColor.redColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColor.redColor,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.redColor,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Logout Dialog ────────────────────────────────────────────────────────

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: AppColor.backgroundColor,
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon circle
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: AppColor.redColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppColor.redColor,
                    size: 26.sp,
                  ),
                ),

                SizedBox(height: 16.h),

                Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.secondaryColor,
                    fontFamily: 'Poppins',
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Are you sure you want to\nlog out of your account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColor.textColor707070,
                    fontFamily: 'Poppins',
                    height: 1.6,
                  ),
                ),

                SizedBox(height: 24.h),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: AppColor.borderColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textColor4F4F4F,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await PrefsHelper.remove(AppConstants.bearerToken);
                          await PrefsHelper.remove(AppConstants.role);
                          await PrefsHelper.setBool(AppConstants.isLogged, false);
                          await PrefsHelper.remove(AppConstants.name);
                          await PrefsHelper.remove(AppConstants.email);
                          await PrefsHelper.remove(AppConstants.userId);
                          await PrefsHelper.remove(AppConstants.image);
                          RouteHelper.goToSignIn(context);
                        },
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: AppColor.redColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.backgroundColor,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
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
