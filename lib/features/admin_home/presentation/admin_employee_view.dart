import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/features/admin_home/presentation/widget/custom_expenssion_list.dart';

class AdminEmployeeView extends StatelessWidget {
  const AdminEmployeeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Employee'), centerTitle: true),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomExpansionList(
              title: 'Fruits',
              items: ['Apple', 'Banana', 'Orange', 'Mango'],
            ),
            CustomExpansionList(
              title: 'Fruits',
              items: ['Apple', 'Banana', 'Orange', 'Mango'],
            ),
            CustomExpansionList(
              title: 'Fruits',
              items: ['Apple', 'Banana', 'Orange', 'Mango'],
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        height: 80.h,
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.all(10.sp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: 50.h,

              width: 100.h,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text("Reject", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(width: 10.h),
            Container(
              alignment: Alignment.center,
              height: 50.h,

              width: 100.h,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text("Accept", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
