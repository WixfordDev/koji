import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionDetailWidget extends StatelessWidget {
  final String staffName;
  final String category;
  final List<String> serviceList;
  final String customerName;
  final String customerNumber;
  final String customerAddress;
  final String assignTo;
  final String time;
  final String priority;
  final String difficulty;
  final String invoiceNo;
  final String amount;
  final String status;
  final List<String> attachmentImages;

  const TransactionDetailWidget({
    super.key,
    required this.staffName,
    required this.category,
    required this.serviceList,
    required this.customerName,
    required this.customerNumber,
    required this.customerAddress,
    required this.assignTo,
    required this.time,
    required this.priority,
    required this.difficulty,
    required this.invoiceNo,
    required this.amount,
    required this.status,
    required this.attachmentImages,
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

          // Priority
          _buildDetailRow("Priority", priority),
          SizedBox(height: 12.h),

          // Difficulty
          _buildDetailRow("Difficulty", difficulty),
          SizedBox(height: 12.h),

          // Invoice No
          _buildDetailRow("Invoice No.", invoiceNo),
          SizedBox(height: 12.h),

          // Amount
          _buildDetailRow("Amount", amount),
          SizedBox(height: 16.h),

          // Attachments and Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Attachment Images
              Row(
                children: attachmentImages.map((image) {
                  return Container(
                    margin: EdgeInsets.only(right: 8.w),
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(
                        color: _getStatusDotColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: _getStatusTextColor(status),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Color(0x664CD964);
      case 'pending':
        return Color(0x66FFA726);
      case 'cancelled':
        return Color(0x66EF5350);
      default:
        return Color(0x6664B5F6);
    }
  }

  Color _getStatusDotColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Color(0xFF4CD964);
      case 'pending':
        return Color(0xFFFFA726);
      case 'cancelled':
        return Color(0xFFEF5350);
      default:
        return Color(0xFF64B5F6);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Color(0xFF2E7D32);
      case 'pending':
        return Color(0xFFE65100);
      case 'cancelled':
        return Color(0xFFC62828);
      default:
        return Color(0xFF1565C0);
    }
  }
}