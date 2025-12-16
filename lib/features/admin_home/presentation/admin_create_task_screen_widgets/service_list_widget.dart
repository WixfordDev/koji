import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/app_color.dart';
import '../../../../controller/admincontroller/department_controller.dart';
import '../../../../models/admin-model/all_serviceList_model.dart';
import '../../../../shared_widgets/custom_text.dart';

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

  @override
  void didUpdateWidget(ServiceListDropdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset expansion state if the service list becomes empty
    if (oldWidget.selectedServiceList.isNotEmpty && widget.selectedServiceList.isEmpty) {
      _isExpanded = false;
    }
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

        // Dropdown + Add Icon Row
        Row(
          children: [
            // Expandable Dropdown
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Toggle the expanded state to show all available services
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
                      CustomText(
                        text: _isExpanded
                            ? "Select services"
                            : (widget.selectedServiceList.isEmpty
                                ? "Select services"
                                : "${widget.selectedServiceList.length} service(s) selected"),
                        color: _isExpanded
                            ? AppColor.primaryColor
                            : (widget.selectedServiceList.isEmpty
                                ? Colors.grey.shade500
                                : AppColor.secondaryColor),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                        size: 20.r,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Add Icon Button - now optional since we have dropdown selection
            GestureDetector(
              onTap: widget.onAddPressed,
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
        SizedBox(height: 12.h),

        // Available Services List (only shown when expanded)
        if (_isExpanded)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(12.w),
              itemCount: widget.availableServices.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final service = widget.availableServices[index];
                // Check if this service is already in the selected list
                bool isSelected = widget.selectedServiceList.any((item) => item.serviceItem.id == service.id);

                return Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: isSelected ? AppColor.primaryColor : Colors.grey.shade300,
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
                              text: "\$${service.price}",
                              color: AppColor.primaryColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppColor.primaryColor,
                              size: 18.r,
                            )
                          else
                            IconButton(
                              onPressed: () {
                                // Add the service to the selected list
                                widget.onAddServiceToList(ServiceItemWithQuantity(
                                  serviceItem: service,
                                  quantity: 1,
                                ));
                              },
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: Colors.grey.shade500,
                                size: 18.r,
                              ),
                            ),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: () {
                              // Call a callback function to edit the service
                              // This would require finding the index in the selected list
                              int? selectedIndex = widget.selectedServiceList.indexWhere(
                                (item) => item.serviceItem.id == service.id
                              );
                              if (selectedIndex != -1) {
                                widget.onEditPressed?.call(selectedIndex);
                              }
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.blue,
                              size: 18.r,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
