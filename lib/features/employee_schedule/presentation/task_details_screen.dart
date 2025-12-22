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

  @override
  void initState() {
    super.initState();
    controller = Get.put(EmployeeScheduleController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTaskById(widget.taskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp, color: Colors.black),
          onPressed: () => Get.back(),
        ),
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
                // Attachment Section with grey background
                /// Attachments Section
                _buildAttachmentSection(task),

                SizedBox(height: 24.h),

                /// Department Field
                _buildTextField('Department', task.department?.name ?? 'N/A'),

                SizedBox(height: 12.h),

                /// Service Category Field
                _buildTextField(
                  'Service Category',
                  task.serviceCategory?.name ?? 'N/A',
                ),

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
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: task.service?.length ?? 0,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 8.h),
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

                      _buildServiceItem(
                        'Others Amount',
                        '\$${task.otherAmount?.toStringAsFixed(1) ?? '0.0'}',
                      ),
                      SizedBox(height: 8.h),
                      _buildServiceItem('GST 9%', ''),

                      Divider(height: 24.h, color: Colors.grey[300]),

                      // Total Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Price',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '\$${task.totalAmount?.toStringAsFixed(1) ?? '0.0'}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A90E2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                /// Customer Name Field
                _buildTextField('Customer Name', task.customerName ?? 'N/A'),

                SizedBox(height: 12.h),

                /// Customer Number Field
                _buildTextField(
                  'Customer Number',
                  task.customerNumber ?? 'N/A',
                ),

                SizedBox(height: 12.h),

                /// Customer Address Field
                _buildTextField(
                  'Customer Address',
                  task.customerAddress ?? 'N/A',
                ),

                SizedBox(height: 12.h),

                /// Assign To Field
                _buildTextField('Assign To', task.assignTo ?? 'N/A'),

                SizedBox(height: 12.h),

                /// IMEI Field
                _buildTextField('IMEI', task.id ?? 'N/A'),

                SizedBox(height: 12.h),

                Row(
                  children: [
                    /// Assign Date Field
                    Expanded(
                      flex: 1,
                      child: _buildDateField(
                        'Assign Date',
                        task.assignDate.toString(),
                      ),
                    ),

                    SizedBox(width: 12.h),

                    /// Assign Time (You can extract time from assignDate if available)
                    Expanded(
                      flex: 1,
                      child: _buildTimeField(
                        'Assign Time',
                        task.assignDate?.toIso8601String(),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                Row(
                  children: [
                    /// Assign Date Field
                    Expanded(
                      flex: 1,
                      child: _buildDateField(
                        'End Date',
                        task.deadline.toString(),
                      ),
                    ),

                    SizedBox(width: 12.h),

                    /// Assign Time (You can extract time from assignDate if available)
                    Expanded(
                      flex: 1,
                      child: _buildTimeField(
                        'End Time',
                        task.deadline.toString(),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                /// Priority Field
                _buildTextField('Priority', task.priority ?? 'N/A'),

                SizedBox(height: 12.h),

                /// Difficulty Field
                _buildTextField('Difficulty', task.difficulty ?? 'N/A'),

                SizedBox(height: 24.h),

                // Accept Button
                if (task.isSubmited != true &&
                    task.status?.toLowerCase() == 'pending')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _acceptTask(task),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A90E2),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Accept',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: 12.h),

                // If already accepted, show "Go to Task Screen" button
                if (task.isSubmited != true &&
                    task.status?.toLowerCase() != 'pending')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _goToTaskScreen(task),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Go to Task Screen',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // If already submitted
                if (task.isSubmited == true)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Task Already Submitted',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
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

  Widget _buildAttachmentSection(task) {
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
          Text(
            'Attachment',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          // SizedBox(height: 4.h),
          // Text(
          //   'Format should be in .pdf, .jpeg, .png, less than 5MB',
          //   style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
          // ),
          SizedBox(height: 12.h),
          if (task.attachments != null && task.attachments!.isNotEmpty)
            SizedBox(
              height: 100.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: task.attachments!.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100.w,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        "${ApiConstants.imageBaseUrl}${task.attachments![index]}",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.image, color: Colors.grey[400]),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  'No attachments',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                ),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(String title, String value, {IconData? icon}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20.sp, color: Colors.grey[600]),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String service, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          service,
          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
        ),
        Text(
          price,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAssignItem(String text) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8.sp, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownCard(String title, String value, List<String> options) {
    return Container(
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
            title,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, String? dateString) {
    String displayDate = 'N/A';
    if (dateString != null && dateString.isNotEmpty) {
      try {
        final date = DateTime.parse(dateString);
        displayDate = DateFormat('dd-MM-yyyy').format(date);
      } catch (e) {
        displayDate = dateString;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
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
              Expanded(
                child: Text(
                  displayDate,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                ),
              ),
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
        final date = DateTime.parse(dateString);
        displayTime = DateFormat('hh:mm a').format(date);
      } catch (e) {
        displayTime = '09:00 AM';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
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
              Expanded(
                child: Text(
                  displayTime,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                ),
              ),
              Icon(Icons.access_time, size: 18.sp, color: Colors.grey[600]),
            ],
          ),
        ),
      ],
    );
  }

  void _acceptTask(task) async {
    // Call the accept task API
    await controller.acceptTask(widget.taskId);

    // Show success message
    Get.snackbar(
      'Success',
      'Task accepted successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Navigate to Task Screen
    _goToTaskScreen(task);
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
            "service": task.service ?? {},
            "totalPrice": task.totalAmount,
          },
        ),
      ),
    );
  }
}
