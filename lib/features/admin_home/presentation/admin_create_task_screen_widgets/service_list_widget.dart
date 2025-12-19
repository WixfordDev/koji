import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/app_color.dart';
import '../../../../controller/admincontroller/department_controller.dart';
import '../../../../models/admin-model/all_serviceList_model.dart';
import '../../../../shared_widgets/custom_text.dart';
import '../../../../helpers/toast_message_helper.dart';

class ServiceListDropdownWidget extends StatefulWidget {
  final List<ServiceItemWithQuantity> selectedServiceList;
  final List<ServiceItem> availableServices;
  final VoidCallback onAddPressed;
  final Function(int) onRemovePressed;
  final Function(int)? onEditPressed;
  final Function(ServiceItemWithQuantity) onAddServiceToList;

  const ServiceListDropdownWidget({
    super.key,
    required this.selectedServiceList,
    required this.availableServices,
    required this.onAddPressed,
    required this.onRemovePressed,
    this.onEditPressed,
    required this.onAddServiceToList,
  });

  @override
  State<ServiceListDropdownWidget> createState() => _ServiceListDropdownWidgetState();
}

class _ServiceListDropdownWidgetState extends State<ServiceListDropdownWidget> {
  bool _isExpanded = false;

  // Show dialog to add custom service directly
  void _showAddCustomServiceDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController(text: "1");
    TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              title: Text(
                "Add Custom Service",
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
                        prefixText: "₦",
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
                ElevatedButton(
                  onPressed: () {
                    String name = nameController.text.trim();
                    int quantity = int.tryParse(quantityController.text.trim()) ?? 1;
                    String price = priceController.text.trim();

                    if (name.isEmpty) {
                      ToastMessageHelper.showToastMessage("Please enter service name");
                      return;
                    }

                    if (quantity < 1) {
                      ToastMessageHelper.showToastMessage("Quantity must be at least 1");
                      return;
                    }

                    if (price.isEmpty || double.tryParse(price) == null) {
                      ToastMessageHelper.showToastMessage("Please enter a valid price");
                      return;
                    }

                    // Add the custom service
                    widget.onAddServiceToList(
                      ServiceItemWithQuantity(
                        serviceItem: ServiceItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          price: price,
                        ),
                        quantity: quantity,
                      ),
                    );

                    Navigator.pop(context);

                    // Expand dropdown to show the added service
                    setState(() {
                      _isExpanded = true;
                    });

                    ToastMessageHelper.showToastMessage("Service added successfully!");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  ),
                  child: Text(
                    "Add Service",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        CustomText(
          text: "Service List",
          color: AppColor.secondaryColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 8.h),

        // Dropdown Field + Add Button Row
        Row(
          children: [
            // Dropdown field - click to show/select services
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: _isExpanded ? AppColor.primaryColor : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: CustomText(
                          text: widget.selectedServiceList.isEmpty
                              ? "Select services"
                              : "${widget.selectedServiceList.length} service(s) selected",
                          color: widget.selectedServiceList.isEmpty
                              ? Colors.grey.shade500
                              : AppColor.secondaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                        size: 20.r,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Add button - opens dialog to add custom service directly
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = false; // Close dropdown first
                });
                _showAddCustomServiceDialog();
              },
              child: Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20.r,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),

        // Selected services list - shown only when dropdown is closed
        if (!_isExpanded && widget.selectedServiceList.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              itemCount: widget.selectedServiceList.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final item = widget.selectedServiceList[index];
                final service = item.serviceItem;
                final total = (double.tryParse(service.price ?? '0') ?? 0) * item.quantity;

                return Container(
                  padding: EdgeInsets.all(8.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: service.name ?? "",
                              color: AppColor.secondaryColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            SizedBox(height: 2.h),
                            CustomText(
                              text: "Qty: ${item.quantity} x ₦${service.price} = ₦$total",
                              color: Colors.grey.shade600,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.onEditPressed?.call(index);
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 14.r,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      GestureDetector(
                        onTap: () {
                          widget.onRemovePressed(index);
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14.r,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        SizedBox(height: 12.h),

        // Expanded dropdown - shows available services to select from
        if (_isExpanded)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                // Search field inside dropdown
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search service...",
                      prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.r),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),

                // Available services list
                widget.availableServices.isEmpty
                    ? Padding(
                  padding: EdgeInsets.all(20.w),
                  child: CustomText(
                    text: "No services available",
                    color: Colors.grey.shade600,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),
                )
                    : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  itemCount: widget.availableServices.length,
                  separatorBuilder: (context, index) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final service = widget.availableServices[index];
                    final existingServiceIndex = widget.selectedServiceList
                        .indexWhere((item) => item.serviceItem.id == service.id);
                    final isAdded = existingServiceIndex != -1;
                    final addedService = isAdded ? widget.selectedServiceList[existingServiceIndex] : null;

                    return Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isAdded
                            ? AppColor.primaryColor.withOpacity(0.1)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: isAdded
                              ? AppColor.primaryColor
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: service.name ?? "",
                                  color: AppColor.secondaryColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                SizedBox(height: 4.h),
                                CustomText(
                                  text: "₦${service.price}",
                                  color: Colors.grey.shade600,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                if (isAdded) ...[
                                  SizedBox(height: 4.h),
                                  CustomText(
                                    text: "Qty: ${addedService!.quantity} | Total: ₦${(double.tryParse(addedService.serviceItem.price ?? '0') ?? 0) * addedService.quantity}",
                                    color: AppColor.primaryColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isAdded) ...[
                                GestureDetector(
                                  onTap: () {
                                    widget.onEditPressed?.call(existingServiceIndex);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4.r),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16.r,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: () {
                                    widget.onRemovePressed(existingServiceIndex);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4.r),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16.r,
                                    ),
                                  ),
                                ),
                              ] else
                                GestureDetector(
                                  onTap: () {
                                    widget.onAddServiceToList(
                                      ServiceItemWithQuantity(
                                        serviceItem: service,
                                        quantity: 1,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4.r),
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryColor,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 16.r,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        SizedBox(height: 16.h),
      ],
    );
  }
}