import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InvoiceDetailsWidget extends StatelessWidget {
  final String staffName;
  final String category;
  final List<String> serviceList;
  final String customerName;
  final String customerNumber;
  final String customerAddress;
  final String assignTo;
  final String time;
  final String invoiceNumber;
  final String dueDate;
  final List<String> notes;
  final int otherAmount;
  final int gst;
  final int totalDue;
  final String? priority;
  final String? difficulty;
  final String? status;
  final List<String>? attachmentImages;

  const InvoiceDetailsWidget({
    super.key,
    required this.staffName,
    required this.category,
    required this.serviceList,
    required this.customerName,
    required this.customerNumber,
    required this.customerAddress,
    required this.assignTo,
    required this.time,
    required this.invoiceNumber,
    required this.dueDate,
    required this.notes,
    required this.otherAmount,
    required this.gst,
    required this.totalDue,
    this.priority,
    this.difficulty,
    this.status,
    this.attachmentImages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Staff Name
          Text(
            staffName,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),

          // Category
          _buildDetailRow("Category:", category),
          SizedBox(height: 12.h),

          // Service List
          _buildServiceListRow("Service List:", serviceList),
          SizedBox(height: 12.h),

          // Customer Name
          _buildDetailRow("Customer Name:", customerName),
          SizedBox(height: 12.h),

          // Customer Number
          _buildDetailRow("Customer Number:", customerNumber),
          SizedBox(height: 12.h),

          // Customer Address
          _buildDetailRow("Customer Address:", customerAddress),
          SizedBox(height: 12.h),

          // Assign To
          _buildDetailRow("Assign To:", assignTo),
          SizedBox(height: 12.h),

          // Time
          _buildDetailRow("Time:", time),
          SizedBox(height: 12.h),

          // Invoice Number
          _buildDetailRow("Invoice No.", invoiceNumber),
          SizedBox(height: 12.h),

          // Due Date
          _buildDetailRow("Due Date:", dueDate),
          SizedBox(height: 12.h),

          // Notes
          if (notes.isNotEmpty) ...[
            _buildDetailRow("Notes:", notes.join(", ")),
            SizedBox(height: 12.h),
          ],

          // Other Amount
          _buildDetailRow("Other Amount:", "\$${otherAmount.toString()}"),
          SizedBox(height: 12.h),

          // GST
          _buildDetailRow("GST:", "$gst%"),
          SizedBox(height: 12.h),

          // Total Due
          _buildDetailRow("Total Due:", "\$${totalDue.toString()}"),
          SizedBox(height: 16.h),

        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceListRow(String label, List<String> services) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: services.map((service) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  service,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color chipColor;
    Color textColor;

    switch (priority.toLowerCase()) {
      case 'high':
        chipColor = Color(0x66EF5350);
        textColor = Color(0xFFC62828);
        break;
      case 'medium':
        chipColor = Color(0x66FFA726);
        textColor = Color(0xFFE65100);
        break;
      case 'low':
        chipColor = Color(0x664CD964);
        textColor = Color(0xFF2E7D32);
        break;
      default:
        chipColor = Color(0x6664B5F6);
        textColor = Color(0xFF1565C0);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        'Priority: ${priority.toUpperCase()}',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color chipColor;
    Color textColor;

    switch (difficulty.toLowerCase()) {
      case 'hard':
        chipColor = Color(0x66EF5350);
        textColor = Color(0xFFC62828);
        break;
      case 'medium':
        chipColor = Color(0x66FFA726);
        textColor = Color(0xFFE65100);
        break;
      case 'easy':
        chipColor = Color(0x664CD964);
        textColor = Color(0xFF2E7D32);
        break;
      default:
        chipColor = Color(0x6664B5F6);
        textColor = Color(0xFF1565C0);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        'Difficulty: ${difficulty.toUpperCase()}',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
