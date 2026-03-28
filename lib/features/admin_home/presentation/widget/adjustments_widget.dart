import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdjustmentsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> adjustments;
  final VoidCallback onAdd;
  final Function(int) onRemove;
  final Function(int, String) onTypeChanged;
  final VoidCallback onChanged;

  const AdjustmentsWidget({
    super.key,
    required this.adjustments,
    required this.onAdd,
    required this.onRemove,
    required this.onTypeChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Adjustments (Deposit/Discount)",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF95555),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(Icons.add, color: Colors.white, size: 18.sp),
              ),
            ),
          ],
        ),
        if (adjustments.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: List.generate(adjustments.length, (index) {
                final adj = adjustments[index];
                final controller = adj['controller'] as TextEditingController;
                final type = adj['type'] as String;

                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index < adjustments.length - 1 ? 12.h : 0),
                  child: Row(
                    children: [
                      // Type Dropdown
                      Container(
                        height: 40.h,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: type,
                            isDense: true,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'discount',
                                child: Text('Discount'),
                              ),
                              DropdownMenuItem(
                                value: 'deposit',
                                child: Text('Deposit'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) onTypeChanged(index, val);
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),

                      // Amount Field
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            prefixText: "-\$",
                            prefixStyle: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.r),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.r),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.r),
                              borderSide:
                                  const BorderSide(color: Color(0xFFF95555)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            isDense: true,
                            hintText: "0.00",
                          ),
                          onChanged: (_) => onChanged(),
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Remove Button
                      GestureDetector(
                        onTap: () => onRemove(index),
                        child: Container(
                          padding: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6.r),
                            border:
                                Border.all(color: Colors.red.shade200),
                          ),
                          child: Icon(Icons.close,
                              color: Colors.red.shade600, size: 16.sp),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }
}
