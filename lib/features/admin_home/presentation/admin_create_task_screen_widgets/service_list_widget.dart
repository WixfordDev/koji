import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../controller/admincontroller/department_controller.dart';


class ServiceListWidget extends StatefulWidget {
  final List<ServiceItemWithQuantity> selectedServiceList;
  final VoidCallback onAddPressed;
  final Function(int index) onRemovePressed;

  const ServiceListWidget({
    Key? key,
    required this.selectedServiceList,
    required this.onAddPressed,
    required this.onRemovePressed,
  }) : super(key: key);

  @override
  State<ServiceListWidget> createState() => _ServiceListWidgetState();
}

class _ServiceListWidgetState extends State<ServiceListWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Service List", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
              IconButton(
                onPressed: widget.onAddPressed,
                icon: Icon(Icons.add, size: 20.r, color: Color(0xFFAC87C5)),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: widget.selectedServiceList.isEmpty
                ? Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 40.h),
              child: Center(
                child: Text(
                  "No services added",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.selectedServiceList.length,
              itemBuilder: (context, index) {
                final serviceItemWithQuantity = widget.selectedServiceList[index];
                final service = serviceItemWithQuantity.serviceItem;
                final name = service.name ?? '';
                final price = service.price ?? '0';
                final quantity = serviceItemWithQuantity.quantity;

                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5FF),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(index == 0 ? 8.r : 0),
                      bottom: Radius.circular(index == widget.selectedServiceList.length - 1 ? 8.r : 0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Qty: $quantity",
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "₦$price",
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        onPressed: () => widget.onRemovePressed(index),
                        icon: Icon(Icons.delete_outline, size: 20.r, color: Colors.red.shade400),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}