import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DifficultySelectorWidget extends StatelessWidget {
  final String? selectedDifficulty;
  final VoidCallback onTap;
  final String? errorText;

  const DifficultySelectorWidget({
    Key? key,
    required this.selectedDifficulty,
    required this.onTap,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: hasError ? 4.h : 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Difficulty", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 6.h),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: hasError ? Colors.red.shade400 : Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDifficulty ?? "Select Difficulty",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Color(0xFFAC87C5), size: 20.r),
                ],
              ),
            ),
          ),
          if (hasError) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.error_outline, size: 12.sp, color: Colors.red.shade600),
                SizedBox(width: 4.w),
                Text(errorText!, style: TextStyle(fontSize: 11.sp, color: Colors.red.shade600)),
              ],
            ),
            SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }
}
