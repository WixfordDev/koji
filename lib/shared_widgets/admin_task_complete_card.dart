import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_color.dart';
import '../models/admin-model/task_details_model.dart';
import '../services/api_constants.dart';
import '../shared_widgets/custom_text.dart';

class AdminTaskCompleteCard extends StatelessWidget {
  final TaskDetailsModel? taskDetails;

  const AdminTaskCompleteCard({
    super.key,
    this.taskDetails,
  });

  Color _getStatusColor(String? status) {
    final statusLower = status?.toLowerCase() ?? '';
    if (statusLower.contains('submit') || statusLower.contains('complete')) {
      return const Color(0xFF12B76A);
    } else if (statusLower.contains('progress')) {
      return const Color(0xFFF79009);
    } else if (statusLower.contains('pending')) {
      return const Color(0xFFF04438);
    }
    return Colors.grey;
  }

  String _getStatusText(String? status) {
    final statusLower = status?.toLowerCase() ?? '';
    if (statusLower.contains('submit') || statusLower.contains('complete')) {
      return 'Completed';
    } else if (statusLower.contains('progress')) {
      return 'In Progress';
    } else if (statusLower.contains('pending')) {
      return 'Pending';
    }
    return status ?? 'N/A';
  }

  Color _getPriorityColor(String? priority) {
    final priorityLower = priority?.toLowerCase() ?? '';
    if (priorityLower == 'high' || priorityLower == 'important') {
      return const Color(0xFFF04438);
    } else if (priorityLower == 'medium') {
      return const Color(0xFFF79009);
    } else if (priorityLower == 'low') {
      return const Color(0xFF12B76A);
    }
    return Colors.grey;
  }

  Color _getDifficultyColor(String? difficulty) {
    final difficultyLower = difficulty?.toLowerCase() ?? '';
    if (difficultyLower == 'hard') {
      return const Color(0xFFF04438);
    } else if (difficultyLower == 'medium') {
      return const Color(0xFFF79009);
    } else if (difficultyLower == 'easy') {
      return const Color(0xFF12B76A);
    }
    return Colors.grey;
  }

  Color _getStatusBorderColor(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s.contains('submit') || s.contains('complete')) return Colors.green.shade200;
    if (s.contains('progress')) return Colors.orange.shade200;
    return Colors.orange.shade200;
  }

  Color _getStatusLightColor(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s.contains('submit') || s.contains('complete')) return Colors.green.shade50;
    if (s.contains('progress')) return Colors.orange.shade50;
    return Colors.orange.shade50;
  }

  Color _getStatusDarkColor(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s.contains('submit') || s.contains('complete')) return Colors.green.shade700;
    if (s.contains('progress')) return Colors.orange.shade700;
    return Colors.orange.shade700;
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _getAssigneeName() {
    if (taskDetails?.assignTo == null) return 'N/A';
    if (taskDetails!.assignTo is AssignTo) {
      return (taskDetails!.assignTo as AssignTo).fullName ?? 'N/A';
    } else if (taskDetails!.assignTo is String) {
      return taskDetails!.assignTo as String;
    } else if (taskDetails!.assignTo is List) {
      final assignToList = taskDetails!.assignTo as List;
      if (assignToList.isEmpty) return 'N/A';
      final names = assignToList.map((item) {
        if (item is AssignTo) return item.fullName ?? 'N/A';
        if (item is Map<String, dynamic>) return item['fullName'] ?? 'N/A';
        if (item is String) return item;
        return 'N/A';
      }).toList();
      return names.join(', ');
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    if (taskDetails == null) {
      return const SizedBox.shrink();
    }

    String formattedDate = taskDetails?.assignDate != null
        ? DateFormat('dd-MM-yyyy').format(taskDetails!.assignDate!)
        : 'N/A';

    String categoryName = taskDetails?.serviceCategory?.name ?? 'N/A';

    List<Service> services = taskDetails?.services ?? [];

    String departmentName = taskDetails?.department?.name ?? 'Handy Man Staff';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _getStatusBorderColor(taskDetails?.status), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Badge - Centered
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Text(
                formattedDate,
                style: TextStyle(
                  color: const Color(0xFF0284C7),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Customer Name + Department
          Text(
            taskDetails?.customerName ?? 'N/A',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 2.h),

          Text(
            departmentName,
            style: TextStyle(
              color: const Color(0xFF667085),
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
          ),

          SizedBox(height: 12.h),

          // Info Rows
          _buildInfoRow('Category:', categoryName),
          if (services.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service List:',
                    style: TextStyle(
                      color: const Color(0xFF667085),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  ...services.asMap().entries.map((e) => Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Text(
                          '${e.key + 1}. ${e.value.name ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )),
                ],
              ),
            ),

          // Customer Number — clickable (call)
          _buildClickableInfoRow(
            'Customer Number:',
            taskDetails?.customerNumber ?? 'N/A',
            icon: Icons.phone,
            onTap: () async {
              final number = taskDetails?.customerNumber ?? '';
              if (number.isNotEmpty && number != 'N/A') {
                final uri = Uri(scheme: 'tel', path: number);
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              }
            },
          ),

          // Customer Address — clickable (map)
          _buildClickableInfoRow(
            'Customer Address:',
            taskDetails?.customerAddress ?? 'N/A',
            icon: Icons.location_on,
            onTap: () async {
              final address = taskDetails?.customerAddress ?? '';
              if (address.isNotEmpty && address != 'N/A') {
                final encoded = Uri.encodeComponent(address);
                final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
          ),

          // Post Code — clickable (map)
          if (taskDetails?.postCode != null && taskDetails!.postCode!.isNotEmpty)
            _buildClickableInfoRow(
              'Post Code:',
              taskDetails!.postCode!,
              icon: Icons.pin_drop_outlined,
              onTap: () async {
                final encoded = Uri.encodeComponent(taskDetails!.postCode!);
                final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),

          _buildInfoRow('Assign To:', _getAssigneeName()),

          if (taskDetails?.assignDate != null)
            _buildInfoRow(
              'Time:',
              '${_formatTime(taskDetails?.assignDate)} - ${_formatTime(taskDetails?.deadline)}',
            ),

          // Priority (hidden)
          Visibility(
            visible: false,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120.w,
                    child: Text(
                      'Priority:',
                      style: TextStyle(
                        color: const Color(0xFF667085),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      taskDetails?.priority ?? 'N/A',
                      style: TextStyle(
                        color: _getPriorityColor(taskDetails?.priority),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Difficulty (hidden)
          Visibility(
            visible: false,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120.w,
                    child: Text(
                      'Difficulty:',
                      style: TextStyle(
                        color: const Color(0xFF667085),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      taskDetails?.difficulty ?? 'N/A',
                      style: TextStyle(
                        color: _getDifficultyColor(taskDetails?.difficulty),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (taskDetails?.invoicePath != null && taskDetails!.invoicePath!.isNotEmpty)
            _buildInfoRow('Invoice No.:', _extractInvoiceNo(taskDetails!.invoicePath!)),

          if (taskDetails?.totalAmount != null)
            _buildInfoRow('Amount:', '\$${taskDetails?.totalAmount}'),

          SizedBox(height: 12.h),

          if (taskDetails?.submitedDoc != null && taskDetails!.submitedDoc!.isNotEmpty) ...[
            Text(
              'PROOF OF WORK',
              style: TextStyle(
                color: const Color(0xFF667085),
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8.h),
          ],

          // Images and Status Row
          Row(
            children: [
              if (taskDetails?.submitedDoc != null && taskDetails!.submitedDoc!.isNotEmpty)
                Expanded(
                  child: Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: taskDetails!.submitedDoc!.take(3).map((doc) {
                      String rawPath = '';
                      if (doc is String) {
                        rawPath = doc;
                      } else if (doc is Map) {
                        rawPath = doc['url'] ?? doc['path'] ?? '';
                      }
                      final imageUrl = rawPath.startsWith('http')
                          ? rawPath
                          : '${ApiConstants.imageBaseUrl}/${rawPath.startsWith('/') ? rawPath.substring(1) : rawPath}';

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 50.w,
                                height: 50.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50.w,
                                    height: 50.h,
                                    color: const Color(0xFFEAECF0),
                                    child: Icon(Icons.image, size: 24.sp, color: const Color(0xFF667085)),
                                  );
                                },
                              )
                            : Container(
                                width: 50.w,
                                height: 50.h,
                                color: const Color(0xFFEAECF0),
                                child: Icon(Icons.image, size: 24.sp, color: const Color(0xFF667085)),
                              ),
                      );
                    }).toList(),
                  ),
                )
              else
                const Expanded(child: SizedBox()),

              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusLightColor(taskDetails?.status),
                  borderRadius: BorderRadius.circular(100.r),
                  border: Border.all(color: _getStatusBorderColor(taskDetails?.status), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: _getStatusColor(taskDetails?.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _getStatusText(taskDetails?.status),
                      style: TextStyle(
                        color: _getStatusDarkColor(taskDetails?.status),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _extractInvoiceNo(String path) {
    final fileName = path.split('/').last;
    final withoutExt = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    final parts = withoutExt.split('-');
    if (parts.length >= 3) {
      return 'INV-${parts.sublist(1, parts.length - 1).join('-')}';
    }
    return withoutExt;
  }

  Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: TextStyle(
              color: const Color(0xFF667085),
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
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

  Widget _buildClickableInfoRow(String label, String value, {required IconData icon, required VoidCallback onTap}) {
    final isEmpty = value.isEmpty || value == 'N/A';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: TextStyle(
              color: const Color(0xFF667085),
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: isEmpty
                ? Text(
                    'N/A',
                    style: TextStyle(color: Colors.black, fontSize: 13.sp, fontWeight: FontWeight.w500),
                  )
                : GestureDetector(
                    onTap: onTap,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(icon, size: 14.sp, color: const Color(0xFF007AFF)),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            value,
                            style: TextStyle(
                              color: const Color(0xFF007AFF),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFF007AFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
