import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/features/admin_home/presentation/widget/transaction_details_widget.dart';

class AdminTransactionDetailsScreen extends StatefulWidget {
  const AdminTransactionDetailsScreen({super.key});

  @override
  State<AdminTransactionDetailsScreen> createState() =>
      _AdminTransactionDetailsScreenState();
}

class _AdminTransactionDetailsScreenState
    extends State<AdminTransactionDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Transaction Report",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16.h),

            // Transaction Detail Card
            TransactionDetailWidget(
              staffName: "Handy Man Staff",
              category: "Plumbing Service",
              serviceList: [
                "Plumbing Service",
                "Plumbing Service",
                "Plumbing Service",
              ],
              customerName: "Najibur Rahman",
              customerNumber: "+6515484854",
              customerAddress: "Dhaka, Bangladesh",
              assignTo: "Koji Tech 123",
              time: "2:00 PM - 9:00 PM",
              priority: "Important",
              difficulty: "Medium",
              invoiceNo: "#Koji6565418166",
              amount: "\$2500",
              status: "Completed",
              attachmentImages: [
                "assets/images/task.png",
                "assets/images/task.png",
                "assets/images/task.png",
              ],
            ),



            // Download Invoice Button
            Padding(
              padding: EdgeInsets.all(17.w),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    // Download invoice logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF7D7D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Download Invoice",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 20.r,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
