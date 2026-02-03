import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomerDetailsWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController numberController;
  final TextEditingController emailController;

  const CustomerDetailsWidget({
    super.key,
    required this.nameController,
    required this.addressController,
    required this.numberController,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Customer Details",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16.h),

        // Customer Name
        _buildInputField(
          label: "Customer Name",
          controller: nameController,
          hintText: "Enter Customer Name",
        ),
        SizedBox(height: 16.h),

        // Customer Number
        _buildInputField(
          label: "Customer Number",
          controller: numberController,
          hintText: "Enter Customer Number",
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 16.h),

        // Customer Email
        _buildInputField(
          label: "Customer Email",
          controller: emailController,
          hintText: "Enter Customer Email",
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),

        // Customer Address
        _buildInputField(
          label: "Customer Address",
          controller: addressController,
          hintText: "Enter Customer Address",
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Color(0xFFF95555)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }
}