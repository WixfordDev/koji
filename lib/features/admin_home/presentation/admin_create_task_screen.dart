import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../constants/app_color.dart';
import '../../../controller/admincontroller/department_controller.dart';
import '../../../helpers/toast_message_helper.dart';
import '../../../models/admin-model/all_serviceList_model.dart';
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

class AdminCreateTaskScreen extends StatefulWidget {
  const AdminCreateTaskScreen({super.key});

  @override
  State<AdminCreateTaskScreen> createState() => _AdminCreateTaskScreenState();
}


class _AdminCreateTaskScreenState extends State<AdminCreateTaskScreen> {
  final DepartmentController departmentController = Get.find();

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerNumberController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      departmentController.getAllDepartment();
      departmentController.getAllCategories();
      departmentController.getAllEmployee();
      departmentController.getAllServiceList();

      // Initialize local variables from controller
      _initializeLocalVariablesFromController();
    });
  }

  void _initializeLocalVariablesFromController() {
    selectedImages = List.from(departmentController.selectedImages);
    selectedDepartment = departmentController.selectedDepartment.value;
    selectedCategory = departmentController.selectedCategory.value;
    selectedRoles = List.from(departmentController.selectedRoles);
    selectedPriority = departmentController.selectedPriority.value;
    selectedDifficulty = departmentController.selectedDifficulty.value;
    selectedServiceList = List.from(departmentController.selectedServiceList);
    startDate = departmentController.startDate.value;
    endDate = departmentController.endDate.value;
    startTime = departmentController.startTime.value;
    endTime = departmentController.endTime.value;
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

              ServiceListWidget(
                selectedServiceList: selectedServiceList,
                onAddPressed: _showServicePickerBottomSheet,
                onRemovePressed: _removeSelectedService,
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

              DateTimePickerWidget(
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

              DateTimePickerWidget(
                label: "Assign Time",
                startHint: startTime == null ? "Start Time" : startTime!.format(context),
                endHint: endTime == null ? "End Time" : endTime!.format(context),
                startOnTap: () => _pickTime(true),
                endOnTap: () => _pickTime(false),
                iconPath: "assets/icons/time.svg",
              ),

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
                ),
              ),

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
    departmentController.removeServiceItemAt(index);
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
      if (isStart) {
        departmentController.updateStartDate(picked);
      } else {
        departmentController.updateEndDate(picked);
      }
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      if (isStart) {
        departmentController.updateStartTime(picked);
      } else {
        departmentController.updateEndTime(picked);
      }
    }
  }


  final List<String> priorities = ['Low', 'Medium', 'Important', 'Urgent'];
  final List<String> difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void dispose() {
    super.dispose();
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
    // Use controller's validation with local variables
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

    // Use local values to format dates to ISO strings
    String assignDate = _formatDateToISO(startDate, startTime);
    String deadlineDate = _formatDateToISO(endDate, endTime);

    // Prepare services list
    List<String> services = selectedServiceList
        .map((item) => '${item.serviceItem.name} (Qty: ${item.quantity})')
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

  void _showToast(String message) {
    ToastMessageHelper.showToastMessage(message);
  }

}