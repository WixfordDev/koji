import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/shared_widgets/custom_auth_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  String? selectedRole;
  bool acceptTerms = false;

  final List<String> roles = ['User', 'Admin', 'Manager'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFCFCFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30.h),

              // Profile Image
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: 50.sp, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16.r,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.edit, size: 16.sp, color: Colors.white),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              Text(
                'Registration',
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
              ),

              SizedBox(height: 20.h),

              // Role Dropdown
              DropdownButtonFormField<String>(
                value: selectedRole,
                hint: Text('Select Role'),
                items: roles
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Full Name
              CustomAuthTextField(controller: nameCtrl, hintText: 'Full Name'),

              SizedBox(height: 16.h),

              // Email
              CustomAuthTextField(
                controller: emailCtrl,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 16.h),

              // Password
              CustomAuthTextField(
                controller: passwordCtrl,
                hintText: 'Password',
                obscureText: true,
                suffixIcon: Icon(Icons.visibility_off),
              ),

              SizedBox(height: 16.h),

              // Confirm Password
              CustomAuthTextField(
                controller: confirmPasswordCtrl,
                hintText: 'Confirm Password',
                obscureText: true,
                suffixIcon: Icon(Icons.visibility_off),
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
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/verifyScreen');
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Login Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "already have an account? ",
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
    );
  }
}
