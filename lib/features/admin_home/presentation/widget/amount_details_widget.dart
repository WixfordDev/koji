import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AmountDetailsWidget extends StatelessWidget {
  final double subtotal;
  final TextEditingController otherAmountController;
  final TextEditingController gstController;
  final double total;
  final VoidCallback onAmountChanged;

  const AmountDetailsWidget({
    super.key,
    required this.subtotal,
    required this.otherAmountController,
    required this.gstController,
    required this.total,
    required this.onAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    double otherAmount = double.tryParse(otherAmountController.text) ?? 0.0;
    double gstPercentage = double.tryParse(gstController.text) ?? 0.0;
    double gstAmount = (subtotal + otherAmount) * (gstPercentage / 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Amount Details",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16.h),

        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // Subtotal
              _buildAmountRow(
                label: "Subtotal",
                value: "\$${subtotal.toStringAsFixed(2)}",
                isEditable: false,
              ),
              SizedBox(height: 12.h),

              // Other Amount
              _buildEditableAmountRow(
                label: "Other Amount",
                controller: otherAmountController,
                onChanged: onAmountChanged,
              ),
              SizedBox(height: 12.h),

              // GST
              Visibility(
                visible: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "GST",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        Container(
                          width: 80.w,
                          child: TextField(
                            controller: gstController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.end,
                            decoration: InputDecoration(
                              suffixText: "%",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.r),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.r),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.r),
                                borderSide: BorderSide(color: Color(0xFFF95555)),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              isDense: true,
                            ),
                            onChanged: (value) => onAmountChanged(),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          "\$${gstAmount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),

              Divider(color: Colors.grey.shade300, thickness: 1),
              SizedBox(height: 12.h),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "\$${total.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF95555),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow({
    required String label,
    required String value,
    required bool isEditable,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableAmountRow({
    required String label,
    required TextEditingController controller,
    required VoidCallback onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade700,
          ),
        ),
        Container(
          width: 100.w,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.end,
            decoration: InputDecoration(
              prefixText: "\$",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: BorderSide(color: Color(0xFFF95555)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              isDense: true,
            ),
            onChanged: (value) => onChanged(),
          ),
        ),
      ],
    );
  }
}