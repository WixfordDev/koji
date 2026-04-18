import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/controller/employee_schedule_controller.dart';
import 'package:koji/features/employee_schedule/presentation/submit_task_screen.dart';
import 'package:koji/services/api_constants.dart';
import 'package:intl/intl.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late final EmployeeScheduleController controller;
  bool _isAccepting = false;

  // Gradient colors
  static const Color primaryDark = Color(0xFF162238);
  static const Color primaryBlue = Color(0xFF4082FB);

  @override
  void initState() {
    super.initState();
    controller = Get.put(EmployeeScheduleController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTaskById(widget.taskId);
    });
  }

  /// Reusable gradient button
  Widget _gradientButton({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            transform: GradientRotation(344.45 * 3.14159 / 180),
            colors: [primaryDark, primaryBlue],
          ),
          borderRadius: BorderRadius.circular(100.r),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
          height: 22.h,
          width: 22.h,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Task Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final task = controller.selectedTask.value;

        if (task == null) {
          return Center(
            child: Text(
              'Failed to load task details',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAttachmentSection(task),
                SizedBox(height: 24.h),
                _buildTextField('Department', task.department?.name ?? 'N/A'),
                SizedBox(height: 12.h),
                _buildTextField('Service Category', task.serviceCategory?.name ?? 'N/A'),
                SizedBox(height: 12.h),

                // Service List Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service List',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: task.service?.length ?? 0,
                        separatorBuilder: (context, index) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final serviceItem = task.service![index];
                          final price = serviceItem.price ?? 0;
                          final quantity = serviceItem.quantity ?? 0;
                          final total = price * quantity;
                          return _buildServiceItem(
                            '${serviceItem.name ?? 'Service'} (x$quantity)',
                            '\$${total.toStringAsFixed(1)}',
                          );
                        },
                      ),
                      _buildServiceItem('Others Amount', '\$${task.otherAmount?.toStringAsFixed(1) ?? '0.0'}'),
                      SizedBox(height: 8.h),
                      _buildServiceItem('GST 9%', ''),
                      Divider(height: 24.h, color: Colors.grey[300]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Price',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [primaryDark, primaryBlue],
                            ).createShader(bounds),
                            child: Text(
                              '\$${task.totalAmount?.toStringAsFixed(1) ?? '0.0'}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),
                _buildTextField('Customer Name', task.customerName ?? 'N/A'),
                SizedBox(height: 12.h),
                _buildTextField('Customer Number', task.customerNumber ?? 'N/A'),
                SizedBox(height: 12.h),
                _buildTextField('Customer Address', task.customerAddress ?? 'N/A'),
                SizedBox(height: 12.h),
                _buildTextField('Assign To', task.assignTo?.isNotEmpty == true ? task.assignTo!.join(', ') : 'N/A'),
                SizedBox(height: 12.h),
                _buildTextField('Vehicle Number', task.vehicle ?? 'N/A'),
                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(child: _buildDateField('Assign Date', task.assignDate?.toIso8601String())),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildTimeField('Assign Time', task.assignDate?.toIso8601String())),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(child: _buildDateField('End Date', task.deadline?.toIso8601String())),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildTimeField('End Time', task.deadline?.toIso8601String())),
                  ],
                ),
                SizedBox(height: 12.h),
                // _buildTextField('Priority', task.priority ?? 'N/A'),
                // SizedBox(height: 12.h),
                // _buildTextField('Difficulty', task.difficulty ?? 'N/A'),
                // SizedBox(height: 12.h),
                _buildTextField('Notes', task.notes ?? 'N/A'),
                SizedBox(height: 24.h),

                // Accept Button
                if (task.isSubmited != true && task.status?.toLowerCase() == 'pending')
                  _gradientButton(
                    label: 'Accept',
                    isLoading: _isAccepting,
                    onPressed: _isAccepting ? () {} : () => _acceptTask(task),
                  ),

                SizedBox(height: 12.h),

                // Go to Task Screen Button
                if (task.isSubmited != true && task.status?.toLowerCase() != 'pending')
                  _gradientButton(
                    label: 'Go to Task Screen',
                    onPressed: () => _goToTaskScreen(task),
                  ),

                // Already submitted
                if (task.isSubmited == true)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100.r),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Task Already Submitted',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.green),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Safely builds image URL — handles slash between base URL and path
  String _buildImageUrl(String baseUrl, String imagePath) {
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final path = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '$base$path';
  }

  Widget _buildAttachmentSection(task) {
    final List<String> originalImages = (task.attachments as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList()
            .cast<String>() ??
        [];
    final List<String> submittedImages = (task.submitedDoc as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList()
            .cast<String>() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (originalImages.isNotEmpty) ...[
          _imageListSection(title: 'Attachment', imagePaths: originalImages),
          SizedBox(height: 12.h),
        ],
        if (task.isSubmited == true) ...[
          _imageListSection(
            title: 'Submitted Documents',
            imagePaths: submittedImages,
          ),
        ] else if (originalImages.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.r)),
              child: Center(
                child: Text('No attachments',
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _imageListSection(
      {required String title, required List<String> imagePaths}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
          SizedBox(height: 12.h),
          if (imagePaths.isEmpty)
            Container(
              height: 80.h,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.r)),
              child: Center(
                child: Text('No images',
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
              ),
            )
          else
            SizedBox(
              height: 110.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  final imageUrl =
                      _buildImageUrl(ApiConstants.imageBaseUrl, imagePaths[index]);
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.black,
                          insetPadding: EdgeInsets.all(12.w),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.white54, size: 48.sp),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 110.w,
                      height: 110.h,
                      margin: EdgeInsets.only(right: 10.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.grey[300]!),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: primaryBlue,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image_outlined,
                                    color: Colors.grey[400], size: 28.sp),
                                SizedBox(height: 4.h),
                                Text('No Image',
                                    style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey[500])),
                              ],
                            );
                          },
                        ),
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

  Widget _buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], fontWeight: FontWeight.w500)),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(value, style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildServiceItem(String service, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(service, style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
        Text(price, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }

  Widget _buildDateField(String label, String? dateString) {
    String displayDate = 'N/A';
    if (dateString != null && dateString.isNotEmpty) {
      try {
        displayDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(dateString).toLocal());
      } catch (e) {
        displayDate = dateString;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], fontWeight: FontWeight.w500)),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(child: Text(displayDate, style: TextStyle(fontSize: 14.sp, color: Colors.black87))),
              Icon(Icons.calendar_today, size: 18.sp, color: Colors.grey[600]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, String? dateString) {
    String displayTime = 'N/A';
    if (dateString != null && dateString.isNotEmpty) {
      try {
        displayTime = DateFormat('hh:mm a').format(DateTime.parse(dateString).toLocal());
      } catch (e) {
        displayTime = '09:00 AM';
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], fontWeight: FontWeight.w500)),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(child: Text(displayTime, style: TextStyle(fontSize: 14.sp, color: Colors.black87))),
              Icon(Icons.access_time, size: 18.sp, color: Colors.grey[600]),
            ],
          ),
        ),
      ],
    );
  }

  void _acceptTask(task) async {
    setState(() => _isAccepting = true);
    final success = await controller.acceptTask(widget.taskId);
    if (!mounted) return;
    setState(() => _isAccepting = false);
    if (success) {
      Navigator.pop(context);
    }
  }

  void _goToTaskScreen(task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskScreen(
          taskId: widget.taskId,
          taskData: {
            'customerName': task.customerName,
            'customerNumber': task.customerNumber,
            'customerAddress': task.customerAddress,
            'customerEmail': task.customerEmail,
            'serviceCategory': task.serviceCategory,
            'totalAmount': task.totalAmount,
            'otherAmount': task.otherAmount,
            'priority': task.priority,
            'difficulty': task.difficulty,
            'notes': task.notes,
            "service": (task.service as List?)
                    ?.map((s) => {
                          'name': s.name ?? '',
                          'price': (s.price ?? 0).toDouble(),
                          'quantity': (s.quantity ?? 1).toString(),
                        })
                    .toList() ??
                [],
            "totalPrice": task.totalAmount,
          },
        ),
      ),
    );
  }
}