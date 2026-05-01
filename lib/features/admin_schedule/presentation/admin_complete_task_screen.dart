import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controller/admincontroller/admin_home_controller.dart';
import '../../../controller/admincontroller/schedule_controller.dart';
import '../../../models/admin-model/get_alllist_task_model.dart' as list_model;
import '../../../models/admin-model/task_details_model.dart';
import '../../../services/api_constants.dart';
import '../../../shared_widgets/admin_task_complete_card.dart';
import '../../../shared_widgets/custom_text.dart';

class AdminCompleteTaskScreen extends StatefulWidget {
  final String? taskId;

  const AdminCompleteTaskScreen({super.key, this.taskId});

  @override
  State<AdminCompleteTaskScreen> createState() => _AdminCompleteTaskScreenState();
}

class _AdminCompleteTaskScreenState extends State<AdminCompleteTaskScreen> {
  late ScheduleController scheduleController;

  @override
  void initState() {
    super.initState();
    scheduleController = Get.find<ScheduleController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if taskId was passed as a parameter
      if (widget.taskId != null && widget.taskId!.isNotEmpty) {
        scheduleController.getTaskDetails(widget.taskId!);
      } else {
        // If not passed as parameter, try to get from GoRouter state
        final taskId = GoRouterState.of(context).pathParameters['taskId'];
        if (taskId != null && taskId.isNotEmpty) {
          scheduleController.getTaskDetails(taskId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
              onPressed: () {
                if (mounted) context.pop();
              },
            ),
            SizedBox(width: 8.w),
            CustomText(
              text: "Task Details",
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        actions: [
          Obx(() {
            final task = scheduleController.taskDetailsData.value;
            if (task == null) return const SizedBox.shrink();
            final taskId = widget.taskId ??
                GoRouterState.of(context).pathParameters['taskId'] ?? '';
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Colors.black, size: 22.sp),
                  onPressed: () async {
                    final result = _toListResult(task);
                    await context.pushNamed('adminEditTaskScreen', extra: result);
                    if (taskId.isNotEmpty) {
                      scheduleController.getTaskDetails(taskId);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red, size: 22.sp),
                  onPressed: () => _confirmDelete(taskId),
                ),
              ],
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (scheduleController.taskDetailsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          TaskDetailsModel? taskDetails = scheduleController.taskDetailsData.value;
          if (taskDetails == null) {
            return const Center(child: Text('No task details available'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AdminTaskCompleteCard with dynamic data
                AdminTaskCompleteCard(taskDetails: taskDetails),

                SizedBox(height: 16.h),

                // Approve Task Button — only for submitted tasks
                if (_isSubmitted(taskDetails.status, taskDetails.isSubmited)) ...[
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        backgroundColor: const Color(0xFF12B76A),
                        elevation: 0,
                      ),
                      onPressed: scheduleController.taskApproving.value
                          ? null
                          : () async {
                              final taskId = widget.taskId ?? GoRouterState.of(context).pathParameters['taskId'] ?? '';
                              if (taskId.isNotEmpty) {
                                await scheduleController.approveTask(taskId);
                              }
                            },
                      child: scheduleController.taskApproving.value
                          ? SizedBox(
                              width: 22.w,
                              height: 22.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Approve Task",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  )),
                  SizedBox(height: 8.h),
                ],

                SizedBox(height: 12.h),

                // Services Section
                Text(
                  'Services',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 12.h),

                // Services List
                ..._buildServiceItems(taskDetails.services ?? []),

                SizedBox(height: 24.h),

                // Assigned To Section
                Text(
                  'Assigned To',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 12.h),

                _buildAssigneeInfo(taskDetails.assignTo),

                // Attachments Section
                if (taskDetails.attachments != null && taskDetails.attachments!.isNotEmpty) ...[
                  SizedBox(height: 24.h),
                  Text(
                    'Attachments',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: taskDetails.attachments!.map((path) {
                      final fullUrl = path.startsWith('http')
                          ? path
                          : '${ApiConstants.imageBaseUrl}$path';
                      final fileName = path.split('/').last;
                      final isImage = ['.png', '.jpg', '.jpeg', '.gif', '.webp']
                          .any((ext) => fileName.toLowerCase().endsWith(ext));

                      return GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse(fullUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open the file')),
                            );
                          }
                        },
                        child: Container(
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey[300]!, width: 1),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                                child: isImage
                                    ? Image.network(
                                        fullUrl,
                                        width: 100.w,
                                        height: 80.h,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => SizedBox(
                                          width: 100.w,
                                          height: 80.h,
                                          child: Icon(Icons.broken_image, color: Colors.grey, size: 32.sp),
                                        ),
                                      )
                                    : Container(
                                        width: 100.w,
                                        height: 80.h,
                                        color: const Color(0xFFE8EEF9),
                                        child: Icon(Icons.insert_drive_file, color: const Color(0xFF007AFF), size: 36.sp),
                                      ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(6.w),
                                child: Text(
                                  fileName,
                                  style: TextStyle(fontSize: 10.sp, color: Colors.black87),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                SizedBox(height: 24.h),

                // Notes Section
                if (taskDetails.notes != null && taskDetails.notes!.isNotEmpty) ...[
                  Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    taskDetails.notes ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF667085),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],

                // Download Task Report Button
                if (taskDetails.invoicePath != null && taskDetails.invoicePath!.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        backgroundColor: const Color(0xFFF95555),
                        elevation: 0,
                      ),
                      icon: Icon(Icons.download, color: Colors.white, size: 20.sp),
                      label: Text(
                        "Download Task Report",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () async {
                        final path = taskDetails.invoicePath!;
                        final fullUrl = path.startsWith('http')
                            ? path
                            : '${ApiConstants.imageBaseUrl}$path';
                        final uri = Uri.parse(fullUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open the file')),
                          );
                        }
                      },
                    ),
                  ),

                SizedBox(height: 32.h),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _confirmDelete(String taskId) {
    if (taskId.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Task', style: TextStyle(fontWeight: FontWeight.w600)),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final adminController = Get.find<AdminHomeController>();
              await adminController.deleteTask(taskId: taskId);
              if (mounted) context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  list_model.Result _toListResult(TaskDetailsModel d) {
    List<String> assignToIds = [];
    final at = d.assignTo;
    if (at is List) {
      assignToIds = at.map((item) {
        if (item is AssignTo) return item.id ?? '';
        if (item is Map<String, dynamic>) return item['id']?.toString() ?? '';
        return item.toString();
      }).where((id) => id.isNotEmpty).toList();
    } else if (at is AssignTo) {
      assignToIds = [at.id ?? ''].where((id) => id.isNotEmpty).toList();
    } else if (at is String && at.isNotEmpty) {
      assignToIds = [at];
    }

    return list_model.Result(
      id: d.id,
      customerName: d.customerName,
      customerNumber: d.customerNumber,
      customerAddress: d.customerAddress,
      notes: d.notes,
      otherAmount: d.otherAmount,
      department: d.department?.id,
      serviceCategory: d.serviceCategory?.id,
      vehicle: d.vehicle,
      assignTo: assignToIds,
      priority: d.priority,
      difficulty: d.difficulty,
      assignDate: d.assignDate,
      deadline: d.deadline,
      services: d.services
          ?.map((s) => list_model.Service(
                name: s.name,
                price: s.price?.toInt(),
                quantity: s.quantity,
                id: s.id,
              ))
          .toList(),
      attachments: d.attachments,
      status: d.status,
      isSubmited: d.isSubmited,
    );
  }

  bool _isSubmitted(String? status, bool? isSubmited) {
    final s = status?.toLowerCase() ?? '';
    if (s == 'completed' || s == 'approved') return false;
    if (isSubmited == true) return true;
    return s.contains('submit');
  }

  List<Widget> _buildServiceItems(List<Service> services) {
    if (services.isEmpty) {
      return [
        Text(
          'No services available',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF667085),
          ),
        ),
      ];
    }

    return services.map((service) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                service.name ?? 'N/A',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Qty: ${service.quantity ?? 0}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF667085),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              '\$${service.price?.toStringAsFixed(2) ?? '0.00'}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildAssigneeInfo(dynamic assignTo) {
    if (assignTo == null) {
      return Text(
        'N/A',
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF667085),
        ),
      );
    }

    // Check if assignTo is a string (ID) or an AssignTo object
    if (assignTo is String) {
      return Text(
        assignTo,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      );
    } else if (assignTo is AssignTo) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            assignTo.fullName ?? 'N/A',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          if (assignTo.email != null) ...[
            SizedBox(height: 4.h),
            Text(
              assignTo.email!,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF667085),
              ),
            ),
          ],
          if (assignTo.phoneNumber != null) ...[
            SizedBox(height: 4.h),
            Text(
              assignTo.phoneNumber!,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF667085),
              ),
            ),
          ],
        ],
      );
    } else if (assignTo is List) {
      if (assignTo.isEmpty) {
        return Text(
          'No assignees',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF667085),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: assignTo.map((item) {
          String displayText = 'N/A';

          if (item is String) {
            displayText = item;
          } else if (item is Map<String, dynamic>) {
            displayText = item['fullName'] ?? item['id'] ?? 'N/A';
          }

          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              displayText,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          );
        }).toList(),
      );
    } else {
      return Text(
        assignTo.toString(),
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      );
    }
  }
}