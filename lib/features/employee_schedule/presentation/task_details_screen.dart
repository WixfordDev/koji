import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:koji/controller/employee_schedule_controller.dart';
import 'package:koji/models/admin-model/get_alllist_task_model.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late final EmployeeScheduleController controller;
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    controller = Get.put(EmployeeScheduleController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTaskById(widget.taskId);
    });
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
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
                /// Attachments Section
                _buildAttachmentSection(task),

                SizedBox(height: 16.h),

                /// Department Field
                _buildTextField('Department', task.department ?? 'N/A'),

                SizedBox(height: 12.h),

                /// Handy Man Field
                _buildTextField('Handy Man', task.assignTo ?? 'N/A'),

                SizedBox(height: 12.h),

                /// Service Category Field
                _buildTextField(
                  'Service Category',
                  task.serviceCategory ?? 'N/A',
                ),

                SizedBox(height: 12.h),

                /// Service List
                // _buildServiceListSection(task.services ?? []),
                SizedBox(height: 12.h),

                /// GST Field
                _buildPriceField('GST 9%', task.otherAmount ?? 0),

                SizedBox(height: 12.h),

                /// Total Price Field
                _buildPriceField('Total Price', task.totalAmount ?? 0),

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

                /// Assign Date Field
                _buildDateField('Assign Date', task.assignDate),

                SizedBox(height: 12.h),

                /// Assign Time (You can extract time from assignDate if available)
                _buildTimeField('Assign Time', task.assignDate),

                SizedBox(height: 12.h),

                /// Priority Field
                _buildDropdownField('Priority', task.priority ?? 'N/A'),

                SizedBox(height: 12.h),

                /// Difficulty Field
                _buildDropdownField('Difficulty', task.difficulty ?? 'N/A'),

                SizedBox(height: 12.h),

                /// Payment Method Field
                _buildDropdownField(
                  'Payment Method',
                  task.paymentMethod ?? 'N/A',
                ),

                SizedBox(height: 12.h),

                /// Payment Status Field
                _buildDropdownField(
                  'Payment Status',
                  task.paymentStatus ?? 'N/A',
                ),

                SizedBox(height: 24.h),

                /// Action Buttons
                if (task.isSubmited != true) ...[
                  // Accept Button
                  if (task.status?.toLowerCase() == 'pending')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.acceptTask(widget.taskId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
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

                  // Submit Task Button
                  if (task.status?.toLowerCase() != 'pending')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            _showSubmitDialog(context, task.customerName),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Submit Task',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ] else
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
          SizedBox(height: 4.h),
          Text(
            'Format should be in .pdf, .jpeg, .png, less than 5MB',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 12.h),
          if (task.attachments != null && task.attachments!.isNotEmpty)
            SizedBox(
              height: 80.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: task.attachments!.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80.w,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        task.attachments![index],
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

  Widget _buildPriceField(String label, num amount) {
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
            '৳${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceListSection(List<Service> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service List',
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: services.isEmpty
                ? [
                    Text(
                      'No services',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ]
                : services
                      .map(
                        (service) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                service.name ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '\$${(service.price ?? 0).toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
          ),
        ),
      ],
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

  Widget _buildDropdownField(String label, String value) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 14.sp, color: Colors.black87),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            ],
          ),
        ),
      ],
    );
  }

  void _showSubmitDialog(BuildContext context, String? customerName) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Customer Signature',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20.h),

                // Signature Area with Image Picker
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImages.clear();
                        _selectedImages.add(File(image.path));
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 150.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.grey[50],
                    ),
                    child: _selectedImages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 40.sp,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Tap to add signature',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.file(
                              _selectedImages[0],
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _showSuccessDialog(context);
                      // Call the submit API here
                      // controller.submitTask(
                      //   widget.taskId,
                      //   attachments: _selectedImages,
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10.h),

                // Cancel Button
                TextButton(
                  onPressed: () {
                    _selectedImages.clear();
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'No, Let Me Check',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Animation Icon
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: const Color(0xFF4A90E2),
                  size: 50.sp,
                ),
              ),

              SizedBox(height: 20.h),

              Text(
                'Success',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 12.h),

              Text(
                'Your task has been submitted successfully.\nYou will be notified once it is reviewed by\nyour admin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close success dialog
                    Get.back(); // Go back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'View List',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:koji/controller/employee_schedule_controller.dart';
// import 'package:koji/models/admin-model/get_alllist_task_model.dart';

// class TaskDetailsScreen extends StatefulWidget {
//   final String taskId;

//   const TaskDetailsScreen({super.key, required this.taskId});

//   @override
//   State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
// }

// class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
//   late final EmployeeScheduleController controller;

//   @override
//   void initState() {
//     super.initState();
//     controller = Get.put(EmployeeScheduleController());
//     // Fetch task details when screen initializes
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.fetchTaskById(widget.taskId);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, size: 20.sp, color: Colors.black),
//           onPressed: () => Get.back(),
//         ),
//         title: Text(
//           'Task Details',
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final task = controller.selectedTask.value;

//         if (task == null) {
//           return Center(
//             child: Text(
//               'Failed to load task details',
//               style: TextStyle(fontSize: 16.sp, color: Colors.grey),
//             ),
//           );
//         }

//         return SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// Customer Info Card
//                 _buildInfoCard('Customer Information', [
//                   _buildInfoRow(
//                     Icons.person,
//                     'Name',
//                     task.customerName ?? 'N/A',
//                   ),
//                   _buildInfoRow(
//                     Icons.phone,
//                     'Phone',
//                     task.customerNumber ?? 'N/A',
//                   ),
//                   _buildInfoRow(
//                     Icons.location_on,
//                     'Address',
//                     task.customerAddress ?? 'N/A',
//                   ),
//                   if (task.customerEmail != null &&
//                       task.customerEmail!.isNotEmpty)
//                     _buildInfoRow(Icons.email, 'Email', task.customerEmail!),
//                 ]),

//                 SizedBox(height: 16.h),

//                 /// Task Info Card
//                 _buildInfoCard('Task Information', [
//                   // _buildInfoRow(
//                   //   Icons.calendar_today,
//                   //   'Assign Date',
//                   //   _formatDate(task.assignDate),
//                   // ),
//                   // _buildInfoRow(
//                   //   Icons.event,
//                   //   'Deadline',
//                   //   _formatDate(task.deadline),
//                   // ),
//                   _buildStatusRow('Status', task.status ?? 'N/A'),
//                   _buildInfoRow(Icons.flag, 'Priority', task.priority ?? 'N/A'),
//                   _buildInfoRow(
//                     Icons.speed,
//                     'Difficulty',
//                     task.difficulty ?? 'N/A',
//                   ),
//                 ]),

//                 SizedBox(height: 16.h),

//                 /// Services Card
//                 if (task.services != null && task.services!.isNotEmpty)
//                   //  _buildServicesCard(task.services!),
//                   SizedBox(height: 16.h),

//                 /// Payment Info Card
//                 _buildInfoCard('Payment Information', [
//                   _buildPriceRow(
//                     'Services Total',
//                     (task.totalAmount ?? 0) - (task.otherAmount ?? 0),
//                   ),
//                   _buildPriceRow('Other Amount', task.otherAmount ?? 0),
//                   Divider(height: 20.h),
//                   _buildPriceRow(
//                     'Total Amount',
//                     task.totalAmount ?? 0,
//                     isTotal: true,
//                   ),
//                   if (task.paymentMethod != null &&
//                       task.paymentMethod!.isNotEmpty)
//                     _buildInfoRow(
//                       Icons.payment,
//                       'Payment Method',
//                       task.paymentMethod!,
//                     ),
//                   if (task.paymentStatus != null &&
//                       task.paymentStatus!.isNotEmpty)
//                     _buildStatusRow('Payment Status', task.paymentStatus!),
//                 ]),

//                 SizedBox(height: 16.h),

//                 /// Notes Card
//                 if (task.notes != null && task.notes!.isNotEmpty)
//                   _buildInfoCard('Notes', [
//                     Text(
//                       task.notes!,
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         color: Colors.grey[700],
//                         height: 1.5,
//                       ),
//                     ),
//                   ]),

//                 SizedBox(height: 16.h),

//                 /// Attachments Card
//                 if (task.attachments != null && task.attachments!.isNotEmpty)
//                   //  _buildAttachmentsCard(task.attachments!),
//                   SizedBox(height: 24.h),

//                 /// Action Buttons
//                 if (task.isSubmited != true) ...[
//                   // Accept Button
//                   if (task.status?.toLowerCase() == 'pending')
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () => controller.acceptTask(widget.taskId),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           padding: EdgeInsets.symmetric(vertical: 14.h),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                           ),
//                         ),
//                         child: Text(
//                           'Accept Task',
//                           style: TextStyle(
//                             fontSize: 16.sp,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),

//                   SizedBox(height: 12.h),

//                   // Submit Task Button
//                   if (task.status?.toLowerCase() != 'pending')
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () => _showSubmitDialog(context),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           padding: EdgeInsets.symmetric(vertical: 14.h),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                           ),
//                         ),
//                         child: Text(
//                           'Submit Task',
//                           style: TextStyle(
//                             fontSize: 16.sp,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ] else
//                   Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.all(16.w),
//                     decoration: BoxDecoration(
//                       color: Colors.green.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12.r),
//                       border: Border.all(color: Colors.green),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.check_circle,
//                           color: Colors.green,
//                           size: 24.sp,
//                         ),
//                         SizedBox(width: 8.w),
//                         Text(
//                           'Task Already Submitted',
//                           style: TextStyle(
//                             fontSize: 16.sp,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.green,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 SizedBox(height: 24.h),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildInfoCard(String title, List<Widget> children) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w600,
//               color: Colors.black,
//             ),
//           ),
//           SizedBox(height: 12.h),
//           ...children,
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 12.h),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 20.sp, color: Colors.grey[600]),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
//                 ),
//                 SizedBox(height: 2.h),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusRow(String label, String status) {
//     Color statusColor = _getStatusColor(status);
//     return Padding(
//       padding: EdgeInsets.only(bottom: 12.h),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(20.r),
//             ),
//             child: Text(
//               status,
//               style: TextStyle(
//                 color: statusColor,
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPriceRow(String label, num amount, {bool isTotal = false}) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 8.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: isTotal ? 16.sp : 14.sp,
//               fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
//               color: Colors.black,
//             ),
//           ),
//           Text(
//             '৳${amount.toStringAsFixed(2)}',
//             style: TextStyle(
//               fontSize: isTotal ? 16.sp : 14.sp,
//               fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
//               color: isTotal ? Colors.blue : Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildServicesCard(List<Service> services) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Services',
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w600,
//               color: Colors.black,
//             ),
//           ),
//           SizedBox(height: 12.h),
//           ...services.map((service) => _buildServiceItem(service)).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildServiceItem(Service service) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 8.h),
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.blue.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(8.r),
//         border: Border.all(color: Colors.blue.withOpacity(0.2)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   service.name ?? 'N/A',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black,
//                   ),
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   'Qty: ${service.quantity ?? 0}',
//                   style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             '৳${((service.price ?? 0) * (service.quantity ?? 0)).toStringAsFixed(2)}',
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w600,
//               color: Colors.blue,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttachmentsCard(List<String> attachments) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Attachments',
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w600,
//               color: Colors.black,
//             ),
//           ),
//           SizedBox(height: 12.h),
//           Wrap(
//             spacing: 8.w,
//             runSpacing: 8.h,
//             children: attachments.map((attachment) {
//               return Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(8.r),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.attach_file,
//                       size: 16.sp,
//                       color: Colors.grey[700],
//                     ),
//                     SizedBox(width: 4.w),
//                     Text(
//                       attachment.split('/').last,
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSubmitDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.r),
//         ),
//         title: Text(
//           'Submit Task',
//           style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
//         ),
//         content: Text(
//           'Are you sure you want to submit this task? This action cannot be undone.',
//           style: TextStyle(fontSize: 14.sp),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               controller.submitTask(widget.taskId);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//             ),
//             child: const Text('Submit'),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return 'N/A';
//     try {
//       return DateFormat('dd MMM yyyy').format(date);
//     } catch (e) {
//       return 'N/A';
//     }
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'completed':
//       case 'complete':
//       case 'done':
//         return Colors.green;
//       case 'inprogress':
//       case 'in progress':
//         return Colors.blue;
//       case 'pending':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }
// }
