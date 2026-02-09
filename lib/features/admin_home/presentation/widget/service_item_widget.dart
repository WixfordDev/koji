import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/app_color.dart';
import '../../../../helpers/toast_message_helper.dart';
import '../../../../models/admin-model/all_serviceList_model.dart';

class ServiceItemsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> serviceItems;
  final List<ServiceItem> availableServices;
  final Function(Map<String, dynamic>) onAddService;
  final Function(int) onRemoveService;
  final Function(int, Map<String, dynamic>) onEditService;

  const ServiceItemsWidget({
    super.key,
    required this.serviceItems,
    required this.availableServices,
    required this.onAddService,
    required this.onRemoveService,
    required this.onEditService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Service Items",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            InkWell(
              onTap: () {
                _showServicePickerDialog(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEC526A),
                      Color(0xFFF77F6E),
                    ],
                    stops: [0.0075, 0.9527],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18.r, color: Colors.white),
                    SizedBox(width: 4.w),
                    Text(
                      "Add Service",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Service Items List
        if (serviceItems.isEmpty)
          Container(
            padding: EdgeInsets.all(40.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48.r,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "No services added yet",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...serviceItems.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> service = entry.value;
            return _buildServiceCard(context, index, service);
          }).toList(),
      ],
    );
  }

  Widget _buildServiceCard(
      BuildContext context, int index, Map<String, dynamic> service) {
    double price = double.tryParse(service['price'].toString()) ?? 0.0;
    int quantity = int.tryParse(service['quantity'].toString()) ?? 0;
    double total = price * quantity;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  service['name'],
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _showEditServiceDialog(context, index, service);
                    },
                    icon: Icon(Icons.edit, size: 18.r, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  SizedBox(width: 12.w),
                  IconButton(
                    onPressed: () {
                      onRemoveService(index);
                    },
                    icon: Icon(Icons.delete, size: 18.r, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                "Qty: $quantity",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                "Price: \$$price",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "Total: \$${total.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showServicePickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Service",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: 20.r),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search service...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: availableServices.isEmpty
                    ? Center(child: Text("No services available"))
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableServices.length,
                  itemBuilder: (context, index) {
                    final service = availableServices[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.name ?? '',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "\$${service.price ?? '0'}",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              _showServiceFormDialog(context, service);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFEC526A),
                                    Color(0xFFF77F6E),
                                  ],
                                  stops: [0.0075, 0.9527],
                                ),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                "Add",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
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
      },
    );
  }

  void _showServiceFormDialog(BuildContext context, ServiceItem service) {
    TextEditingController nameController =
    TextEditingController(text: service.name);
    TextEditingController quantityController =
    TextEditingController(text: "1");
    TextEditingController priceController =
    TextEditingController(text: service.price);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Text(
            "Add Service",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Service Name",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Enter service name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 16.h),
                Text(
                  "Quantity",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    hintText: "Enter quantity",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.h),
                Text(
                  "Price",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    hintText: "Enter price",
                    prefixText: "\$",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            InkWell(
              onTap: () {
                int quantity =
                    int.tryParse(quantityController.text.trim()) ?? 1;
                String price = priceController.text.trim();

                if (quantity < 1) {
                  ToastMessageHelper.showToastMessage(
                      "Quantity must be at least 1");
                  return;
                }

                if (price.isEmpty || double.tryParse(price) == null) {
                  ToastMessageHelper.showToastMessage(
                      "Please enter a valid price");
                  return;
                }

                onAddService({
                  'name': nameController.text.trim(),
                  'quantity': quantity.toString(),
                  'price': price,
                });

                Navigator.pop(context);
                ToastMessageHelper.showToastMessage(
                    "Service added successfully!");
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEC526A),
                      Color(0xFFF77F6E),
                    ],
                    stops: [0.0075, 0.9527],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  "Add Service",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditServiceDialog(
      BuildContext context, int index, Map<String, dynamic> service) {
    TextEditingController nameController =
    TextEditingController(text: service['name']);
    TextEditingController quantityController =
    TextEditingController(text: service['quantity'].toString());
    TextEditingController priceController =
    TextEditingController(text: service['price'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Text(
            "Edit Service",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Service Name",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Enter service name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  "Quantity",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    hintText: "Enter quantity",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.h),
                Text(
                  "Price",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    hintText: "Enter price",
                    prefixText: "\$",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            InkWell(
              onTap: () {
                int quantity =
                    int.tryParse(quantityController.text.trim()) ?? 1;
                String price = priceController.text.trim();

                if (quantity < 1) {
                  ToastMessageHelper.showToastMessage(
                      "Quantity must be at least 1");
                  return;
                }

                if (price.isEmpty || double.tryParse(price) == null) {
                  ToastMessageHelper.showToastMessage(
                      "Please enter a valid price");
                  return;
                }

                onEditService(index, {
                  'name': nameController.text.trim(),
                  'quantity': quantity.toString(),
                  'price': price,
                });

                Navigator.pop(context);
                ToastMessageHelper.showToastMessage(
                    "Service updated successfully!");
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEC526A),
                      Color(0xFFF77F6E),
                    ],
                    stops: [0.0075, 0.9527],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  "Update Service",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}