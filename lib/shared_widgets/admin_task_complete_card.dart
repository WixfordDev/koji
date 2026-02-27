import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../constants/app_color.dart';
import '../../../../models/admin-model/task_details_model.dart';
import '../../../../shared_widgets/custom_text.dart';

class AdminTaskCompleteCard extends StatelessWidget {
  final TaskDetailsModel? taskDetails;

  const AdminTaskCompleteCard({
    super.key,
    this.taskDetails,
  });

  // Helper method to get status color
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

  // Helper method to get status text
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

  // Helper method to get priority color
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

  // Helper method to get difficulty color
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

  // Helper method to format time
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';

    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period';
  }

  // Get assignee name
  String _getAssigneeName() {
    if (taskDetails?.assignTo == null) return 'N/A';

    if (taskDetails!.assignTo is AssignTo) {
      return (taskDetails!.assignTo as AssignTo).fullName ?? 'N/A';
    } else if (taskDetails!.assignTo is String) {
      return taskDetails!.assignTo as String;
    } else if (taskDetails!.assignTo is List) {
      final assignToList = taskDetails!.assignTo as List;
      if (assignToList.isEmpty) return 'N/A';

      // Properly extract names from list items
      final names = assignToList.map((item) {
        if (item is AssignTo) {
          return item.fullName ?? 'N/A';
        } else if (item is Map<String, dynamic>) {
          return item['fullName'] ?? 'N/A';
        } else if (item is String) {
          return item;
        }
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

    // Format date
    String formattedDate = taskDetails?.assignDate != null
        ? DateFormat('dd-MM-yyyy').format(taskDetails!.assignDate!)
        : 'N/A';

    // Get service category name
    String categoryName = taskDetails?.serviceCategory?.name ?? 'N/A';

    // Get service list
    List<Service> services = taskDetails?.services ?? [];
    String serviceList = services.map((s) => s.name ?? 'N/A').join('\n');

    // Get department/title
    String departmentName = taskDetails?.department?.name ?? 'Handy Man Staff';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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

          // Department/Title
          Text(
            departmentName,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 12.h),

          // Info Rows
          _buildInfoRow('Category:', categoryName),
          if (services.isNotEmpty)
            _buildInfoRow('Service List:', serviceList, isMultiline: true),
          _buildInfoRow('Customer Name:', taskDetails?.customerName ?? 'N/A'),
          _buildInfoRow('Customer Number:', taskDetails?.customerNumber ?? 'N/A'),
          _buildInfoRow('Customer Address:', taskDetails?.customerAddress ?? 'N/A'),
          _buildInfoRow('Assign To:', _getAssigneeName()),

          // Time row
          if (taskDetails?.assignDate != null)
            _buildInfoRow(
              'Time:',
              '${_formatTime(taskDetails?.assignDate)} - ${_formatTime(taskDetails?.deadline)}',
            ),

          // Priority with colored text
          Padding(
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

          // Difficulty with colored text
          Padding(
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

          // Invoice and Amount if available
          if (taskDetails?.invoicePath != null && taskDetails!.invoicePath!.isNotEmpty)
            _buildInfoRow('Invoice No.:', taskDetails?.invoicePath ?? 'N/A'),

          if (taskDetails?.totalAmount != null)
            _buildInfoRow('Amount:', '৳${taskDetails?.totalAmount}'),

          SizedBox(height: 12.h),

          // Proof of Work Label and Images with Status Row
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
              // Proof of Work Images
              if (taskDetails?.submitedDoc != null && taskDetails!.submitedDoc!.isNotEmpty)
                Expanded(
                  child: Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: taskDetails!.submitedDoc!.take(3).map((doc) {
                      String imageUrl = '';
                      if (doc is String) {
                        imageUrl = doc;
                      } else if (doc is Map) {
                        imageUrl = doc['url'] ?? doc['path'] ?? '';
                      }

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
                              child: Icon(
                                Icons.image,
                                size: 24.sp,
                                color: const Color(0xFF667085),
                              ),
                            );
                          },
                        )
                            : Container(
                          width: 50.w,
                          height: 50.h,
                          color: const Color(0xFFEAECF0),
                          child: Icon(
                            Icons.image,
                            size: 24.sp,
                            color: const Color(0xFF667085),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              else
              // If no images, just show empty space
                const Expanded(child: SizedBox()),

              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(taskDetails?.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100.r),
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
                        color: _getStatusColor(taskDetails?.status),
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

  Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF667085),
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
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
}