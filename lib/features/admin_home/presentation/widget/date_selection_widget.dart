import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class DateSelectionWidget extends StatelessWidget {
  final DateTime? invoiceDate;
  final DateTime? dueDate;
  final Function(DateTime) onInvoiceDateSelected;
  final Function(DateTime) onDueDateSelected;

  const DateSelectionWidget({
    super.key,
    required this.invoiceDate,
    required this.dueDate,
    required this.onInvoiceDateSelected,
    required this.onDueDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Date Details",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16.h),

        // Invoice Date
        _buildDateField(
          context: context,
          label: "Invoice Date",
          selectedDate: invoiceDate,
          hintText: "Select Invoice Date",
          onDateSelected: onInvoiceDateSelected,
        ),
        SizedBox(height: 16.h),

        // Due Date
        _buildDateField(
          context: context,
          label: "Due Date",
          selectedDate: dueDate,
          hintText: "Select Due Date",
          onDateSelected: onDueDateSelected,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? selectedDate,
    required String hintText,
    required Function(DateTime) onDateSelected,
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
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Color(0xFFF95555),
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('dd MMM yyyy').format(selectedDate)
                      : hintText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: selectedDate != null
                        ? Colors.black
                        : Colors.grey.shade400,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20.r,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}