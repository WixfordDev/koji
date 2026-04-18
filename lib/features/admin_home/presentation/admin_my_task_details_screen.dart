import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koji/controller/admincontroller/task_details_controller.dart';
import 'package:koji/models/task_model.dart';
import 'package:koji/services/api_constants.dart';

class AdminMyTaskDetailsScreen extends StatefulWidget {
  final String taskId;

  const AdminMyTaskDetailsScreen({super.key, required this.taskId});

  @override
  State<AdminMyTaskDetailsScreen> createState() => _AdminMyTaskDetailsScreenState();
}

class _AdminMyTaskDetailsScreenState extends State<AdminMyTaskDetailsScreen> {
  late TaskDetailsController _controller;

  static const _gradientColors = [Color(0xffEC526A), Color(0xffF77F6E)];
  static const _darkBlue = Color(0xFF162238);
  static const _blue = Color(0xFF4082FB);

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      TaskDetailsController(taskId: widget.taskId),
      tag: widget.taskId,
    );
  }

  @override
  void dispose() {
    Get.delete<TaskDetailsController>(tag: widget.taskId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 22.sp),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 4.w),
            Text(
              'Task Details',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          Obx(() {
            final task = _controller.taskDetails.value;
            if (task == null) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: _statusChip(_effectiveStatus(task)),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final task = _controller.taskDetails.value;
        if (task == null) {
          return Center(
            child: Text('Failed to load task', style: TextStyle(color: Colors.grey, fontSize: 15.sp)),
          );
        }
        return _buildBody(task);
      }),
    );
  }

  Widget _buildBody(TaskModel task) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(task),
          SizedBox(height: 16.h),
          _buildInfoCard(task),
          SizedBox(height: 16.h),
          _buildServicesCard(task),
          if (task.attachments != null && task.attachments!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildAttachmentsCard(task.attachments!, 'Attachments'),
          ],
          if (task.isSubmited == true &&
              task.submitedDoc != null &&
              task.submitedDoc!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildAttachmentsCard(
              task.submitedDoc!.map((e) => e.toString()).toList(),
              'Submitted Documents',
            ),
          ],
          if (task.notes != null && task.notes!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildNotesCard(task.notes!),
          ],
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // ─── Header Card ────────────────────────────────────────────────────────────
  Widget _buildHeaderCard(TaskModel task) {
    final progress = (task.progressPercent ?? 0) / 100.0;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: _gradientColors),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flash_on, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.customerName ?? 'N/A',
                      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                    if (task.customerNumber != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        task.customerNumber!,
                        style: TextStyle(fontSize: 13.sp, color: const Color(0xff6B7280)),
                      ),
                    ],
                  ],
                ),
              ),
              _priorityChip(task.priority ?? 'medium'),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6.h,
                    backgroundColor: Colors.black12,
                    valueColor: const AlwaysStoppedAnimation(Color(0xffEC526A)),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xffEC526A)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Info Card ──────────────────────────────────────────────────────────────
  Widget _buildInfoCard(TaskModel task) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _infoRow(Icons.location_on_outlined, 'Address', task.customerAddress ?? 'N/A'),
          _divider(),
          _infoRow(Icons.email_outlined, 'Email', task.customerEmail ?? 'N/A'),
          _divider(),
          _infoRow(Icons.business_outlined, 'Department', task.department?.name ?? 'N/A'),
          _divider(),
          _infoRow(Icons.category_outlined, 'Service Category', task.serviceCategory?.name ?? 'N/A'),
          _divider(),
          _infoRow(Icons.directions_car_outlined, 'Vehicle', task.vehicle ?? 'N/A'),
          _divider(),
          _infoRow(
            Icons.calendar_today_outlined,
            'Assign Date',
            task.assignDate != null ? DateFormat('dd MMM yyyy, hh:mm a').format(task.assignDate!) : 'N/A',
          ),
          _divider(),
          _infoRow(
            Icons.event_outlined,
            'Deadline',
            task.deadline != null ? DateFormat('dd MMM yyyy, hh:mm a').format(task.deadline!) : 'N/A',
          ),
          _divider(),
          _infoRow(Icons.person_outline, 'Assigned To',
              task.assignTo?.isNotEmpty == true ? task.assignTo!.join(', ') : 'N/A'),
          _divider(),
          _infoRow(Icons.payment_outlined, 'Payment', task.notes != null ? 'N/A' : 'N/A'),
          _divider(),
          _infoRow(
            Icons.attach_money_outlined,
            'Total Amount',
            task.totalAmount != null ? '\$${task.totalAmount}' : 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: const Color(0xff6B7280)),
          SizedBox(width: 10.w),
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(fontSize: 13.sp, color: const Color(0xff6B7280))),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black87),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade100);

  // ─── Services Card ──────────────────────────────────────────────────────────
  Widget _buildServicesCard(TaskModel task) {
    final services = task.services ?? [];
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Services', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 12.h),
          if (services.isEmpty)
            Text('No services', style: TextStyle(fontSize: 13.sp, color: Colors.grey))
          else
            ...services.map((s) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${s.name ?? 'N/A'} × ${s.quantity ?? 1}',
                          style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                        ),
                      ),
                      Text(
                        '\$${((s.price ?? 0) * (s.quantity ?? 1)).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                    ],
                  ),
                )),
          if (services.isNotEmpty) ...[
            Divider(color: Colors.grey.shade200),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                ShaderMask(
                  shaderCallback: (b) =>
                      const LinearGradient(colors: [_darkBlue, _blue]).createShader(b),
                  child: Text(
                    '\$${task.totalAmount ?? 0}',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Attachments Card ───────────────────────────────────────────────────────
  Widget _buildAttachmentsCard(List<String> paths, String title) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 12.h),
          SizedBox(
            height: 110.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: paths.length,
              itemBuilder: (context, i) {
                final url = _buildUrl(paths[i]);
                return GestureDetector(
                  onTap: () => _showFullImage(context, url),
                  child: Container(
                    width: 110.w,
                    height: 110.h,
                    margin: EdgeInsets.only(right: 10.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.grey.shade100,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_outlined, color: Colors.grey.shade400, size: 28.sp),
                            Text('No Image', style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500)),
                          ],
                        ),
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

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(12.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.network(url, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 48.sp))),
        ),
      ),
    );
  }

  // ─── Notes Card ─────────────────────────────────────────────────────────────
  Widget _buildNotesCard(String notes) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notes', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 8.h),
          Text(notes, style: TextStyle(fontSize: 13.sp, color: const Color(0xff6B7280), height: 1.5)),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  String _buildUrl(String path) {
    if (path.startsWith('http')) return path;
    final base = ApiConstants.imageBaseUrl.endsWith('/')
        ? ApiConstants.imageBaseUrl
        : '${ApiConstants.imageBaseUrl}/';
    return '$base${path.startsWith('/') ? path.substring(1) : path}';
  }

  String _effectiveStatus(TaskModel task) {
    final s = task.status?.toLowerCase() ?? '';
    if (s == 'complete' || s == 'completed' || s == 'done') return 'Completed';
    if (s == 'inprogress' || s == 'progress' || s == 'in progress') return 'In Progress';
    if (s == 'submited' || s == 'submitted') return 'Submitted';
    if (s == 'approved') return 'Approved';
    if (s == 'rejected') return 'Rejected';
    return s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : 'Pending';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'submitted':
        return const Color(0xff6B7280);
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(status, style: TextStyle(fontSize: 12.sp, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _priorityChip(String priority) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 11.sp, color: Colors.red),
          SizedBox(width: 3.w),
          Text(
            priority[0].toUpperCase() + priority.substring(1),
            style: TextStyle(fontSize: 11.sp, color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
