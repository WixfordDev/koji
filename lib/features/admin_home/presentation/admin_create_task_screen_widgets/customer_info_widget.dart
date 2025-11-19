import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomerInfoWidget extends StatelessWidget {
  final TextEditingController customerNameController;
  final TextEditingController customerNumberController;
  final TextEditingController customerAddressController;
  final TextEditingController notesController;

  const CustomerInfoWidget({
    Key? key,
    required this.customerNameController,
    required this.customerNumberController,
    required this.customerAddressController,
    required this.notesController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          label: "Customer Name",
          hint: "Enter Customer Name",
          controller: customerNameController,
        ),
        _buildTextField(
          label: "Customer Number",
          hint: "Enter Customer Number",
          controller: customerNumberController,
        ),
        _buildTextField(
          label: "Customer Address",
          hint: "Enter Customer Address",
          controller: customerAddressController,
          maxLines: 3,
        ),
        _buildTextField(
          label: "Notes",
          hint: "Enter any additional notes",
          controller: notesController,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController? controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 6.h),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
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
                borderSide: BorderSide(color: Color(0xFFAC87C5)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }
}