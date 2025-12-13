import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:koji/features/admin_home/presentation/widget/transaction_widget.dart';

import '../../../controller/admincontroller/admin_home_controller.dart';
import '../../../models/admin-model/transaction_model.dart';


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
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  SizedBox(width: 12.w),
                  Icon(Icons.search, color: Color(0xFF9E9E9E), size: 20.sp),
                  SizedBox(width: 8.w),
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
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    child: Icon(Icons.tune, color: Colors.black, size: 20.sp),
                  ),
                  SizedBox(width: 4.w),
                ],
              ),
            ),
          ),

          // Transaction List
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
    );
  }
}