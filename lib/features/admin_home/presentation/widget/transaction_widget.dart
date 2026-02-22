import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../models/admin-model/transaction_model.dart';
import '../../../../../routes/route_paths.dart';

class TransactionCard extends StatelessWidget {
  final Result transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (transaction.taskId != null) {
          context.pushNamed(
            RoutePaths.adminInvoiceDetailsScreen,
            queryParameters: {
              'type': 'invoice',
              'billingId': transaction.taskId!,
            },
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Center(
                child: Icon(
                  Icons.receipt,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name: ${transaction.employeeId?.fullName ?? 'N/A'}",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF162238),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Transaction ID: ${transaction.transactionId ?? 'N/A'}",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                  Text(
                    "Method: ${transaction.paymentMethod ?? 'N/A'}",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                  Text(
                    "Invoice: ${_extractFileName(transaction.invoice) ?? 'N/A'}",
                  ),
                ],
              ),
            ),

            // Amount and Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "\$${transaction.amount?.toStringAsFixed(2) ?? '0.00'}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  transaction.createdAt != null
                      ? "${transaction.createdAt!.day}.${transaction.createdAt!.month}.${transaction.createdAt!.year}"
                      : 'N/A',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return const Color(0xFF9E9E9E);
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFFC107);
      case 'failed':
      case 'cancelled':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String? _extractFileName(String? path) {
    if (path == null) return null;

    try {
      String fileName = path.split('/').last;

      if (fileName.contains('-')) {
        List<String> parts = fileName.split('-');
        if (parts.isNotEmpty) {
          String namePart = parts[0];
          if (fileName.contains('.')) {
            String extension = fileName.substring(fileName.lastIndexOf('.'));
            return "$namePart$extension";
          } else {
            return namePart;
          }
        }
      }

      return fileName;
    } catch (e) {
      return path;
    }
  }
}
