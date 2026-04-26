import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/models/task_report_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/app_color.dart';
import '../../../controller/task_report_controller.dart';
import '../../../services/api_constants.dart';
import '../../../shared_widgets/custom_text.dart';
import '../../../shared_widgets/task_report_card_widget.dart';

class TaskReportScreen extends StatefulWidget {
  final String? taskId;

  const TaskReportScreen({Key? key, this.taskId}) : super(key: key);

  @override
  State<TaskReportScreen> createState() => _TaskReportScreenState();
}

class _TaskReportScreenState extends State<TaskReportScreen> {
  late TaskReportController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TaskReportController());

    // Only fetch the task report if a taskId is provided
    if (widget.taskId != null && widget.taskId!.isNotEmpty) {
      controller.fetchTaskReport(widget.taskId!);
    }
  }

  void _showSnack(String msg, {Color color = Colors.orange}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _downloadReport(String? path) async {
    if (path == null || path.isEmpty) {
      _showSnack('Task report PDF has not been generated yet.');
      return;
    }
    String fullUrl;
    if (path.startsWith('http')) {
      fullUrl = path;
    } else {
      final base = ApiConstants.imageBaseUrl.endsWith('/')
          ? ApiConstants.imageBaseUrl
          : '${ApiConstants.imageBaseUrl}/';
      final cleanPath = path.startsWith('/') ? path.substring(1) : path;
      fullUrl = '$base$cleanPath';
    }
    final uri = Uri.tryParse(fullUrl);
    if (uri == null) {
      _showSnack('Invalid report link.', color: Colors.red);
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e) {
        _showSnack('Cannot open the report: $e', color: Colors.red);
      }
    }
  }

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
            CustomText(
              text: "Task Report",
              color: AppColor.secondaryColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.error.isNotEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          "Error loading task report",
                          style: TextStyle(fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () => controller.fetchTaskReport(
                            widget.taskId.toString(),
                          ),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                final taskReport = controller.taskReport.value;
                if (taskReport == null) {
                  return const Center(child: Text("No task report found"));
                }

                return _buildTaskReportCard(taskReport);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskReportCard(TaskReportAttributes taskReport) {
    return Container(
      width: 370.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color:
                    taskReport.status.toLowerCase().contains('completed') ||
                        taskReport.status.toLowerCase().contains('done') ||
                        taskReport.isSubmited
                    ? const Color(0xFFE8F9EE) // Green for completed
                    : const Color(0xFFFFF3E0), // Orange for pending
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                taskReport.isSubmited
                    ? "Submitted on ${_formatDate(taskReport.updatedAt ?? taskReport.createdAt)}"
                    : "Task is in progress",
                style: TextStyle(
                  color:
                      taskReport.status.toLowerCase().contains('completed') ||
                          taskReport.status.toLowerCase().contains('done') ||
                          taskReport.isSubmited
                      ? const Color(0xFF249E58)
                      : const Color(0xFFFF9800),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: taskReport.serviceCategory.name,
            color: AppColor.secondaryColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 10.h),
          _buildRow("Service:", taskReport.serviceCategory.name),
          _buildRow("Service List:", _formatServices(taskReport.services)),
          _buildRow("Customer Name:", taskReport.customerName),
          _buildRow("Customer Number:", taskReport.customerNumber),
          _buildRow("Customer Address:", taskReport.customerAddress),
          _buildRow("Assign To:", taskReport.assignTo.fullName),
          _buildRow("Assign Date:", _formatDate(taskReport.assignDate)),
          _buildRow("Time:", _formatTime(taskReport.assignDate)),
          _buildRow("Deadline:", _formatDate(taskReport.deadline)),
          _buildRow(
            "Invoice No.:",
            taskReport.invoicePath != null ? taskReport.invoicePath! : "N/A",
          ),
          _buildRow(
            "Total Amount:",
            "\$${taskReport.totalAmount.toString()}",
          ),
          _buildRow("Status:", taskReport.status),
          _buildRow("Payment Status:", taskReport.paymentStatus),
          SizedBox(height: 8.h),
          Row(
            children: [
              // Display submitted documents if available
              if (taskReport.submitedDoc.isNotEmpty)
                ...taskReport.submitedDoc
                    .take(3)
                    .map(
                      (doc) => Padding(
                        padding: EdgeInsets.only(right: 6.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.asset(
                            'assets/images/task.png', // Placeholder image
                            width: 40.w,
                            height: 40.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
              else
                // Display attachments if no submitted documents
                ...taskReport.attachments
                    .take(3)
                    .map(
                      (doc) => Padding(
                        padding: EdgeInsets.only(right: 6.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.asset(
                            'assets/images/task.png', // Placeholder image
                            width: 40.w,
                            height: 40.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color:
                      taskReport.status.toLowerCase().contains('completed') ||
                          taskReport.status.toLowerCase().contains('done') ||
                          taskReport.isSubmited
                      ? const Color(0xFFE8F9EE) // Green for completed
                      : const Color(0xFFFFF3E0), // Orange for pending
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  taskReport.isSubmited ? "● Submitted" : "● Pending",
                  style: TextStyle(
                    color:
                        taskReport.status.toLowerCase().contains('completed') ||
                            taskReport.status.toLowerCase().contains('done') ||
                            taskReport.isSubmited
                        ? const Color(0xFF249E58) // Green
                        : const Color(0xFFFF9800), // Orange
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatServices(List<Service> services) {
    if (services.isEmpty) return "No services";
    return services
        .map((service) => "${service.name} (x${service.quantity})")
        .join("\n");
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      final hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;
      return '$displayHour:$minute $period';
    } catch (e) {
      return '-';
    }
  }
}
