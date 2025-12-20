import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/controller/auth_controller.dart';
import 'package:koji/shared_widgets/custom_auth_text_field.dart';
import 'package:get/get.dart';
import 'package:koji/shared_widgets/custom_button.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final AuthController authController = Get.find<AuthController>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  bool acceptTerms = false;
  String? selectedRole;
  final List<String> roles = ['User', 'Admin', 'Manager'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCFCFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30.h),

                // Logo
                Center(
                  child: Image.asset('assets/images/splash.png', height: 100.h),
                ),

                SizedBox(height: 20.h),

                Text(
                  'Registration',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 20.h),

                // Full Name
                CustomAuthTextField(
                  controller: nameCtrl,
                  hintText: 'Full Name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // Email
                CustomAuthTextField(
                  controller: emailCtrl,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // Password
                CustomAuthTextField(
                  controller: passwordCtrl,
                  hintText: 'Password',
                  obscureText: true,
                  suffixIcon: const Icon(Icons.visibility_off),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // Confirm Password
                CustomAuthTextField(
                  controller: confirmPasswordCtrl,
                  hintText: 'Confirm Password',
                  obscureText: true,
                  suffixIcon: const Icon(Icons.visibility_off),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    } else if (value != passwordCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // Policy & Terms
                Row(
                  children: [
                    Checkbox(
                      value: acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          acceptTerms = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'I accept the ',
                          children: [
                            TextSpan(
                              text: 'policy & terms',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Sign Up Button
                Obx(
                  () => CustomButton(
                    loading: authController.signUpLoading.value,
                    title: "Sign Up",
                    onpress: () {
                      if (!acceptTerms) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please accept the policy & terms'),
                          ),
                        );
                        return;
                      }

                      if (formKey.currentState!.validate()) {
                        authController.handleSignUp(
                          email: emailCtrl.text.trim(),
                          firstName: nameCtrl.text.trim(),
                          password: passwordCtrl.text.trim(),
                          isAcceptPolicyTerms: true,
                          screenType: "Sign Up",
                          context: context,
                        );
                      }
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                // Login Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push('/sign-in');
                      },
                      child: Text(
                        "Log in",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
