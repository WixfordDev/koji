import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

enum AuthInputType { email, password, name, phone, general }

class CustomAuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool readOnly;
  final bool isPasswordField;
  final AuthInputType inputType;

  const CustomAuthTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.onSuffixTap,
    this.maxLines = 1,
    this.validator,
    this.readOnly = false,
    this.isPasswordField = false,
    this.inputType = AuthInputType.general,
  }) : super(key: key);

  @override
  State<CustomAuthTextField> createState() => _CustomAuthTextFieldState();
}

class _CustomAuthTextFieldState extends State<CustomAuthTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  void _toggleObscureText() {
    setState(() {
      _isObscured = !_isObscured;
    });
    if (widget.onSuffixTap != null) {
      widget.onSuffixTap!();
    }
  }

  String? _validateInput(String? value) {
    // Custom validator takes priority
    if (widget.validator != null) {
      final customResult = widget.validator!(value);
      if (customResult != null) return customResult;
    }

    // Auto validation based on input type
    if (value == null || value.isEmpty) {
      switch (widget.inputType) {
        case AuthInputType.email:
          return 'Please enter your email';
        case AuthInputType.password:
          return 'Please enter your password';
        case AuthInputType.name:
          return 'Please enter your name';
        case AuthInputType.phone:
          return 'Please enter your phone number';
        case AuthInputType.general:
          return 'This field is required';
      }
    }

    switch (widget.inputType) {
      case AuthInputType.email:
        if (!GetUtils.isEmail(value)) {
          return 'Please enter a valid email address';
        }
        break;
      case AuthInputType.password:
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        break;
      case AuthInputType.phone:
        if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
          return 'Please enter a valid phone number';
        }
        break;
      case AuthInputType.name:
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        break;
      case AuthInputType.general:
        // No additional validation
        break;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xffF1F1F1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.white10,
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _isObscured,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        readOnly: widget.readOnly,
        validator: _validateInput,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          errorStyle: TextStyle(
            color: Colors.red,
            fontSize: 12.sp,
          ),
          errorMaxLines: 2,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),
          suffixIcon: widget.isPasswordField
              ? GestureDetector(
            onTap: _toggleObscureText,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Icon(
                _isObscured ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
                size: 20.sp,
              ),
            ),
          )
              : widget.suffixIcon != null
              ? GestureDetector(
            onTap: widget.onSuffixTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: widget.suffixIcon,
            ),
          )
              : null,
        ),
      ),
    );
  }
}