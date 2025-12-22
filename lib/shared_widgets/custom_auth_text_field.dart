import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    this.isPasswordField = false, // Default false
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
        readOnly: widget.readOnly && widget.onSuffixTap == null,
        validator: widget.validator,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
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