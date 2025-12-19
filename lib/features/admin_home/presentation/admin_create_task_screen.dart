import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koji/features/admin_home/presentation/widget/custom_loader.dart';
import 'dart:io';
import '../../../constants/app_color.dart';
import '../../../controller/admincontroller/department_controller.dart';
import '../../../helpers/toast_message_helper.dart';
import '../../../models/admin-model/all_serviceList_model.dart';
import '../../../models/admin-model/vechicle_model.dart';
import '../../../models/admin-model/all_department_model.dart';
import '../../../models/admin-model/all_categories_model.dart';
import '../../../shared_widgets/custom_button.dart';
import '../../../shared_widgets/custom_text.dart';
import 'admin_create_task_screen_widgets/attachment_picker_widget.dart';
import 'admin_create_task_screen_widgets/customer_info_widget.dart';
import 'admin_create_task_screen_widgets/date_time_picker_widget.dart';
import 'admin_create_task_screen_widgets/department_selector_widget.dart';
import 'admin_create_task_screen_widgets/difficulty_selector_widget.dart';
import 'admin_create_task_screen_widgets/priority_selector_widget.dart';
import 'admin_create_task_screen_widgets/assign_to_selector_widget.dart';
import 'admin_create_task_screen_widgets/service_category_selector_widget.dart';
import 'admin_create_task_screen_widgets/service_list_widget.dart';
import 'admin_create_task_screen_widgets/vehicle_selector_widget.dart';

class AdminCreateTaskScreen extends StatefulWidget {
  const AdminCreateTaskScreen({super.key});

  @override
  State<AdminCreateTaskScreen> createState() => _AdminCreateTaskScreenState();
}


class _AdminCreateTaskScreenState extends State<AdminCreateTaskScreen> with WidgetsBindingObserver {

  final DepartmentController departmentController = Get.find();

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerNumberController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Image picker
  final ImagePicker _picker = ImagePicker();
  List<File?> selectedImages = [null, null, null];

  // Selected values
  String? selectedDepartment;
  String? selectedCategory;
  String? selectedVehicle;  // New vehicle selection variable
  List<String> selectedRoles = [];
  String? selectedPriority;
  String? selectedDifficulty;

  // Selected service items list
  List<ServiceItemWithQuantity> selectedServiceList = [];

  @override
  void initState() {
    super.initState();

    // Listen for app lifecycle changes to ensure UI is updated when returning to screen
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      departmentController.getAllDepartment();
      departmentController.getAllCategories();
      departmentController.getAllEmployee();
      departmentController.getAllServiceList();
      departmentController.getAllVehicles();  // Add vehicle API call

      // Initialize local variables from controller (excluding date/time since we use reactive approach now)
      _initializeLocalVariablesFromController();
    });
  }

  void _initializeLocalVariablesFromController() {
    selectedImages = List.from(departmentController.selectedImages);
    selectedDepartment = departmentController.selectedDepartment.value;
    selectedCategory = departmentController.selectedCategory.value;
    selectedVehicle = departmentController.selectedVehicle.value;  // Initialize vehicle from controller
    selectedRoles = List.from(departmentController.selectedRoles);
    selectedPriority = departmentController.selectedPriority.value;
    selectedDifficulty = departmentController.selectedDifficulty.value;
    selectedServiceList = List.from(departmentController.selectedServiceList);
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

              AttachmentPickerWidget(
                selectedImages: selectedImages,
                onImagePicked: (index, file) {
                  setState(() {
                    selectedImages[index] = file;
                  });
                  departmentController.updateImage(index, file);
                },
              ),
              SizedBox(height: 24.h),

              DepartmentSelectorWidget(
                selectedDepartment: selectedDepartment,
                onTap: _showDepartmentBottomSheet,
              ),

              ServiceCategorySelectorWidget(
                selectedCategory: selectedCategory,
                onTap: _showCategoryBottomSheet,
              ),

              VehicleSelectorWidget(
                selectedVehicle: selectedVehicle,
                onTap: _showVehicleBottomSheet),

              ServiceListDropdownWidget(
                selectedServiceList: selectedServiceList,
                availableServices: departmentController.serviceList.value.results ?? [],
                onAddPressed: _showServicePickerBottomSheet,
                onRemovePressed: _removeSelectedService,
                onEditPressed: _editSelectedService,
                onAddServiceToList: _addServiceToList,
              ),




              CustomerInfoWidget(
                customerNameController: _customerNameController,
                customerNumberController: _customerNumberController,
                customerAddressController: _customerAddressController,
                notesController: _notesController,
              ),

              /// ===========================> Assign To =====================================================>

              AssignToSelectorWidget(
                selectedRoles: selectedRoles,
                onTap: _showAssignRoleBottomSheet,
              ),



              ///  ==================================== Assign to date =======================================>

              Obx(() => DateTimePickerWidget(
                label: "Assign Date",
                startHint: departmentController.startDate.value == null
                    ? "Start Date"
                    : _formatDate(departmentController.startDate.value!),
                endHint: departmentController.endDate.value == null
                    ? "End Date"
                    : _formatDate(departmentController.endDate.value!),
                startOnTap: () => _pickDate(true),
                endOnTap: () => _pickDate(false),
                iconPath: "assets/icons/calendar.svg",
              )),

              Obx(() => DateTimePickerWidget(
                label: "Assign Time",
                startHint: departmentController.startTime.value == null
                    ? "Start Time"
                    : _formatTime(departmentController.startTime.value!),
                endHint: departmentController.endTime.value == null
                    ? "End Time"
                    : _formatTime(departmentController.endTime.value!),
                startOnTap: () => _pickTime(true),
                endOnTap: () => _pickTime(false),
                iconPath: "assets/icons/time.svg",
              )),

              PrioritySelectorWidget(
                selectedPriority: selectedPriority,
                onTap: _showPriorityBottomSheet,
              ),

              DifficultySelectorWidget(
                selectedDifficulty: selectedDifficulty,
                onTap: _showDifficultyBottomSheet,
              ),

              SizedBox(height: 16.h),

              Obx(()=>
                 CustomButton(
                  title: departmentController.createNewLoading.value ? 'Creating...' : 'Create Task',
                  onpress: () {
                    _createTask();
                  },
                  loading: departmentController.createNewLoading.value,
                ),),

              SizedBox(height: 40.h),
            ],
          ),
        ),
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
                                        "\$$servicePrice",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _showUpdateServiceDialog(service, setModalState);
                                      },
                                      icon: Icon(Icons.edit, size: 18.r, color: Colors.grey),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _showServiceFormDialog(service, setModalState);
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

  void _showServiceFormDialog(ServiceItem service, StateSetter setModalState) {
    TextEditingController nameController = TextEditingController(text: service.name);
    TextEditingController quantityController = TextEditingController(text: "1");
    TextEditingController priceController = TextEditingController(text: service.price);

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
                      onChanged: (value) {
                        setDialogState(() {});
                      },
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
                      onChanged: (value) {
                        setDialogState(() {});
                      },
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
                    int quantity = int.tryParse(quantityController.text.trim()) ?? 1;
                    String price = priceController.text.trim();

                    if (quantity < 1) {
                      ToastMessageHelper.showToastMessage("Quantity must be at least 1");
                      return;
                    }

                    if (price.isEmpty || double.tryParse(price) == null) {
                      ToastMessageHelper.showToastMessage("Please enter a valid price");
                      return;
                    }

                    setState(() {
                      selectedServiceList.add(ServiceItemWithQuantity(
                        serviceItem: ServiceItem(
                          id: service.id,
                          name: nameController.text.trim(),
                          price: price,
                        ),
                        quantity: quantity,
                      ));
                    });
                    departmentController.addServiceItemWithQuantity(ServiceItemWithQuantity(
                      serviceItem: ServiceItem(
                        id: service.id,
                        name: nameController.text.trim(),
                        price: price,
                      ),
                      quantity: quantity,
                    ));
                    Navigator.pop(context);
                    Navigator.pop(context);
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

  void _showUpdateServiceDialog(ServiceItem service, StateSetter setModalState) {
    // Create controllers with the current values
    TextEditingController nameController = TextEditingController(text: service.name);
    TextEditingController quantityController = TextEditingController(text: "1");  // Default quantity
    TextEditingController priceController = TextEditingController(text: service.price);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Service"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            Obx(() => ElevatedButton(
                  onPressed: departmentController.updateServiceLoading.value
                      ? null
                      : () async {
                          final success = await departmentController.updateService(
                            serviceId: service.id ?? '',
                            name: nameController.text.trim(),
                            quantity: int.tryParse(quantityController.text.trim()) ?? 1,
                            price: priceController.text.trim(),
                          );
                          if (success) {
                            Navigator.pop(context);
                            // Refresh the service list in the bottom sheet
                            setModalState(() {});
                          }
                        },
                  child: departmentController.updateServiceLoading.value
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text("Update"),
                )),
            Obx(() => ElevatedButton(
                  onPressed: departmentController.deleteServiceLoading.value
                      ? null
                      : () async {
                          _showDeleteConfirmationDialog(service, setModalState);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: departmentController.deleteServiceLoading.value
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text("Delete"),
                )),
          ],
        );
      },
    );
  }

  void _removeSelectedService(int index) {
    setState(() {
      selectedServiceList.removeAt(index);
    });
    departmentController.removeServiceItemAt(index);
  }

  void _editSelectedService(int index) {
    final serviceItemWithQuantity = selectedServiceList[index];

    // Create controllers with the current values
    TextEditingController nameController = TextEditingController(text: serviceItemWithQuantity.serviceItem.name);
    TextEditingController quantityController = TextEditingController(text: serviceItemWithQuantity.quantity.toString());
    TextEditingController priceController = TextEditingController(text: serviceItemWithQuantity.serviceItem.price);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Service"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Update the service item with new values
                  selectedServiceList[index] = ServiceItemWithQuantity(
                    serviceItem: ServiceItem(
                      id: serviceItemWithQuantity.serviceItem.id,
                      name: nameController.text.trim(),
                      quantity: int.tryParse(quantityController.text.trim()),
                      price: priceController.text.trim(),
                      createdBy: serviceItemWithQuantity.serviceItem.createdBy,
                      createdAt: serviceItemWithQuantity.serviceItem.createdAt,
                    ),
                    quantity: int.tryParse(quantityController.text.trim()) ?? serviceItemWithQuantity.quantity,
                  );
                });

                // Update the controller's selected service list
                departmentController.updateSelectedServiceList(selectedServiceList);

                Navigator.pop(context);
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _addServiceToList(ServiceItemWithQuantity serviceItemWithQuantity) {
    setState(() {
      selectedServiceList.add(serviceItemWithQuantity);
    });

    // Update the controller's selected service list
    departmentController.updateSelectedServiceList(selectedServiceList);
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
              child: Center(child: CustomLoader()),
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
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _showUpdateDepartmentDialog(dept);
                                },
                                icon: Icon(Icons.edit, size: 18.r, color: Colors.grey),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
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
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _showUpdateCategoryDialog(cat);
                                },
                                icon: Icon(Icons.edit, size: 18.r, color: Colors.grey),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
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






  void _showVehicleBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Obx(() {
          if (departmentController.getAllVehiclesModelLoading.value) {
            return Container(
              height: 300.h,
              child: Center(child: CustomLoader()),
            );
          }

          final vehicles = departmentController.allVehicles.value.attributes?.results ?? [];

          if (vehicles.isEmpty) {
            return Container(
              height: 300.h,
              child: Center(child: Text("No vehicles found")),
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
                      "Vehicle",
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
                ...vehicles.map((vehicle) {
                  bool isSelected = selectedVehicle == vehicle.name;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedVehicle = vehicle.name;
                      });
                      departmentController.updateSelectedVehicle(vehicle.name ?? '');
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
                                vehicle.name ?? "",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              if (vehicle.description != null)
                                Text(
                                  vehicle.description!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isSelected ? Colors.white70 : Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _showUpdateVehicleDialog(vehicle);
                                },
                                icon: Icon(Icons.edit, size: 18.r, color: Colors.grey),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
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
                String displayText = priorityDisplayMap[priority] ?? priority;
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
                          displayText,
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
                String displayText = difficultyDisplayMap[difficulty] ?? difficulty;
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
                          displayText,
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xffEC526A), // Using the app's primary color from the design
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        departmentController.updateStartDate(picked);
      } else {
        departmentController.updateEndDate(picked);
      }
      // Force UI update
      setState(() {});
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xffEC526A), // Using the app's primary color from the design
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        departmentController.updateStartTime(picked);
      } else {
        departmentController.updateEndTime(picked);
      }
      // Force UI update
      setState(() {});
    }
  }

  // Backend value to display value mapping
  final Map<String, String> priorityDisplayMap = {
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High',
    'urgent': 'Urgent',
  };

  final Map<String, String> difficultyDisplayMap = {
    'very easy': 'Very Easy',
    'easy': 'Easy',
    'moderate': 'Moderate',
    'hard': 'Hard',
    'very hard': 'Very Hard',
  };

  // Backend values for API
  List<String> get priorities => priorityDisplayMap.keys.toList();
  List<String> get difficulties => difficultyDisplayMap.keys.toList();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh UI when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }


  double _calculateTotalAmount() {
    double total = 0.0;
    for (var serviceWithQty in selectedServiceList) {
      double price = double.tryParse(serviceWithQty.serviceItem.price ?? '0') ?? 0.0;
      int quantity = serviceWithQty.quantity;
      total += price * quantity;
    }
    return total;
  }

  String _formatDateToISO(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return '';

    // Create a DateTime object with the date and time
    DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return dateTime.toIso8601String();
  }

  Future<void> _createTask() async {
    // Use controller's validation method
    String? validationError = departmentController.validateTaskForm(
      customerName: _customerNameController.text.trim(),
      customerNumber: _customerNumberController.text.trim(),
      customerAddress: _customerAddressController.text.trim(),
      notes: _notesController.text.trim(),
    );

    if (validationError != null) {
      _showToast(validationError);
      return;
    }

    // Use controller values to format dates to ISO strings
    String assignDate = _formatDateToISO(departmentController.startDate.value, departmentController.startTime.value);
    String deadlineDate = _formatDateToISO(departmentController.endDate.value, departmentController.endTime.value);

    // Prepare services list as array of objects
    List<Map<String, dynamic>> services = selectedServiceList
        .map((item) => {
      'name': item.serviceItem.name,
      'price': double.tryParse(item.serviceItem.price ?? '0') ?? 0.0,
      'quantity': item.quantity,
    })
        .toList();

    // Calculate amounts using local values
    double totalAmount = _calculateTotalAmount();
    double otherAmount = 0.0; // This might be for additional costs not included in services

    // Get the first selected attachment (or null if none selected)
    File? attachmentFile = selectedImages
        .firstWhere((image) => image != null, orElse: () => null);

    // Join all selected roles for assignTo (if multiple employees can be assigned)
    String assignTo = selectedRoles.join(','); // Join with comma if multiple roles, or use first if single assignment needed

    // Call the createNewTask method from DepartmentController
    String? result = await departmentController.createNewTask(
      department: selectedDepartment!,
      serviceCategory: selectedCategory!,
      vehicle: selectedVehicle!,  // Pass the selected vehicle
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
      // Task created successfully, reset form using controller's method
      departmentController.resetTaskForm();

      // Clear text controllers separately
      _customerNameController.clear();
      _customerNumberController.clear();
      _customerAddressController.clear();
      _notesController.clear();

      // Reinitialize local variables from controller
      _initializeLocalVariablesFromController();

      // Show success message
      _showToast('Task created successfully!');
    }
  }

  void _showUpdateVehicleDialog(VehicleResult vehicle) {
    // Create controllers with the current values
    TextEditingController nameController = TextEditingController(text: vehicle.name);
    TextEditingController descriptionController = TextEditingController(text: vehicle.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Vehicle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            Obx(() => ElevatedButton(
                  onPressed: departmentController.updateVehicleLoading.value
                      ? null
                      : () async {
                          final success = await departmentController.updateVehicle(
                            vehicleId: vehicle.id ?? '',
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                          );
                          if (success) {
                            Navigator.pop(context);
                          }
                        },
                  child: departmentController.updateVehicleLoading.value
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text("Update"),
                )),
          ],
        );
      },
    );
  }

  void _showUpdateDepartmentDialog(Department dept) {
    // Create controllers with the current values
    TextEditingController nameController = TextEditingController(text: dept.name);
    TextEditingController descriptionController = TextEditingController(text: dept.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Department"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            Obx(() => ElevatedButton(
                  onPressed: departmentController.updateDepartmentLoading.value
                      ? null
                      : () async {
                          final success = await departmentController.updateDepartment(
                            departmentId: dept.id ?? '',
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                          );
                          if (success) {
                            Navigator.pop(context);
                          }
                        },
                  child: departmentController.updateDepartmentLoading.value
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text("Update"),
                )),
          ],
        );
      },
    );
  }

  void _showUpdateCategoryDialog(Category cat) {
    // Create controllers with the current values
    TextEditingController nameController = TextEditingController(text: cat.name);
    TextEditingController descriptionController = TextEditingController(text: cat.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Service Category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            Obx(() => ElevatedButton(
                  onPressed: departmentController.updateCategoryLoading.value
                      ? null
                      : () async {
                          final success = await departmentController.updateCategory(
                            categoryId: cat.id ?? '',
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                          );
                          if (success) {
                            Navigator.pop(context);
                          }
                        },
                  child: departmentController.updateCategoryLoading.value
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text("Update"),
                )),
          ],
        );
      },
    );
  }

  void _showToast(String message) {
    ToastMessageHelper.showToastMessage(message);
  }

  // Format date as "5 Nov 2024" or "05/11/2024"
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    // Option 1: "5 Nov 2024" format
    return "${date.day} ${months[date.month - 1]} ${date.year}";

    // Option 2: "05/11/2024" format (uncomment if preferred)
    // return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

// Format time as "09:30 AM" or "09:30"
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    // Option 1: 24-hour format "09:30"
    return "$hour:$minute";

    // Option 2: 12-hour format with AM/PM (uncomment if preferred)
    // final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    // final hour12 = time.hourOfPeriod.toString().padLeft(2, '0');
    // return "$hour12:$minute $period";
  }

  void _showDeleteConfirmationDialog(ServiceItem service, StateSetter setModalState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete the service '${service.name}'? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            Obx(() => ElevatedButton(
                  onPressed: departmentController.deleteServiceLoading.value
                      ? null
                      : () async {
                          final success = await departmentController.deleteService(
                            serviceId: service.id ?? '',
                          );
                          if (success) {
                            Navigator.pop(context); // Close confirmation dialog
                            Navigator.pop(context); // Close update dialog if it was open
                            // Refresh the service list in the bottom sheet
                            setModalState(() {});
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: departmentController.deleteServiceLoading.value
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text("Delete"),
                )),
          ],
        );
      },
    );
  }

}