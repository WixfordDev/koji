import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:koji/features/admin_home/presentation/widget/transaction_widget.dart';
import 'package:koji/shared_widgets/custom_text.dart';
import '../../../controller/admincontroller/admin_home_controller.dart';
import '../../../models/admin-model/transaction_model.dart';
import 'admin_create_new_invoice_screen.dart';


class AdminTransactionScreen extends StatefulWidget {
  const AdminTransactionScreen({super.key});

  @override
  State<AdminTransactionScreen> createState() =>
      _AdminTransactionScreenState();
}

class _AdminTransactionScreenState extends State<AdminTransactionScreen> {

  late AdminHomeController adminHomeController;



  @override
  void initState() {
    super.initState();
    adminHomeController = Get.find<AdminHomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adminHomeController.getTransaction();
    });
  }

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
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(25.w, 16.h, 25.w, 16.h),
            child: Container(
              width: 357.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  Icon(Icons.search, color: Color(0xFF9E9E9E), size: 20.sp),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 14.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          /// ============> All Invoices Filter Tabs =============
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 12.h),
            child: Row(
              children: [
                // All Tab (Selected)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEC526A), Color(0xFFF77F6E)],
                      stops: [0.0075, 0.9527],
                    ),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    'All',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Invoices Tab
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                      color: Color(0xFFC8C8C8),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Invoices',
                    style: TextStyle(
                      color: Color(0xFF424242),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Quotes Tab
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                      color: Color(0xFFC8C8C8),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Quotes',
                    style: TextStyle(
                      color: Color(0xFF424242),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),



          Expanded(
            child: Obx(() {
              if (adminHomeController.getTransactionLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              List<Result>? transactions = adminHomeController.transaction.value.results;

              if (transactions == null || transactions.isEmpty) {
                return const Center(
                  child: Text('No transactions found'),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  return TransactionCard(
                    transaction: transactions[index],
                  );
                },
              );
            }),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AdminCreateInvoiceScreen(
              ),
            ),
          ).then((value) {
            // Refresh transaction list after returning from invoice creation
            adminHomeController.getTransaction();
          });
        },
        backgroundColor: Color(0xFFF95555),
        child: Icon(Icons.add, color: Colors.white, size: 24.sp),
      ),
    );
  }
}

