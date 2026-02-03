import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BankDetailsWidget extends StatelessWidget {
  final TextEditingController bankNameController;
  final TextEditingController accountNameController;
  final TextEditingController accountNumberController;
  final TextEditingController swiftCodeController;
  final TextEditingController qrCodeController;

  const BankDetailsWidget({
    super.key,
    required this.bankNameController,
    required this.accountNameController,
    required this.accountNumberController,
    required this.swiftCodeController,
    required this.qrCodeController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bank Details",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16.h),

        // Bank Name
        _buildInputField(
          label: "Bank Name",
          controller: bankNameController,
          hintText: "Enter Bank Name",
        ),
        SizedBox(height: 16.h),

        // Account Name
        _buildInputField(
          label: "Account Name",
          controller: accountNameController,
          hintText: "Enter Account Name",
        ),
        SizedBox(height: 16.h),

        // Account Number
        _buildInputField(
          label: "Account Number",
          controller: accountNumberController,
          hintText: "Enter Account Number",
        ),
        SizedBox(height: 16.h),

        // SWIFT Code
        _buildInputField(
          label: "SWIFT Code",
          controller: swiftCodeController,
          hintText: "Enter SWIFT Code",
        ),
        SizedBox(height: 16.h),

        // QR Code URL
        _buildInputField(
          label: "QR Code URL",
          controller: qrCodeController,
          hintText: "Enter QR Code URL",
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
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