import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/features/admin_home/presentation/widget/custom_loader.dart';
import '../../../controller/admincontroller/admin_home_controller.dart';
import '../../../models/admin-model/get_alllist_task_model.dart';

class AdminMyTaskScreen extends StatefulWidget {
  const AdminMyTaskScreen({super.key});

  @override
  State<AdminMyTaskScreen> createState() => _AdminMyTaskScreenState();
}

class _AdminMyTaskScreenState extends State<AdminMyTaskScreen> {
  late AdminHomeController adminHomeController;

  @override
  void initState() {
    super.initState();
    adminHomeController = Get.find<AdminHomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adminHomeController.getAllListTasks();
    });
  }

  // Status enum values as requested
  final List<String> statusFilters = ["All", "pending", "progress", "submitted", "approved", "rejected", "completed"];
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildAppBar(),
            const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 20),
            Expanded(child: _buildTaskList()),
            _buildCreateTaskButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ------------------------------ APP BAR ------------------------------
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          const Spacer(),
          const Text(
            "My Task",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  // ------------------------------ TABS ------------------------------
  Widget _buildTabs() {
    return GetBuilder<AdminHomeController>(
      builder: (controller) {
        String allCount = controller.getAllListTaskLoading.value
            ? "All"
            : "All (${controller.getAllListTask.value.results?.length ?? 0})";

        List<String> tabs = [allCount, ...statusFilters.skip(1)]; // Skip "All" from statusFilters

        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            physics: const BouncingScrollPhysics(), // Add bouncy scrolling effect
            itemBuilder: (context, index) {
              final bool active = selectedTab == index;

              return GestureDetector(
                onTap: () => setState(() => selectedTab = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: active
                        ? const LinearGradient(
                      colors: [Color(0xffEC526A), Color(0xffF77F6E)],
                    )
                        : null,
                    borderRadius: BorderRadius.circular(30),
                    border: active
                        ? null
                        : Border.all(color: const Color(0xffC8C8C8)),
                  ),
                  child: Center(
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        fontSize: 14,
                        color: active ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemCount: tabs.length,
          ),
        );
      },
    );
  }

  // ------------------------------ TASK LIST ------------------------------
  Widget _buildTaskList() {
    return GetBuilder<AdminHomeController>(
      builder: (controller) {
        if (controller.getAllListTaskLoading.value) {
          return const Center(child: CustomLoader());
        }

        if (controller.getAllListTask.value.results == null ||
            controller.getAllListTask.value.results!.isEmpty) {
          return const Center(child: Text("No tasks found"));
        }

        // Filter tasks based on selected tab
        List<Result> filteredTasks = _filterTasks(controller.getAllListTask.value.results!);

        if (filteredTasks.isEmpty) {
          return const Center(child: Text("No tasks found for this status"));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: filteredTasks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            final status = task.status?.toString().toLowerCase() ?? '';
            final progress = (task.progressPercent ?? 0) / 100.0;

            final statusValue = _getStatusValue(task.status);
            return _taskCard(
              title: _formatServiceCategory(task.serviceCategory?.toString()),
              status: _formatStatusEnum(task.status),
              statusColor: _getStatusColor(statusValue),
              priority: _formatPriorityEnum(task.priority),
              progress: progress,
              date: task.assignDate != null
                  ? '${task.assignDate!.day} ${_getMonthName(task.assignDate!.month)}'
                  : 'No date',
            );
          },
        );
      },
    );
  }

  // Filter tasks based on selected status tab
  List<Result> _filterTasks(List<Result> tasks) {
    if (selectedTab == 0) { // All tab
      return tasks;
    }

    String selectedStatus = statusFilters[selectedTab].toLowerCase();
    // Handle submitted vs submited (as the model uses "submited")
    if (selectedStatus == "submitted") {
      selectedStatus = "submited";
    }

    return tasks.where((task) {
      String taskStatus = _getStatusValue(task.status);
      // Handle the case where the model uses "submited" instead of "submitted"
      if (taskStatus == "submited" && selectedStatus == "submitted") {
        return true;
      }
      return taskStatus == selectedStatus;
    }).toList();
  }

  // Get the status value from enum
  String _getStatusValue(dynamic status) {
    if (status == null) return '';

    String statusString = status.toString();

    // Handle the enum pattern "Status." prefix
    if (statusString.startsWith('Status.')) {
      statusString = statusString.substring(7); // Remove "Status." prefix
    }

    return statusString.toLowerCase();
  }

  // Format status for display (already exists but improved)
  String _formatStatus(String status) {
    if (status.isEmpty) return 'Pending';

    // Handle API typo
    if (status == "submited") return "Submitted";
    if (status == "progress") return "In Progress";

    // Capitalize first letter
    return status[0].toUpperCase() + status.substring(1);
  }

  // Get color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'progress':
        return Colors.blue;
      case 'submitted':
      case 'submited':
        return const Color(0xff6B7280); // Grey for submitted
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return const Color(0xff10B981); // Green
      default:
        return Colors.grey;
    }
  }

  // Get month name from number
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return month >= 1 && month <= 12 ? months[month - 1] : '';
  }

  // ------------------------------ CARD COMPONENT ------------------------------
  Widget _taskCard({
    required String title,
    required String status,
    required Color statusColor,
    required String priority,
    required double progress,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.flash_on, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _chip(status, statusColor.withOpacity(0.15), statusColor),
              const SizedBox(width: 8),
              _chip(priority, Colors.red.withOpacity(0.15), Colors.red),
              const Spacer(),
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              )
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              height: 4,
              width: double.infinity,
              color: Colors.black12,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xffEC526A), Color(0xffF77F6E)],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("👨‍🔧  👩‍🔧  🧑‍🔧", style: TextStyle(fontSize: 18)),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.chat_bubble_outline, size: 16),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------ CHIP COMPONENT ------------------------------
  Widget _chip(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Format service category to remove prefixes and format nicely
  String _formatServiceCategory(String? category) {
    if (category == null || category.isEmpty) return 'Task';

    // Check if it's a known service category ID and map to name
    String serviceName = _mapServiceCategoryById(category);
    if (serviceName != category) {
      return serviceName;
    }

    // If not found in mapping, try to format the enum normally
    // Remove enum prefix patterns like "ServiceCategory."
    String formatted = category
        .replaceAll('ServiceCategory.', '')
        .replaceAll('THE_', '')
        .replaceAll('_', ' ');

    // Capitalize each word properly
    return formatted.split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // Map service category IDs to actual service names
  String _mapServiceCategoryById(String? categoryId) {
    if (categoryId == null) return 'Task';

    // Remove prefixes and normalize the ID for comparison
    String cleanId = categoryId
        .replaceAll('ServiceCategory.', '')
        .replaceAll('THE_', '')
        .replaceAll('_', '');

    // Convert to lowercase for comparison
    String lowerCleanId = cleanId.toLowerCase();

    // Check for known service IDs (using lowercase versions)
    switch (lowerCleanId) {
      case '690a1088223815bcb3528a5b':
        return 'Hand Painting Service';
      case '691a224ffb67f0b04e2d7cb7':
        return 'Plumbing Service';
      case 'anotherid': // Add other known IDs as needed
        return 'Another Service';
      default:
        return categoryId; // Return original if no mapping found
    }
  }

// Format priority properly
  String _formatPriority(String? priority) {
    if (priority == null || priority.isEmpty) return 'Medium';

    // Remove "Priority." prefix and capitalize
    String formatted = priority.replaceAll('Priority.', '');
    return formatted[0].toUpperCase() + formatted.substring(1).toLowerCase();
  }

  // Format status enum properly
  String _formatStatusEnum(dynamic status) {
    if (status == null) return 'Pending';

    String statusString = status.toString();

    // Handle the enum pattern "Status." prefix
    if (statusString.startsWith('Status.')) {
      statusString = statusString.substring(7); // Remove "Status." prefix
    }

    switch (statusString.toLowerCase()) {
      case 'submited':
        return 'Submitted';
      case 'progress':
        return 'In Progress';
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      default:
        return statusString[0].toUpperCase() + statusString.substring(1);
    }
  }

  // Format priority enum properly
  String _formatPriorityEnum(dynamic priority) {
    if (priority == null) return 'Medium';

    String priorityString = priority.toString();

    // Handle the enum pattern "Priority." prefix
    if (priorityString.startsWith('Priority.')) {
      priorityString = priorityString.substring(9); // Remove "Priority." prefix
    }

    switch (priorityString.toLowerCase()) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return priorityString[0].toUpperCase() + priorityString.substring(1);
    }
  }






  // ------------------------------ BOTTOM BUTTON ------------------------------
  Widget _buildCreateTaskButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffEC526A), Color(0xffF77F6E)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextButton(
        onPressed: () {
          context.push("/adminCreateTaskScreen");
        },
        child: const Text(
          "Create Task",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
