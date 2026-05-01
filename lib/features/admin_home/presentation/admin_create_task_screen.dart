import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koji/features/admin_home/presentation/widget/custom_loader.dart';
import 'dart:io';
import '../../../constants/app_color.dart';
import '../../../controller/admincontroller/admin_home_controller.dart';
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
import 'admin_create_task_screen_widgets/department_selector_widget.dart';
// import 'admin_create_task_screen_widgets/difficulty_selector_widget.dart';
// import 'admin_create_task_screen_widgets/priority_selector_widget.dart';
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
  final TextEditingController _postCodeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Image picker
  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];


  String? selectedDepartment;
  String? selectedCategory;
  String? selectedVehicle;
  List<String> selectedRoles = [];      // stores IDs (for API)
  List<String> selectedRoleNames = [];  // stores names (for display)
  String? selectedPriority;
  String? selectedDifficulty;


  List<ServiceItemWithQuantity> selectedServiceList = [];

  // Inline field errors — key matches validation field keys
  final Map<String, String?> _errors = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();


    WidgetsBinding.instance.addObserver(this);
    _customerNameController.addListener(_onNameChanged);
    _customerNumberController.addListener(_onNumberChanged);
    _customerAddressController.addListener(_onAddressChanged);

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

  void _onNameChanged() => _clearError('customerName');
  void _onNumberChanged() { _clearError('customerNumber'); _clearError('customerNumberLength'); }
  void _onAddressChanged() => _clearError('customerAddress');

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
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              AttachmentPickerWidget(
                selectedImages: selectedImages,
                onImageAdded: (file) {
                  setState(() {
                    selectedImages.add(file);
                  });
                },
                onImageRemoved: (index) {
                  setState(() {
                    selectedImages.removeAt(index);
                  });
                },
              ),
              SizedBox(height: 24.h),

              DepartmentSelectorWidget(
                selectedDepartment: selectedDepartment,
                onTap: () {
                  _clearError('department');
                  _showDepartmentBottomSheet();
                },
                errorText: _errors['department'],
              ),

              ServiceCategorySelectorWidget(
                selectedCategory: selectedCategory,
                onTap: () {
                  _clearError('category');
                  _showCategoryBottomSheet();
                },
                errorText: _errors['category'],
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
                postCodeController: _postCodeController,
                notesController: _notesController,
                nameError: _errors['customerName'],
                numberError: _errors['customerNumber'] ?? _errors['customerNumberLength'],
                addressError: _errors['customerAddress'],
              ),

              /// ===========================> Assign To =====================================================>

              AssignToSelectorWidget(
                selectedRoles: selectedRoleNames,
                onTap: () {
                  _clearError('assignTo');
                  _showAssignRoleBottomSheet();
                },
                errorText: _errors['assignTo'],
              ),



              ///  ==================================== Assign to date =======================================>

              Obx(() => _singlePickerField(
                label: "Assign Date",
                value: departmentController.startDate.value == null
                    ? null : _formatDate(departmentController.startDate.value!),
                hint: "Select assign date",
                icon: Icons.calendar_today_outlined,
                onTap: () { _clearError('assignDate'); _pickDate(true); },
                errorText: _errors['assignDate'],
              )),

              Obx(() => _singlePickerField(
                label: "Assign Time",
                value: departmentController.startTime.value == null
                    ? null : _formatTime(departmentController.startTime.value!),
                hint: "Select assign time",
                icon: Icons.access_time_outlined,
                onTap: () { _clearError('assignTime'); _pickTime(true); },
                errorText: _errors['assignTime'],
              )),

              Obx(() => _singlePickerField(
                label: "Deadline Date",
                value: departmentController.endDate.value == null
                    ? null : _formatDate(departmentController.endDate.value!),
                hint: "Select deadline date",
                icon: Icons.calendar_today_outlined,
                onTap: () { _clearError('deadlineDate'); _clearError('deadlineBeforeStart'); _pickDate(false); },
                errorText: _errors['deadlineDate'] ?? _errors['deadlineBeforeStart'],
              )),

              Obx(() => _singlePickerField(
                label: "Deadline Time",
                value: departmentController.endTime.value == null
                    ? null : _formatTime(departmentController.endTime.value!),
                hint: "Select deadline time",
                icon: Icons.access_time_outlined,
                onTap: () { _clearError('deadlineTime'); _pickTime(false); },
                errorText: _errors['deadlineTime'],
              )),

              // PrioritySelectorWidget(
              //   selectedPriority: selectedPriority,
              //   onTap: () {
              //     _clearError('priority');
              //     _showPriorityBottomSheet();
              //   },
              //   errorText: _errors['priority'],
              // ),

              // DifficultySelectorWidget(
              //   selectedDifficulty: selectedDifficulty,
              //   onTap: () {
              //     _clearError('difficulty');
              //     _showDifficultyBottomSheet();
              //   },
              //   errorText: _errors['difficulty'],
              // ),

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
        return StatefulBuilder(
          builder: (context, setModalState) {
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

              return Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Department",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.edit_outlined, size: 20.r, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Search Field
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Search here...",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
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
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Department List
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: departments.length,
                          itemBuilder: (context, index) {
                            final dept = departments[index];
                            final isSelected = selectedDepartment == dept.name;

                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedDepartment = dept.name;
                                });
                                setState(() {
                                  selectedDepartment = dept.name;
                                });
                                departmentController.updateSelectedDepartment(
                                  dept.id ?? '',
                                  dept.name ?? '',
                                );
                                Navigator.pop(context);
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: isSelected ? Colors.black : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dept.name ?? "N/A",
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        // Edit Icon
                                        IconButton(
                                          onPressed: () {
                                            _showUpdateDepartmentDialog(dept);
                                          },
                                          icon: Icon(Icons.edit, size: 18.r, color: Colors.grey),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                        ),
                                        SizedBox(width: 12.w),
                                        // Selection Indicator
                                        Container(
                                          width: 24.r,
                                          height: 24.r,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected ? Colors.black : Colors.transparent,
                                            border: Border.all(
                                              color: isSelected ? Colors.black : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16.r,
                                          )
                                              : null,
                                        ),
                                      ],
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
                ),
              );
            });
          },
        );
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

          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
            child: Padding(
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
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: categories.map((cat) {
                  bool isSelected = selectedCategory == cat.name;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat.name;
                      });
                      departmentController.updateSelectedCategory(cat.id ?? '', cat.name ?? '');
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
                          Expanded(
                            child: Column(
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
                ),
              ),
            ),
                SizedBox(height: 20.h),
              ],
            ),
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
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car_outlined, size: 50.r, color: Colors.grey),
                        SizedBox(height: 16.h),
                        Text(
                          "No vehicles found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Vehicle",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.edit_outlined, size: 20.r, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Search Field
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Search here...",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
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
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Vehicle List
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: vehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = vehicles[index];
                            final isSelected = selectedVehicle == vehicle.name;

                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedVehicle = vehicle.name;
                                });
                                setState(() {
                                  selectedVehicle = vehicle.name;
                                });
                                departmentController.updateSelectedVehicle(
                                  vehicle.id ?? '',
                                  vehicle.name ?? '',
                                );
                                Navigator.pop(context);
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: isSelected ? Colors.black : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            vehicle.name ?? "N/A",
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                          if (vehicle.description != null && vehicle.description!.isNotEmpty)
                                            Padding(
                                              padding: EdgeInsets.only(top: 4.h),
                                              child: Text(
                                                vehicle.description!,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        // Edit Icon
                                        IconButton(
                                          onPressed: () {
                                            _showUpdateVehicleDialog(vehicle);
                                          },
                                          icon: Icon(Icons.edit, size: 18.r, color: Colors.grey),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                        ),
                                        SizedBox(width: 12.w),
                                        // Selection Indicator
                                        Container(
                                          width: 24.r,
                                          height: 24.r,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected ? Colors.black : Colors.transparent,
                                            border: Border.all(
                                              color: isSelected ? Colors.black : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16.r,
                                          )
                                              : null,
                                        ),
                                      ],
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
                ),
              );
            });
          },
        );
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
                                  selectedRoleNames.remove(employeeName);
                                } else {
                                  selectedRoles.add(employeeId);
                                  selectedRoleNames.add(employeeName);
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
                    departmentController.updateSelectedPriority(priority);
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


  final Map<String, String> difficultyDisplayMap = {
    'very easy': 'Very Easy',
    'easy': 'Easy',
    'moderate': 'Moderate',
    'hard': 'Hard',
    'very hard': 'Very Hard',
  };


  List<String> get priorities => priorityDisplayMap.keys.toList();
  List<String> get difficulties => difficultyDisplayMap.keys.toList();

  @override
  void dispose() {
    _scrollController.dispose();
    _postCodeController.dispose();
    _customerNameController.removeListener(_onNameChanged);
    _customerNumberController.removeListener(_onNumberChanged);
    _customerAddressController.removeListener(_onAddressChanged);
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

    // Treat selected time as SGT (UTC+8) regardless of device timezone,
    // then subtract 8 hours to store as UTC on the server.
    final sgt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final utc = sgt.subtract(const Duration(hours: 8));
    return DateTime.utc(utc.year, utc.month, utc.day, utc.hour, utc.minute).toIso8601String();
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

    // Join all selected roles for assignTo (if multiple employees can be assigned)
    String assignTo = selectedRoles.join(','); // Join with comma if multiple roles, or use first if single assignment needed

    // Call the createNewTask method from DepartmentController
    String? result = await departmentController.createNewTask(
      departmentId: departmentController.selectedDepartmentId.value,
      serviceCategoryId: departmentController.selectedCategoryId.value,
      vehicleId: departmentController.selectedVehicleId.value.isNotEmpty
          ? departmentController.selectedVehicleId.value
          : "",  // Pass the selected vehicle ID if not empty, otherwise empty string
      customerName: _customerNameController.text.trim(),
      customerNumber: _customerNumberController.text.trim(),
      customerAddress: _customerAddressController.text.trim(),
      postCode: _postCodeController.text.trim(),
      assignTo: assignTo,
      assignDate: assignDate,
      deadline: deadlineDate,
      services: services,
      otherAmount: otherAmount,
      totalAmount: totalAmount,
      attachmentFiles: selectedImages,
      notes: _notesController.text.trim(),
      // priority: selectedPriority!.toLowerCase(),
      // difficulty: selectedDifficulty!.toLowerCase(),
    );

    if (result == 'success') {
      departmentController.resetTaskForm();
      _customerNameController.clear();
      _customerNumberController.clear();
      _customerAddressController.clear();
      _postCodeController.clear();
      _notesController.clear();
      _initializeLocalVariablesFromController();
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 300), () {
        final adminHomeController = Get.find<AdminHomeController>();
        adminHomeController.getAllListTasks();
      });
    } else if (result != null && result.startsWith('error:')) {
      final apiError = result.replaceFirst('error:', '');
      setState(() {
        _errors['_api'] = apiError;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(apiError, style: const TextStyle(fontSize: 13))),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showUpdateVehicleDialog(VehicleResult vehicle) {
    TextEditingController nameController = TextEditingController(text: vehicle.name);
    TextEditingController descriptionController = TextEditingController(text: vehicle.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Text(
            "Update Vehicle",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Vehicle Name",
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
                    hintText: "Enter vehicle name",
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
                  "Description (Optional)",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
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
            Obx(() => ElevatedButton(
              onPressed: departmentController.updateVehicleLoading.value
                  ? null
                  : () async {
                if (nameController.text.trim().isEmpty) {
                  ToastMessageHelper.showToastMessage("Vehicle name cannot be empty");
                  return;
                }

                final success = await departmentController.updateVehicle(
                  vehicleId: vehicle.id ?? '',
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                );

                if (success) {
                  Navigator.pop(context);
                  // Update the selected vehicle name if it was the one being edited
                  if (selectedVehicle == vehicle.name) {
                    setState(() {
                      selectedVehicle = nameController.text.trim();
                    });
                    departmentController.updateSelectedVehicle(
                      vehicle.id ?? '',
                      nameController.text.trim(),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
              child: departmentController.updateVehicleLoading.value
                  ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                "Update",
                style: TextStyle(color: Colors.white),
              ),
            )),
          ],
        );
      },
    );
  }
  final Map<String, String> priorityDisplayMap = {
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High',
    'urgent': 'Urgent',
  };


  void _showUpdateDepartmentDialog(Department dept) {
    TextEditingController nameController = TextEditingController(text: dept.name);
    TextEditingController descriptionController = TextEditingController(text: dept.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Text(
            "Update Department",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Department Name",
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
                    hintText: "Enter department name",
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
                  "Description (Optional)",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
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
            Obx(() => ElevatedButton(
              onPressed: departmentController.updateDepartmentLoading.value
                  ? null
                  : () async {
                if (nameController.text.trim().isEmpty) {
                  ToastMessageHelper.showToastMessage("Department name cannot be empty");
                  return;
                }

                final success = await departmentController.updateDepartment(
                  departmentId: dept.id ?? '',
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                );

                if (success) {
                  Navigator.pop(context);
                  // Update the selected department name if it was the one being edited
                  if (selectedDepartment == dept.name) {
                    setState(() {
                      selectedDepartment = nameController.text.trim();
                    });
                    departmentController.updateSelectedDepartment(
                      dept.id ?? '',
                      nameController.text.trim(),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
              child: departmentController.updateDepartmentLoading.value
                  ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                "Update",
                style: TextStyle(color: Colors.white),
              ),
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


  void _clearError(String key) {
    if (_errors[key] != null) setState(() => _errors[key] = null);
  }

  Widget _singlePickerField({
    required String label,
    required String? value,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    final hasValue = value != null && value.isNotEmpty;

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
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: hasError ? Colors.red.shade400 : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 16.sp, color: Colors.grey.shade600),
                  SizedBox(width: 8.w),
                  Text(
                    hasValue ? value! : hint,
                    style: TextStyle(
                      color: hasValue ? Colors.black87 : Colors.grey.shade500,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasError) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.error_outline, size: 12.sp, color: Colors.red.shade600),
                SizedBox(width: 4.w),
                Text(errorText, style: TextStyle(fontSize: 11.sp, color: Colors.red.shade600)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _inlineErrorRow(String message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 2.w),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 12.sp, color: Colors.red.shade600),
          SizedBox(width: 4.w),
          Text(message, style: TextStyle(fontSize: 11.sp, color: Colors.red.shade600)),
        ],
      ),
    );
  }

  void _showToast(String fieldKey) {
    // Map field key → human-readable error for inline display
    const messages = <String, String>{
      'department':           'Please select a department',
      'category':             'Please select a service category',
      'customerName':         'Customer name is required',
      'customerNumber':       'Customer phone number is required',
      'customerNumberLength': 'Phone number must be at least 10 digits',
      'customerAddress':      'Customer address is required',
      'assignTo':             'Please assign at least one employee',
      'assignDate':           'Please select the assign date',
      'assignTime':           'Please select the assign time',
      'deadlineDate':         'Please select the deadline date',
      'deadlineTime':         'Please select the deadline time',
      'deadlineBeforeStart':  'Deadline date cannot be before assign date',
      'services':             'Please add at least one service',
      'priority':             'Please select a priority level',
      'difficulty':           'Please select a difficulty level',
    };

    setState(() {
      _errors.clear();
      _errors[fieldKey] = messages[fieldKey] ?? fieldKey;
    });

    // Scroll to top so user sees the first error
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }



  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    // Option 1: "5 Nov 2024" format
    return "${date.day} ${months[date.month - 1]} ${date.year}";

    // Option 2: "05/11/2024" format (uncomment if preferred)
    // return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }


  String _formatTime(TimeOfDay time) {
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
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