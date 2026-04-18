import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:koji/features/admin_home/presentation/widget/custom_loader.dart';
import '../../../constants/app_color.dart';
import '../../../controller/admincontroller/admin_home_controller.dart';
import '../../../controller/admincontroller/department_controller.dart';
import '../../../helpers/toast_message_helper.dart';
import '../../../models/admin-model/get_alllist_task_model.dart';
import '../../../services/api_constants.dart';

class AdminEditTaskScreen extends StatefulWidget {
  final Result task;
  const AdminEditTaskScreen({super.key, required this.task});

  @override
  State<AdminEditTaskScreen> createState() => _AdminEditTaskScreenState();
}

class _AdminEditTaskScreenState extends State<AdminEditTaskScreen> {
  late final AdminHomeController _adminController;
  late final DepartmentController _deptController;

  final _customerNameController = TextEditingController();
  final _customerNumberController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _notesController = TextEditingController();
  final _otherAmountController = TextEditingController();
  final _scrollController = ScrollController();

  String? _departmentId;
  String? _departmentName;
  String? _categoryId;
  String? _categoryName;
  String? _vehicleId;
  String? _vehicleName;
  List<String> _assignToIds = [];
  List<String> _assignToNames = [];
  String? _priority;
  String? _difficulty;
  List<_ServiceItem> _services = [];

  DateTime? _assignDate;
  TimeOfDay? _assignTime;
  DateTime? _deadlineDate;
  TimeOfDay? _deadlineTime;

  File? _attachmentFile;

  final Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _adminController = Get.find<AdminHomeController>();
    _deptController = Get.find<DepartmentController>();

    _prefillFromTask();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deptController.getAllDepartment();
      _deptController.getAllCategories();
      _deptController.getAllEmployee();
      _deptController.getAllServiceList();
      _deptController.getAllVehicles();
      _resolveNamesFromIds();
    });
  }

  void _prefillFromTask() {
    final t = widget.task;
    _customerNameController.text = t.customerName ?? '';
    _customerNumberController.text = t.customerNumber ?? '';
    _customerAddressController.text = t.customerAddress ?? '';
    _notesController.text = t.notes ?? '';
    _otherAmountController.text = (t.otherAmount ?? 0).toString();

    _departmentId = t.department;
    _categoryId = t.serviceCategory;
    _vehicleId = t.vehicle;
    _priority = t.priority;
    _difficulty = t.difficulty;
    _assignToIds = List<String>.from(t.assignTo ?? []);

    if (t.assignDate != null) {
      _assignDate = t.assignDate;
      _assignTime = TimeOfDay.fromDateTime(t.assignDate!);
    }
    if (t.deadline != null) {
      _deadlineDate = t.deadline;
      _deadlineTime = TimeOfDay.fromDateTime(t.deadline!);
    }

    _services = (t.services ?? []).map((s) => _ServiceItem(
      name: s.name ?? '',
      price: (s.price ?? 0).toDouble(),
      quantity: s.quantity ?? 1,
    )).toList();
  }

  void _resolveNamesFromIds() {
    // Try to resolve names from already-loaded lists; fallback to IDs
    final departments = _deptController.allDepartment.value.results ?? [];
    final match = departments.where((d) => d.id == _departmentId).toList();
    if (match.isNotEmpty) setState(() => _departmentName = match.first.name);

    final categories = _deptController.categories.value.results ?? [];
    final catMatch = categories.where((c) => c.id == _categoryId).toList();
    if (catMatch.isNotEmpty) setState(() => _categoryName = catMatch.first.name);

    final vehicles = _deptController.allVehicles.value.attributes?.results ?? [];
    final vMatch = vehicles.where((v) => v.id == _vehicleId).toList();
    if (vMatch.isNotEmpty) setState(() { _vehicleId = vMatch.first.id; _vehicleName = vMatch.first.name; });

    final employees = _deptController.employee.value.results ?? [];
    List<String> names = [];
    for (final id in _assignToIds) {
      final emp = employees.where((e) => e.id == id).toList();
      if (emp.isNotEmpty) names.add(emp.first.fullName ?? id);
    }
    if (names.isNotEmpty) setState(() => _assignToNames = names);
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerNumberController.dispose();
    _customerAddressController.dispose();
    _notesController.dispose();
    _otherAmountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String _formatDate(DateTime dt) => DateFormat('dd MMM yyyy').format(dt);
  String _formatTime(TimeOfDay t) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat('hh:mm a').format(dt).toUpperCase();
  }

  String _buildISO(DateTime? date, TimeOfDay? time) {
    if (date == null) return '';
    // Convert to UTC so the server receives an unambiguous timestamp.
    final d = DateTime(
      date.year, date.month, date.day,
      time?.hour ?? 0, time?.minute ?? 0,
    );
    return d.toUtc().toIso8601String();
  }

  double _calcTotal() {
    double servicesTotal = _services.fold(0, (sum, s) => sum + s.price * s.quantity);
    double other = double.tryParse(_otherAmountController.text.trim()) ?? 0;
    return servicesTotal + other;
  }

  void _clearError(String key) {
    if (_errors[key] != null) setState(() => _errors[key] = null);
  }

  // ─── Validation ─────────────────────────────────────────────────────────────

  bool _validate() {
    final errs = <String, String>{};
    if (_customerNameController.text.trim().isEmpty) errs['name'] = 'Customer name is required';
    if (_customerNumberController.text.trim().isEmpty) errs['number'] = 'Customer number is required';
    if (_customerAddressController.text.trim().isEmpty) errs['address'] = 'Customer address is required';
    if (_departmentId == null || _departmentId!.isEmpty) errs['department'] = 'Select a department';
    if (_categoryId == null || _categoryId!.isEmpty) errs['category'] = 'Select a service category';
    if (_assignToIds.isEmpty) errs['assignTo'] = 'Assign to at least one employee';
    if (_assignDate == null) errs['assignDate'] = 'Select an assign date';
    if (_deadlineDate == null) errs['deadline'] = 'Select a deadline';
    if (_priority == null) errs['priority'] = 'Select a priority';
    if (_difficulty == null) errs['difficulty'] = 'Select a difficulty';
    setState(() { _errors.clear(); _errors.addAll(errs); });
    return errs.isEmpty;
  }

  // ─── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_validate()) {
      ToastMessageHelper.showToastMessage('Please fill all required fields');
      return;
    }

    final result = await _adminController.updateTask(
      taskId: widget.task.id ?? '',
      departmentId: _departmentId!,
      serviceCategoryId: _categoryId!,
      vehicleId: _vehicleId,
      customerName: _customerNameController.text.trim(),
      customerNumber: _customerNumberController.text.trim(),
      customerAddress: _customerAddressController.text.trim(),
      assignTo: _assignToIds,
      assignDate: _buildISO(_assignDate, _assignTime),
      deadline: _buildISO(_deadlineDate, _deadlineTime),
      services: _services.map((s) => {'name': s.name, 'price': s.price, 'quantity': s.quantity}).toList(),
      otherAmount: double.tryParse(_otherAmountController.text.trim()) ?? 0,
      totalAmount: _calcTotal(),
      notes: _notesController.text.trim(),
      priority: _priority!.toLowerCase(),
      difficulty: _difficulty!.toLowerCase(),
      attachmentFile: _attachmentFile,
    );

    if (result == 'success') {
      Navigator.pop(context);
    } else if (result != null && result.startsWith('error:')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.replaceFirst('error:', '')),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            Text(
              'Edit Task',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Attachment'),
              _attachmentPicker(),
              SizedBox(height: 20.h),

              _sectionLabel('Department *'),
              _selectorTile(
                value: _departmentName ?? (_departmentId != null ? 'Department selected' : null),
                hint: 'Select department',
                icon: Icons.business_outlined,
                error: _errors['department'],
                onTap: () { _clearError('department'); _showDepartmentSheet(); },
              ),
              SizedBox(height: 16.h),

              _sectionLabel('Service Category *'),
              _selectorTile(
                value: _categoryName ?? (_categoryId != null ? 'Category selected' : null),
                hint: 'Select service category',
                icon: Icons.category_outlined,
                error: _errors['category'],
                onTap: () { _clearError('category'); _showCategorySheet(); },
              ),
              SizedBox(height: 16.h),

              _sectionLabel('Vehicle'),
              _selectorTile(
                value: _vehicleName,
                hint: 'Select vehicle (optional)',
                icon: Icons.directions_car_outlined,
                onTap: _showVehicleSheet,
              ),
              SizedBox(height: 16.h),

              _sectionLabel('Services'),
              _servicesList(),
              SizedBox(height: 8.h),
              _addServiceButton(),
              SizedBox(height: 16.h),

              _sectionLabel('Customer Name *'),
              _textField(
                controller: _customerNameController,
                hint: 'Enter customer name',
                error: _errors['name'],
                onChanged: (_) => _clearError('name'),
              ),
              SizedBox(height: 16.h),

              _sectionLabel('Customer Number *'),
              _textField(
                controller: _customerNumberController,
                hint: 'Enter customer number',
                keyboardType: TextInputType.phone,
                error: _errors['number'],
                onChanged: (_) => _clearError('number'),
              ),
              SizedBox(height: 16.h),

              _sectionLabel('Customer Address *'),
              _textField(
                controller: _customerAddressController,
                hint: 'Enter customer address',
                error: _errors['address'],
                onChanged: (_) => _clearError('address'),
              ),
              SizedBox(height: 16.h),

              _sectionLabel('Assign To *'),
              _selectorTile(
                value: _assignToNames.isEmpty
                    ? (_assignToIds.isEmpty ? null : '${_assignToIds.length} employee(s) selected')
                    : _assignToNames.join(', '),
                hint: 'Select employees',
                icon: Icons.people_outlined,
                error: _errors['assignTo'],
                onTap: () { _clearError('assignTo'); _showAssignSheet(); },
              ),
              SizedBox(height: 16.h),

              _sectionLabel('Assign Date *'),
              _dateTile(
                label: _assignDate != null ? _formatDate(_assignDate!) : null,
                hint: 'Select assign date',
                icon: Icons.calendar_today_outlined,
                error: _errors['assignDate'],
                onTap: () { _clearError('assignDate'); _pickDate(true); },
              ),
              SizedBox(height: 12.h),
              _dateTile(
                label: _assignTime != null ? _formatTime(_assignTime!) : null,
                hint: 'Select assign time',
                icon: Icons.access_time_outlined,
                onTap: () => _pickTime(true),
              ),
              SizedBox(height: 16.h),

              _sectionLabel('Deadline *'),
              _dateTile(
                label: _deadlineDate != null ? _formatDate(_deadlineDate!) : null,
                hint: 'Select deadline date',
                icon: Icons.calendar_today_outlined,
                error: _errors['deadline'],
                onTap: () { _clearError('deadline'); _pickDate(false); },
              ),
              SizedBox(height: 12.h),
              _dateTile(
                label: _deadlineTime != null ? _formatTime(_deadlineTime!) : null,
                hint: 'Select deadline time',
                icon: Icons.access_time_outlined,
                onTap: () => _pickTime(false),
              ),
              SizedBox(height: 16.h),

              _sectionLabel('Priority *'),
              _chipSelector(
                options: ['low', 'medium', 'high'],
                selected: _priority,
                error: _errors['priority'],
                onSelected: (v) { setState(() => _priority = v); _clearError('priority'); },
              ),
              SizedBox(height: 16.h),

              _sectionLabel('Difficulty *'),
              _chipSelector(
                options: ['easy', 'medium', 'hard', 'very hard'],
                selected: _difficulty,
                error: _errors['difficulty'],
                onSelected: (v) { setState(() => _difficulty = v); _clearError('difficulty'); },
              ),
              SizedBox(height: 16.h),

              _sectionLabel('Other Amount'),
              _textField(
                controller: _otherAmountController,
                hint: '0',
                keyboardType: TextInputType.number,
                prefixText: '\$ ',
              ),
              SizedBox(height: 8.h),
              _totalAmountDisplay(),
              SizedBox(height: 16.h),

              _sectionLabel('Notes'),
              _textField(
                controller: _notesController,
                hint: 'Enter notes...',
                maxLines: 4,
              ),
              SizedBox(height: 28.h),

              _submitButton(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Widgets ─────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Text(
      text,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87),
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? error,
    String? prefixText,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xffF9FAFB),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: error != null ? Colors.red : const Color(0xffE5E7EB)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            style: TextStyle(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: hint,
              prefixText: prefixText,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(error, style: TextStyle(color: Colors.red, fontSize: 11.sp)),
          ),
      ],
    );
  }

  Widget _selectorTile({
    required String? value,
    required String hint,
    required IconData icon,
    String? error,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xffF9FAFB),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: error != null ? Colors.red : const Color(0xffE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18.r, color: Colors.grey[500]),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: value != null ? Colors.black87 : Colors.grey[400],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[400], size: 20.r),
              ],
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(error, style: TextStyle(color: Colors.red, fontSize: 11.sp)),
          ),
      ],
    );
  }

  Widget _dateTile({
    required String? label,
    required String hint,
    required IconData icon,
    String? error,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xffF9FAFB),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: error != null ? Colors.red : const Color(0xffE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18.r, color: Colors.grey[500]),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    label ?? hint,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: label != null ? Colors.black87 : Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(error, style: TextStyle(color: Colors.red, fontSize: 11.sp)),
          ),
      ],
    );
  }

  Widget _chipSelector({
    required List<String> options,
    required String? selected,
    String? error,
    required void Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((opt) {
            final isSelected = selected?.toLowerCase() == opt.toLowerCase();
            return GestureDetector(
              onTap: () => onSelected(opt),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.primaryColor : const Color(0xffF9FAFB),
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: isSelected ? AppColor.primaryColor : const Color(0xffE5E7EB),
                  ),
                ),
                child: Text(
                  _capitalize(opt),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (error != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(error, style: TextStyle(color: Colors.red, fontSize: 11.sp)),
          ),
      ],
    );
  }

  Widget _servicesList() {
    if (_services.isEmpty) return const SizedBox.shrink();
    return Column(
      children: _services.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xffF0F4FF),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xffDDE3F5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 2.h),
                    Text('\$${s.price.toStringAsFixed(0)} × ${s.quantity}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                  ],
                ),
              ),
              Text(
                '\$${(s.price * s.quantity).toStringAsFixed(0)}',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColor.primaryColor),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => _showEditServiceDialog(i),
                child: Icon(Icons.edit_outlined, size: 18.r, color: Colors.grey[500]),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => setState(() => _services.removeAt(i)),
                child: Icon(Icons.close, size: 18.r, color: Colors.red[300]),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _addServiceButton() {
    return GestureDetector(
      onTap: _showAddServiceSheet,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColor.primaryColor.withOpacity(0.3), style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColor.primaryColor, size: 18.r),
            SizedBox(width: 6.w),
            Text('Add Service', style: TextStyle(fontSize: 13.sp, color: AppColor.primaryColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _totalAmountDisplay() {
    return StatefulBuilder(
      builder: (_, setState) {
        _otherAmountController.addListener(() => setState(() {}));
        final total = _calcTotal();
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xffF0F4FF),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              Text('\$${total.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColor.primaryColor)),
            ],
          ),
        );
      },
    );
  }

  Widget _attachmentPicker() {
    final existingAttachments = widget.task.attachments ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show existing attachments from server
        if (existingAttachments.isNotEmpty && _attachmentFile == null) ...[
          SizedBox(
            height: 90.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: existingAttachments.length,
              itemBuilder: (context, i) {
                final rawPath = existingAttachments[i];
                final base = ApiConstants.imageBaseUrl.endsWith('/')
                    ? ApiConstants.imageBaseUrl
                    : '${ApiConstants.imageBaseUrl}/';
                final url = rawPath.startsWith('http')
                    ? rawPath
                    : '$base${rawPath.startsWith('/') ? rawPath.substring(1) : rawPath}';
                return Container(
                  width: 90.w,
                  height: 90.h,
                  margin: EdgeInsets.only(right: 8.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xffE5E7EB)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 28.r),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8.h),
        ],

        // New file picker / replace button
        GestureDetector(
          onTap: _pickAttachment,
          child: Container(
            height: 90.h,
            decoration: BoxDecoration(
              color: const Color(0xffF9FAFB),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xffE5E7EB)),
            ),
            child: _attachmentFile != null
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          _attachmentFile!,
                          width: double.infinity,
                          height: 90.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 6.r,
                        right: 6.r,
                        child: GestureDetector(
                          onTap: () => setState(() => _attachmentFile = null),
                          child: CircleAvatar(
                            radius: 12.r,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, color: Colors.white, size: 14.r),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 28.r, color: Colors.grey[400]),
                      SizedBox(height: 6.h),
                      Text(
                        existingAttachments.isNotEmpty
                            ? 'Tap to add more attachment'
                            : 'Tap to add attachment',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: _adminController.updateTaskLoading.value ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          elevation: 0,
        ),
        child: _adminController.updateTaskLoading.value
            ? SizedBox(width: 22.r, height: 22.r, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text('Update Task', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    ));
  }

  // ─── Date / Time Pickers ────────────────────────────────────────────────────

  Future<void> _pickDate(bool isAssign) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isAssign ? _assignDate : _deadlineDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() { if (isAssign) _assignDate = picked; else _deadlineDate = picked; });
  }

  Future<void> _pickTime(bool isAssign) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isAssign ? _assignTime : _deadlineTime) ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() { if (isAssign) _assignTime = picked; else _deadlineTime = picked; });
  }

  // ─── Attachment ─────────────────────────────────────────────────────────────

  Future<void> _pickAttachment() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _attachmentFile = File(picked.path));
  }

  // ─── Bottom Sheets ───────────────────────────────────────────────────────────

  void _showDepartmentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => StatefulBuilder(builder: (_, setS) => Obx(() {
        if (_deptController.getAllDepartmentModelLoading.value) {
          return SizedBox(height: 300.h, child: const Center(child: CircularProgressIndicator()));
        }
        final items = _deptController.allDepartment.value.results ?? [];
        return _listSheet(
          title: 'Select Department',
          items: items.map((d) => _SheetItem(id: d.id ?? '', name: d.name ?? '')).toList(),
          selectedId: _departmentId,
          onSelect: (item) {
            setState(() { _departmentId = item.id; _departmentName = item.name; });
            Navigator.pop(context);
          },
        );
      })),
    );
  }

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => StatefulBuilder(builder: (_, setS) => Obx(() {
        if (_deptController.getCategoriesLoading.value) {
          return SizedBox(height: 300.h, child: const Center(child: CircularProgressIndicator()));
        }
        final items = _deptController.categories.value.results ?? [];
        return _listSheet(
          title: 'Select Service Category',
          items: items.map((c) => _SheetItem(id: c.id ?? '', name: c.name ?? '')).toList(),
          selectedId: _categoryId,
          onSelect: (item) {
            setState(() { _categoryId = item.id; _categoryName = item.name; });
            Navigator.pop(context);
          },
        );
      })),
    );
  }

  void _showVehicleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => StatefulBuilder(builder: (_, setS) => Obx(() {
        if (_deptController.getAllVehiclesModelLoading.value) {
          return SizedBox(height: 300.h, child: const Center(child: CircularProgressIndicator()));
        }
        final items = _deptController.allVehicles.value.attributes?.results ?? [];
        return _listSheet(
          title: 'Select Vehicle',
          items: items.map((v) => _SheetItem(id: v.id ?? '', name: v.name ?? '')).toList(),
          selectedId: _vehicleId,
          onSelect: (item) {
            setState(() { _vehicleId = item.id; _vehicleName = item.name; });
            Navigator.pop(context);
          },
        );
      })),
    );
  }

  void _showAssignSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => Obx(() {
        if (_deptController.getEmployeeLoading.value) {
          return SizedBox(height: 300.h, child: const Center(child: CircularProgressIndicator()));
        }
        final employees = _deptController.employee.value.results ?? [];
        List<String> tempIds = List.from(_assignToIds);
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Assign To', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (_, i) {
                    final emp = employees[i];
                    final id = emp.id ?? '';
                    return StatefulBuilder(builder: (_, setItem) {
                      final isSelected = tempIds.contains(id);
                      return GestureDetector(
                        onTap: () {
                          setItem(() { if (isSelected) tempIds.remove(id); else tempIds.add(id); });
                          setS(() {});
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: tempIds.contains(id) ? AppColor.primaryColor.withOpacity(0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: tempIds.contains(id) ? AppColor.primaryColor : const Color(0xffE5E7EB),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18.r,
                                backgroundColor: AppColor.primaryColor.withOpacity(0.15),
                                child: Text(
                                  (emp.fullName ?? 'E')[0].toUpperCase(),
                                  style: TextStyle(color: AppColor.primaryColor, fontWeight: FontWeight.w600, fontSize: 14.sp),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(emp.fullName ?? 'N/A', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                                    Text(emp.email ?? '', style: TextStyle(fontSize: 11.sp, color: Colors.grey[500])),
                                  ],
                                ),
                              ),
                              if (tempIds.contains(id))
                                Icon(Icons.check_circle, color: AppColor.primaryColor, size: 20.r),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    final employees2 = _deptController.employee.value.results ?? [];
                    final names = tempIds.map((id) {
                      final e = employees2.where((e) => e.id == id).toList();
                      return e.isNotEmpty ? (e.first.fullName ?? id) : id;
                    }).toList();
                    setState(() { _assignToIds = tempIds; _assignToNames = names; });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text('Confirm (${tempIds.length})', style: TextStyle(color: Colors.white, fontSize: 15.sp)),
                ),
              ),
            ],
          ),
        );
      })),
    );
  }

  void _showAddServiceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => Obx(() {
        if (_deptController.getServiceLoading.value) {
          return SizedBox(height: 300.h, child: const Center(child: CircularProgressIndicator()));
        }
        final allServices = _deptController.serviceList.value.results ?? [];
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Service', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView.builder(
                  itemCount: allServices.length,
                  itemBuilder: (_, i) {
                    final svc = allServices[i];
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xffE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(svc.name ?? '', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                                Text('\$${svc.price ?? 0}', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _showServiceQtyDialog(svc.name ?? '', double.tryParse(svc.price ?? '0') ?? 0);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                            child: Text('Add', style: TextStyle(fontSize: 12.sp, color: Colors.white)),
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
      })),
    );
  }

  // Generic list bottom sheet
  Widget _listSheet({
    required String title,
    required List<_SheetItem> items,
    required String? selectedId,
    required void Function(_SheetItem) onSelect,
  }) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65),
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final isSelected = item.id == selectedId;
                return GestureDetector(
                  onTap: () => onSelect(item),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColor.primaryColor.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: isSelected ? AppColor.primaryColor : const Color(0xffE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(item.name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500))),
                        if (isSelected) Icon(Icons.check, color: AppColor.primaryColor, size: 18.r),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceQtyDialog(String name, double price) {
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController(text: price.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        title: Text('Add: $name', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price', prefixText: '\$ ', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(qtyCtrl.text.trim()) ?? 1;
              final p = double.tryParse(priceCtrl.text.trim()) ?? price;
              setState(() => _services.add(_ServiceItem(name: name, price: p, quantity: qty)));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(int index) {
    final s = _services[index];
    final qtyCtrl = TextEditingController(text: s.quantity.toString());
    final priceCtrl = TextEditingController(text: s.price.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        title: Text('Edit: ${s.name}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price', prefixText: '\$ ', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _services[index] = _ServiceItem(
                  name: s.name,
                  price: double.tryParse(priceCtrl.text.trim()) ?? s.price,
                  quantity: int.tryParse(qtyCtrl.text.trim()) ?? s.quantity,
                );
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─── Local Models ─────────────────────────────────────────────────────────────

class _ServiceItem {
  final String name;
  final double price;
  final int quantity;
  _ServiceItem({required this.name, required this.price, required this.quantity});
}

class _SheetItem {
  final String id;
  final String name;
  _SheetItem({required this.id, required this.name});
}
