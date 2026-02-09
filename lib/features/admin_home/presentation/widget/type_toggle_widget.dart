import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TypeToggleWidget extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const TypeToggleWidget({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 357.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(100.r),
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged("invoice"),
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: selectedType == "invoice" ? Color(0xFFFBFBFB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(100.r),
                  border: selectedType == "invoice"
                      ? Border.all(color: Color(0xFFF95555), width: 1)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Invoice",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: selectedType == "invoice" ? Color(0xFFF95555) : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged("quote"),
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: selectedType == "quote" ? Color(0xFFFBFBFB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(100.r),
                  border: selectedType == "quote"
                      ? Border.all(color: Color(0xFFF95555), width: 1)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Quote",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: selectedType == "quote" ? Color(0xFFF95555) : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}