import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/controller/auth_controller.dart';
import 'package:koji/helpers/prefs_helper.dart';
import 'package:koji/routes/route_helper.dart';
import 'package:koji/shared_widgets/custom_auth_text_field.dart';
import 'package:koji/shared_widgets/custom_button.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool _rememberMe = false;

  static const _keyRememberMe = 'rememberMe';
  static const _keyRememberedEmail = 'rememberedEmail';
  static const _keyRememberedPassword = 'rememberedPassword';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final remember = await PrefsHelper.getBool(_keyRememberMe);
    if (!remember) return;
    final email = await PrefsHelper.getString(_keyRememberedEmail);
    final password = await PrefsHelper.getString(_keyRememberedPassword);
    if (!mounted) return;
    setState(() {
      _rememberMe = true;
      emailCtrl.text = email;
      passwordCtrl.text = password;
    });
  }

  Future<void> _saveOrClearCredentials() async {
    if (_rememberMe) {
      await PrefsHelper.setBool(_keyRememberMe, true);
      await PrefsHelper.setString(_keyRememberedEmail, emailCtrl.text.trim());
      await PrefsHelper.setString(_keyRememberedPassword, passwordCtrl.text);
    } else {
      await PrefsHelper.setBool(_keyRememberMe, false);
      await PrefsHelper.remove(_keyRememberedEmail);
      await PrefsHelper.remove(_keyRememberedPassword);
    }
  }

  void _handleLogin() {
    if (!formKey.currentState!.validate()) return;
    _saveOrClearCredentials();
    authController.handleLogIn(
      emailCtrl.text.trim(),
      passwordCtrl.text,
      context: context,
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCFCFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50.h),

                  Center(
                    child: Image.asset(
                      'assets/images/splash.png',
                      height: 100.h,
                    ),
                  ),

                  SizedBox(height: 30.h),

                  Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Email Field
                  CustomAuthTextField(
                    controller: emailCtrl,
                    hintText: 'Enter Email',
                    keyboardType: TextInputType.emailAddress,
                    inputType: AuthInputType.email,
                  ),

                  SizedBox(height: 16.h),

                  // Password Field
                  CustomAuthTextField(
                    controller: passwordCtrl,
                    hintText: "Enter Password",
                    obscureText: true,
                    isPasswordField: true,
                    inputType: AuthInputType.password,
                  ),

                  SizedBox(height: 8.h),

                  // Remember Me + Forgot Password row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() => _rememberMe = !_rememberMe);
                          if (!_rememberMe) _saveOrClearCredentials();
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (val) {
                                  setState(() => _rememberMe = val ?? false);
                                  if (!(val ?? false)) _saveOrClearCredentials();
                                },
                                activeColor: const Color(0xFFF95555),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                side: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1.5,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Remember Password',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => RouteHelper.goToForgotPassword(
                          context,
                          email: emailCtrl.text,
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot Password',
                          style: TextStyle(fontSize: 13.sp, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40.h),

                  // Login Button
                  Obx(
                    () => CustomButton(
                      loading: authController.logInLoading.value,
                      title: "Login",
                      onpress: _handleLogin,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't Have An Account? ",
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/sign-up'),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
