import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart' show Get;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../constants/app_color.dart';
import '../../../controller/admincontroller/department_controller.dart';
import '../../../helpers/toast_message_helper.dart';
import '../../../models/admin-model/all_serviceList_model.dart';
import '../../../shared_widgets/custom_button.dart';
import '../../../shared_widgets/custom_text.dart';

// Selected service item with quantity
class ServiceItemWithQuantity {
  ServiceItem serviceItem;
  int quantity;

  ServiceItemWithQuantity({
    required this.serviceItem,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'name': serviceItem.name,
    'price': serviceItem.price,
    'quantity': quantity,
  };
}

class AdminCreateTaskScreen extends StatefulWidget {
  const AdminCreateTaskScreen({super.key});

  @override
  State<AdminCreateTaskScreen> createState() => _AdminCreateTaskScreenState();
}

class _AdminCreateTaskScreenState extends State<AdminCreateTaskScreen> {

  final DepartmentController departmentController = Get.put(DepartmentController());

  // Text controllers for form fields
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerNumberController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      departmentController.getAllDepartment();
      departmentController.getAllCategories();
      departmentController.getAllEmployee();
      departmentController.getAllServiceList();

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.r),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 12.w),
            CustomText(
              text: "Create Task",
              color: AppColor.secondaryColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              Text(
                "Attachment",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Format should be in .mp4 .pdf .jpeg .png less than 5MB",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
              SizedBox(height: 12.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  3,
                      (index) => GestureDetector(
                    onTap: () => _pickImage(index),
                    child: Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                        color: Color(0xFFF5F5FF),
                      ),
                      child: selectedImages[index] == null
                          ? Center(
                        child: Icon(
                          Icons.upload_rounded,
                          size: 28.sp,
                          color: Colors.grey.shade400,
                        ),
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          selectedImages[index]!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              _buildSelectionField(
                label: "Department",
                hint: selectedDepartment ?? "Select Department",
                onTap: () => _showDepartmentBottomSheet(),
              ),

              _buildSelectionField(
                label: "Service Category",
                hint: selectedCategory ?? "Select Category",
                onTap: () => _showCategoryBottomSheet(),
              ),

              _buildServiceList(),




              _buildTextField(
                label: "Customer Name",
                hint: "Enter Customer Name",
                controller: _customerNameController,
              ),
              _buildTextField(
                label: "Customer Number",
                hint: "Enter Customer Number",
                controller: _customerNumberController,
              ),
              _buildTextField(
                label: "Customer Address",
                hint: "Enter Customer Address",
                controller: _customerAddressController,
                maxLines: 3,
              ),

              _buildTextField(
                label: "Notes",
                hint: "Enter any additional notes",
                controller: _notesController,
                maxLines: 3,
              ),

              /// ===========================> Assign To =====================================================>

            _buildSelectionField(
                label: "Assign To",
                hint: selectedRoles.isEmpty
                    ? "Employee ID (Multiple)"
                    : selectedRoles.length == 1
                    ? selectedRoles[0]
                    : "${selectedRoles[0]} +${selectedRoles.length - 1}",
                onTap: () => _showAssignRoleBottomSheet(),
              ),



              ///  ==================================== Assign to date =======================================>

              _buildDateTimeRow(
                label: "Assign Date",
                startHint: startDate == null
                    ? "Start Date"
                    : "${startDate!.day}/${startDate!.month}/${startDate!.year}",
                endHint: endDate == null
                    ? "End Date"
                    : "${endDate!.day}/${endDate!.month}/${endDate!.year}",
                startOnTap: () => _pickDate(true),
                endOnTap: () => _pickDate(false),
                iconPath: "assets/icons/calendar.svg",
              ),

              _buildDateTimeRow(
                label: "Assign Time",
                startHint: startTime == null ? "Start Time" : startTime!.format(context),
                endHint: endTime == null ? "End Time" : endTime!.format(context),
                startOnTap: () => _pickTime(true),
                endOnTap: () => _pickTime(false),
                iconPath: "assets/icons/time.svg",
              ),

              _buildSelectionField(
                label: "Priority",
                hint: selectedPriority ?? "Select Priority",
                onTap: () => _showPriorityBottomSheet(),
              ),

              _buildSelectionField(
                label: "Difficulty",
                hint: selectedDifficulty ?? "Select Difficulty",
                onTap: () => _showDifficultyBottomSheet(),
              ),

              SizedBox(height: 16.h),

              Obx(()=>
                 CustomButton(
                  title: departmentController.createNewLoading.value ? 'Creating...' : 'Create Task',
                  onpress: () {
                    _createTask();
                  },
                  loading: departmentController.createNewLoading.value,
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Helper Widgets ----------------

  Widget _buildTextField({
    required String label,
    required String hint,
    TextEditingController? controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 6.h),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColor.primaryColor),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList() {
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
                onPressed: () => _showServicePickerBottomSheet(),
                icon: Icon(Icons.add, size: 20.r, color: AppColor.primaryColor),
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
            child: selectedServiceList.isEmpty
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
                    itemCount: selectedServiceList.length,
                    itemBuilder: (context, index) {
                      final serviceItemWithQuantity = selectedServiceList[index];
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
                            bottom: Radius.circular(index == selectedServiceList.length - 1 ? 8.r : 0),
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
                              onPressed: () => _removeSelectedService(index),
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


  Widget _buildSelectionField({
    required String label,
    required String hint,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 6.h),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hint,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14.sp,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Color(0xFFAC87C5), size: 20.r),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeRow({
    required String label,
    required String startHint,
    required String endHint,
    required VoidCallback startOnTap,
    required VoidCallback endOnTap,
    required String iconPath,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: startOnTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          iconPath,
                          width: 16.w,
                          height: 16.h,
                          colorFilter: ColorFilter.mode(
                            Colors.grey.shade600,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          startHint,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: endOnTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          iconPath,
                          width: 16.w,
                          height: 16.h,
                          colorFilter: ColorFilter.mode(
                            Colors.grey.shade600,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          endHint,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- Service Management ----------------

  void _showServicePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Obx(() {
              if (departmentController.getServiceLoading.value) {
                return Container(
                  height: 400.h,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final services = departmentController.serviceList.value.results ?? [];

              if (services.isEmpty) {
                return Container(
                  height: 400.h,
                  child: Center(child: Text("No services available")),
                );
              }

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
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
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
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          final serviceName = service.name ?? '';
                          final servicePrice = service.price ?? '0';

                          return Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        serviceName,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "₦$servicePrice",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _showQuantitySelector(service, setModalState);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                  ),
                                  child: Text(
                                    "Add",
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              );
            });
          },
        );
      },
    );
  }

  void _showQuantitySelector(ServiceItem service, StateSetter setModalState) {
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Quantity"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Service: ${service.name}"),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (quantity > 1) {
                        setModalState(() {
                          quantity--;
                        });
                      }
                    },
                    icon: Icon(Icons.remove),
                  ),
                  Container(
                    width: 50.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        quantity.toString(),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setModalState(() {
                        quantity++;
                      });
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedServiceList.add(ServiceItemWithQuantity(
                    serviceItem: service,
                    quantity: quantity,
                  ));
                });
                Navigator.pop(context);
                Navigator.pop(context); // Close the bottom sheet as well
              },
              child: Text("Add Service"),
            ),
          ],
        );
      },
    );
  }

  void _removeSelectedService(int index) {
    setState(() {
      selectedServiceList.removeAt(index);
    });
  }

  // ---------------- Bottom Sheets ----------------

  void _showDepartmentBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Obx(() {
          if (departmentController.getAllDepartmentModelLoading.value) {
            return Container(
              height: 300.h,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final departments = departmentController.allDepartment.value.results ?? [];

          if (departments.isEmpty) {
            return Container(
              height: 300.h,
              child: Center(child: Text("No departments found")),
            );
          }

          return Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Department",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.edit_outlined, size: 20.r),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search here...",
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
                SizedBox(height: 16.h),
                ...departments.map((dept) {
                  bool isSelected = selectedDepartment == dept.name;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDepartment = dept.name;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFFFF7D7D) : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dept.name ?? "",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              if (dept.description != null)
                                Text(
                                  dept.description!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isSelected ? Colors.white70 : Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check, color: Color(0xFFFF7D7D), size: 16.r),
                            )
                          else
                            Container(
                              width: 20.r,
                              height: 20.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300, width: 2),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: 20.h),
              ],
            ),
          );
        });
      },
    );
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Obx(() {
          if (departmentController.getCategoriesLoading.value) {
            return Container(
              height: 300.h,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final categories = departmentController.categories.value.results ?? [];

          if (categories.isEmpty) {
            return Container(
              height: 300.h,
              child: Center(child: Text("No categories found")),
            );
          }

          return Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Service Category",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.edit_outlined, size: 20.r),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search here...",
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
                SizedBox(height: 16.h),
                ...categories.map((cat) {
                  bool isSelected = selectedCategory == cat.name;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat.name;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFFFF7D7D) : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.name ?? "",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              if (cat.description != null)
                                Text(
                                  cat.description!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isSelected ? Colors.white70 : Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check, color: Color(0xFFFF7D7D), size: 16.r),
                            )
                          else
                            Container(
                              width: 20.r,
                              height: 20.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300, width: 2),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: 20.h),
              ],
            ),
          );
        });
      },
    );
  }








  void _showAssignRoleBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Obx(() {
              if (departmentController.getEmployeeLoading.value) {
                return Container(
                  height: 300.h,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final employees = departmentController.employee.value.results ?? [];

              if (employees.isEmpty) {
                return Container(
                  height: 300.h,
                  child: Center(child: Text("No employees found")),
                );
              }

              return Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Assign To",
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.edit_outlined, size: 20.r),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search here...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          final employee = employees[index];
                          final employeeId = employee.id ?? '';
                          final employeeName = employee.fullName ?? '';
                          final isSelected = selectedRoles.contains(employeeId);

                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  selectedRoles.remove(employeeId);
                                } else {
                                  selectedRoles.add(employeeId);
                                }
                              });
                              setState(() {});
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                color: isSelected ? Color(0xFFFF7D7D) : Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: isSelected ? Color(0xFFFF7D7D) : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        employeeName,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                          color: isSelected ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        employeeId,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: isSelected ? Colors.white70 : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isSelected)
                                    Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.check, color: Color(0xFFFF7D7D), size: 16.r),
                                    )
                                  else
                                    Container(
                                      width: 20.r,
                                      height: 20.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey.shade300, width: 2),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              );
            });
          },
        );
      },
    );
  }






  void _showPriorityBottomSheet() {
    showModalBottomSheet(
      context: context,
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
              Text(
                "Select Priority",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16.h),
              ...priorities.map((priority) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPriority = priority;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: selectedPriority == priority ? Color(0xFFFF7D7D) : Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          priority,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: selectedPriority == priority ? Colors.white : Colors.black,
                          ),
                        ),
                        if (selectedPriority == priority)
                          Icon(Icons.check_circle, color: Colors.white, size: 20.r),
                      ],
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  void _showDifficultyBottomSheet() {
    showModalBottomSheet(
      context: context,
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
              Text(
                "Select Difficulty",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16.h),
              ...difficulties.map((difficulty) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDifficulty = difficulty;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: selectedDifficulty == difficulty ? Color(0xFFFF7D7D) : Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          difficulty,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: selectedDifficulty == difficulty ? Colors.white : Colors.black,
                          ),
                        ),
                        if (selectedDifficulty == difficulty)
                          Icon(Icons.check_circle, color: Colors.white, size: 20.r),
                      ],
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  // ---------------- Date & Time Pickers ----------------

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }


  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  // Image picker
  final ImagePicker _picker = ImagePicker();
  List<File?> selectedImages = [null, null, null];

  // Selected values
  String? selectedDepartment;
  String? selectedCategory;
  List<String> selectedRoles = [];
  String? selectedPriority;
  String? selectedDifficulty;

  // Selected service items list
  List<ServiceItemWithQuantity> selectedServiceList = [];

  // Sample data

  final List<String> priorities = ['Low', 'Medium', 'Important', 'Urgent'];
  final List<String> difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImages[index] = File(image.path);
      });
    }
  }

  // Calculate total amount based on selected services
  double _calculateTotalAmount() {
    double total = 0.0;
    for (var serviceWithQty in selectedServiceList) {
      double price = double.tryParse(serviceWithQty.serviceItem.price ?? '0') ?? 0.0;
      int quantity = serviceWithQty.quantity;
      total += price * quantity;
    }
    return total;
  }

  // Format date to ISO string
  String _formatDateToISO(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return '';

    // Create a DateTime object with the date and time
    DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return dateTime.toIso8601String();
  }

  // Create task function
  Future<void> _createTask() async {
    // Validate required fields
    if (selectedDepartment == null || selectedDepartment!.isEmpty) {
      _showToast('Please select a department');
      return;
    }

    if (selectedCategory == null || selectedCategory!.isEmpty) {
      _showToast('Please select a service category');
      return;
    }

    if (_customerNameController.text.trim().isEmpty) {
      _showToast('Please enter customer name');
      return;
    }

    if (_customerNumberController.text.trim().isEmpty) {
      _showToast('Please enter customer number');
      return;
    }

    if (_customerAddressController.text.trim().isEmpty) {
      _showToast('Please enter customer address');
      return;
    }

    if (selectedRoles.isEmpty) {
      _showToast('Please select at least one employee to assign to');
      return;
    }

    if (startDate == null || startTime == null) {
      _showToast('Please select assign date and time');
      return;
    }

    if (endDate == null || endTime == null) {
      _showToast('Please select deadline date and time');
      return;
    }

    if (selectedPriority == null || selectedPriority!.isEmpty) {
      _showToast('Please select a priority');
      return;
    }

    if (selectedDifficulty == null || selectedDifficulty!.isEmpty) {
      _showToast('Please select a difficulty level');
      return;
    }

    if (selectedServiceList.isEmpty) {
      _showToast('Please select at least one service');
      return;
    }

    // Format dates to ISO strings
    String assignDate = _formatDateToISO(startDate, startTime);
    String deadlineDate = _formatDateToISO(endDate, endTime);

    // Prepare services list
    List<String> services = selectedServiceList
        .map((item) => '${item.serviceItem.name} (Qty: ${item.quantity})')
        .toList();

    // Calculate amounts
    double totalAmount = _calculateTotalAmount();
    double otherAmount = 0.0; // This might be for additional costs not included in services

    // Get the first selected attachment (or null if none selected)
    File? attachmentFile = selectedImages.firstWhere((image) => image != null, orElse: () => null);

    // Join all selected roles for assignTo (if multiple employees can be assigned)
    String assignTo = selectedRoles.join(','); // Join with comma if multiple roles, or use first if single assignment needed

    // Call the createNewTask method from DepartmentController
    String? result = await departmentController.createNewTask(
      department: selectedDepartment!,
      serviceCategory: selectedCategory!,
      customerName: _customerNameController.text.trim(),
      customerNumber: _customerNumberController.text.trim(),
      customerAddress: _customerAddressController.text.trim(),
      assignDate: assignDate,
      deadline: deadlineDate,
      services: services,
      otherAmount: otherAmount,
      totalAmount: totalAmount,
      attachmentFile: attachmentFile,
      assignTo: assignTo,
      notes: _notesController.text.trim(),
      priority: selectedPriority!.toLowerCase(), // Convert to lowercase to match expected format
      difficulty: selectedDifficulty!.toLowerCase(), // Convert to lowercase to match expected format
    );

    if (result != null) {
      // Task created successfully
      // Reset form fields
      _customerNameController.clear();
      _customerNumberController.clear();
      _customerAddressController.clear();
      _notesController.clear();

      // Reset selections
      selectedDepartment = null;
      selectedCategory = null;
      selectedRoles.clear();
      selectedPriority = null;
      selectedDifficulty = null;
      selectedServiceList.clear();
      selectedImages = [null, null, null];

      // Reset dates and times
      startDate = null;
      endDate = null;
      startTime = null;
      endTime = null;

      // Show success message and potentially navigate back
      _showToast('Task created successfully!');
    }
  }

  void _showToast(String message) {
    ToastMessageHelper.showToastMessage(message);
  }

}