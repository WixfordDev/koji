import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/controller/admincontroller/admin_home_controller.dart';
import 'package:koji/models/admin-model/all_employee_model.dart';
import 'package:koji/shared_widgets/custom_network_image.dart';
import 'package:koji/helpers/toast_message_helper.dart';
import '../../../services/api_constants.dart';

class AdminEmployeeView extends StatefulWidget {
  final Employee employee;

  const AdminEmployeeView({super.key, required this.employee});

  @override
  State<AdminEmployeeView> createState() => _AdminEmployeeViewState();
}

class _AdminEmployeeViewState extends State<AdminEmployeeView> {
  bool isPersonalDetailsExpanded = true;
  bool isContactInfoExpanded = false;
  bool isServiceDetailsExpanded = false;
  bool isShiftChangeExpanded = false;
  TextEditingController fullName = TextEditingController();

  // Local mutable copies so the profile card reflects updates immediately
  late String _displayName;
  late String _displayRole;

  @override
  void initState() {
    getFullName();
    super.initState();
    _displayName = widget.employee.fullName ??
        widget.employee.firstName ??
        'N/A';
    _displayRole = widget.employee.role ?? 'employee';
  }

  getFullName(){
    fullName.text = "${widget.employee.firstName} ${widget.employee.lastName}";
    setState(() {

    });
  }



  void _showUpdateSheet(BuildContext context, AdminHomeController controller) {
    final firstNameCtrl = TextEditingController(text: widget.employee.firstName ?? '');
    final lastNameCtrl = TextEditingController(text: widget.employee.lastName ?? '');

    final phoneCtrl =
        TextEditingController(text: widget.employee.phoneNumber ?? '');
    final addressCtrl =
        TextEditingController(text: widget.employee.address?.toString() ?? '');
    bool isAdminApproved = widget.employee.isAdminApproved ?? false;
    String selectedRole = _displayRole;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Update Employee',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 20.h),
                    _sheetField('First Name', firstNameCtrl),
                    SizedBox(height: 12.h),
                    _sheetField('Last Name', lastNameCtrl),
                    SizedBox(height: 12.h),
                    _sheetField('Phone Number', phoneCtrl,
                        keyboardType: TextInputType.phone),
                    SizedBox(height: 12.h),
                    _sheetField('Address', addressCtrl),
                    SizedBox(height: 12.h),
                    // Role selector
                    Text('Role',
                        style: TextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.w500)),
                    SizedBox(height: 6.h),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'employee', child: Text('Employee')),
                        DropdownMenuItem(
                            value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (val) {
                        if (val != null) setSheet(() => selectedRole = val);
                      },
                    ),
                    SizedBox(height: 16.h),
                    // isAdminApproved toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Admin Approved',
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500)),
                        Switch(
                          value: isAdminApproved,
                          activeColor: const Color(0xFFEC526A),
                          onChanged: (val) =>
                              setSheet(() => isAdminApproved = val),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => GestureDetector(
                            onTap: controller.updateEmployeeLoading.value
                                ? null
                                : () async {
                                    final body = <String, dynamic>{};
                                    if (firstNameCtrl.text.trim().isNotEmpty)
                                      body['firstName'] =
                                          firstNameCtrl.text.trim();
                                    if (lastNameCtrl.text.trim().isNotEmpty)
                                      body['lastName'] =
                                          lastNameCtrl.text.trim();
                                    if (phoneCtrl.text.trim().isNotEmpty)
                                      body['phoneNumber'] =
                                          phoneCtrl.text.trim();
                                    if (addressCtrl.text.trim().isNotEmpty)
                                      body['address'] =
                                          addressCtrl.text.trim();
                                    body['isAdminApproved'] = isAdminApproved;
                                    body['role'] = selectedRole;

                                    Navigator.pop(ctx);
                                    bool result = await controller
                                        .updateEmployeeApproval(
                                      employeeId: widget.employee.id ?? '',
                                      body: body,
                                    );
                                    if (result) {
                                      // Update local state so the profile card
                                      // shows the new name/role immediately
                                      if (mounted) {
                                        setState(() {
                                          final first =
                                              firstNameCtrl.text.trim();
                                          final last = lastNameCtrl.text.trim();
                                          final newName =
                                              '${first.isNotEmpty ? first : (widget.employee.firstName ?? '')} ${last.isNotEmpty ? last : (widget.employee.lastName ?? '')}'
                                                  .trim();
                                          _displayName = newName;
                                          fullName.text = newName;
                                          _displayRole = selectedRole;
                                        });
                                      }
                                      ToastMessageHelper.showToastMessage(
                                          'Employee updated successfully!');
                                    } else {
                                      ToastMessageHelper.showToastMessage(
                                          'Failed to update employee.',
                                          title: 'Error');
                                    }
                                  },
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFEC526A),
                                    Color(0xFFF77F6E)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: controller.updateEmployeeLoading.value
                                    ? SizedBox(
                                        width: 20.w,
                                        height: 20.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetField(String label, TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 6.h),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  String _getImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return "${ApiConstants.imageBaseUrl}$imageUrl";
  }

  @override
  Widget build(BuildContext context) {
    final adminHomeController = Get.find<AdminHomeController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Employee',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // Employee Profile Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 100.w,
                      width: 100.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade300,
                      ),
                      child: ClipOval(
                        child: CustomNetworkImage(
                          imageUrl: _getImageUrl(widget.employee.image ?? ''),
                          height: 100.w,
                          width: 100.w,
                          boxShape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "${fullName.text}",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _displayRole,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Personal Details Section
              _buildExpandableSection(
                title: "Personal Details",
                isExpanded: isPersonalDetailsExpanded,
                onTap: () {
                  setState(() {
                    isPersonalDetailsExpanded = !isPersonalDetailsExpanded;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Personal Information",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          _buildInfoRow("Employee Code", widget.employee.id != null && widget.employee.id!.length >= 6
                              ? 'EMP-${widget.employee.id!.substring(widget.employee.id!.length - 6).toUpperCase()}'
                              : 'N/A'),
                          _buildDivider(),
                          _buildInfoRow("Gender", widget.employee.gender ?? "N/A"),
                          _buildDivider(),
                          _buildInfoRow("Date of Birth", "01 January 2000"),
                          _buildDivider(),
                          _buildInfoRow("Marital Status", "Unmarried"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Contact Information Section
              _buildExpandableSection(
                title: "Contact Information",
                isExpanded: isContactInfoExpanded,
                onTap: () {
                  setState(() {
                    isContactInfoExpanded = !isContactInfoExpanded;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow("Email", widget.employee.email ?? "N/A"),
                      _buildDivider(),
                      _buildInfoRow("Phone", widget.employee.phoneNumber ?? "N/A"),
                      _buildDivider(),
                      _buildInfoRow("Address", widget.employee.address?.toString() ?? "N/A"),
                      _buildDivider(),
                      _buildInfoRow("Location", widget.employee.location?.locationName ?? "N/A"),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Service Details Section
              _buildExpandableSection(
                title: "Service Details",
                isExpanded: isServiceDetailsExpanded,
                onTap: () {
                  setState(() {
                    isServiceDetailsExpanded = !isServiceDetailsExpanded;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow("Role", widget.employee.role ?? "N/A"),
                      _buildDivider(),
                      _buildInfoRow("Shift", widget.employee.shift ?? "N/A"),
                      _buildDivider(),
                      _buildInfoRow("Created Date", widget.employee.createdAt != null
                          ? '${widget.employee.createdAt!.day}/${widget.employee.createdAt!.month}/${widget.employee.createdAt!.year}'
                          : 'N/A'),
                      _buildDivider(),
                      _buildInfoRow("Profile Completed", widget.employee.isProfileCompleted?.toString() ?? "false"),
                      _buildDivider(),
                      _buildInfoRow("Admin Approved", widget.employee.isAdminApproved?.toString() ?? "true"),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Shift Change Section
              _buildExpandableSection(
                title: "Shift Change",
                isExpanded: isShiftChangeExpanded,
                onTap: () {
                  setState(() {
                    isShiftChangeExpanded = !isShiftChangeExpanded;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow("Current Shift", widget.employee.shift ?? "N/A"),
                      _buildDivider(),
                      _buildInfoRow("Available Shifts", "Morning, Evening, Night"),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 100.h), // Space for bottom buttons
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Obx(() {
          final isDeleting = adminHomeController.deleteEmployeeLoading.value;
          final isUpdating = adminHomeController.updateEmployeeLoading.value;

          return Row(
            children: [
              // Delete Button
              Expanded(
                child: GestureDetector(
                  onTap: isDeleting
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Delete Employee"),
                              content: const Text(
                                  "Are you sure you want to delete this employee?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm != true) return;
                          bool result = await adminHomeController.deleteEmployee(
                            employeeId: widget.employee.id ?? '',
                          );
                          if (result) {
                            ToastMessageHelper.showToastMessage(
                                "Employee deleted successfully!");
                            Navigator.pop(context);
                          } else {
                            ToastMessageHelper.showToastMessage(
                                "Failed to delete employee.",
                                title: "Error");
                          }
                        },
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: const Color(0xFFEB0000)),
                    ),
                    child: Center(
                      child: isDeleting
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFEB0000)),
                              ),
                            )
                          : Text(
                              "Delete",
                              style: TextStyle(
                                color: const Color(0xFFEB0000),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Update Button
              Expanded(
                child: GestureDetector(
                  onTap: isUpdating
                      ? null
                      : () => _showUpdateSheet(context, adminHomeController),
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEC526A), Color(0xFFF77F6E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: isUpdating
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              "Update",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[200],
      thickness: 1,
      height: 1,
    );
  }
}