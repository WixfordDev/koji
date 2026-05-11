import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/features/admin_home/presentation/admin_my_task_details_screen.dart';
import 'package:koji/features/admin_home/presentation/widget/custom_loader.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/app_color.dart';
import '../../../controller/admincontroller/admin_home_controller.dart';
import '../../../models/admin-model/get_alllist_task_model.dart';

class AdminMyTaskScreen extends StatefulWidget {
  const AdminMyTaskScreen({super.key});

  @override
  State<AdminMyTaskScreen> createState() => _AdminMyTaskScreenState();
}

class _AdminMyTaskScreenState extends State<AdminMyTaskScreen> {
  late AdminHomeController adminHomeController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    adminHomeController = Get.find<AdminHomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adminHomeController.getAllListTasks();
    });
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    await launchUrl(uri);
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
              await adminHomeController.deleteTask(taskId: taskId);
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

  // Status enum values as requested
  final List<String> statusFilters = ["All", "pending", "progress", "completed"];
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
            const SizedBox(height: 14),
            _buildSearchField(),
            const SizedBox(height: 14),
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

  // ------------------------------ SEARCH FIELD ------------------------------
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xffF3F4F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search by customer, priority...',
            hintStyle: const TextStyle(color: Color(0xff9CA3AF), fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Color(0xff9CA3AF), size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () => _searchController.clear(),
                    child: const Icon(Icons.close, color: Color(0xff9CA3AF), size: 18),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ------------------------------ TABS ------------------------------
  Widget _buildTabs() {
    return Obx(() {
      String allCount = adminHomeController.getAllListTaskLoading.value
          ? "All"
          : "All (${adminHomeController.getAllListTask.value.results?.length ?? 0})";

      List<String> tabs = [allCount, ...statusFilters.skip(1)]; // Skip "All" from statusFilters

      return SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          physics: const BouncingScrollPhysics(),
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
    });
  }

  // ------------------------------ TASK LIST ------------------------------
  Widget _buildTaskList() {
    return Obx(() {
      if (adminHomeController.getAllListTaskLoading.value) {
        return const Center(child: CustomLoader());
      }

      if (adminHomeController.getAllListTask.value.results == null ||
          adminHomeController.getAllListTask.value.results!.isEmpty) {
        return const Center(child: Text("No tasks found"));
      }

      List<Result> filteredTasks =
          _filterTasks(adminHomeController.getAllListTask.value.results!);

      if (filteredTasks.isEmpty) {
        return Center(
          child: Text(
            _searchQuery.isNotEmpty ? 'No results for "$_searchQuery"' : 'No tasks found for this status',
            style: const TextStyle(color: Colors.grey),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await adminHomeController.getAllListTasks();
        },
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: filteredTasks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            final progress = (task.progressPercent ?? 0) / 100.0;

            return GestureDetector(
              onTap: () {
                if (task.id != null && task.id!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminMyTaskDetailsScreen(taskId: task.id!),
                    ),
                  );
                }
              },
              child: _taskCard(
                task: task,
                title: task.customerName ?? 'Task',
                status: _formatStatus(task.status ?? 'pending'),
                statusColor: _getStatusColor(task.status ?? 'pending'),
                priority: _formatPriority(task.priority ?? 'medium'),
                progress: progress,
                date: task.assignDate != null
                    ? '${task.assignDate!.day} ${_getMonthName(task.assignDate!.month)}'
                    : 'No date',
                serialNumber: index + 1,
              ),
            );
          },
        ),
      );
    });
  }

  // Filter tasks based on selected status tab and search query
  List<Result> _filterTasks(List<Result> tasks) {
    List<Result> filtered = tasks;

    // Status filter
    if (selectedTab != 0) {
      String selectedStatus = statusFilters[selectedTab].toLowerCase();
      filtered = filtered.where((task) {
        String taskStatus = (task.status ?? 'pending').toLowerCase();
        if (taskStatus == "submited" && selectedStatus == "submitted") return true;
        if (taskStatus == "submitted" && selectedStatus == "submited") return true;
        return taskStatus == selectedStatus;
      }).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) {
        final name = (task.customerName ?? '').toLowerCase();
        final number = (task.customerNumber ?? '').toLowerCase();
        final priority = (task.priority ?? '').toLowerCase();
        final status = (task.status ?? '').toLowerCase();
        final address = (task.customerAddress ?? '').toLowerCase();
        return name.contains(_searchQuery) ||
            number.contains(_searchQuery) ||
            priority.contains(_searchQuery) ||
            status.contains(_searchQuery) ||
            address.contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  // Format status for display
  String _formatStatus(String status) {
    if (status.isEmpty) return 'Pending';

    // Handle API typo
    if (status.toLowerCase() == "submited") return "Submitted";
    if (status.toLowerCase() == "progress") return "In Progress";

    // Capitalize first letter
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  // Get color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'progress':
      case 'in_progress':
        return Colors.orange;
      case 'submitted':
      case 'submited':
        return const Color(0xff6B7280);
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return const Color(0xff10B981);
      default:
        return Colors.grey;
    }
  }

  // Format priority
  String _formatPriority(String priority) {
    if (priority.isEmpty) return 'Medium';
    return priority[0].toUpperCase() + priority.substring(1).toLowerCase();
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
    required Result task,
    required String title,
    required String status,
    int? serialNumber,
    required Color statusColor,
    required String priority,
    required double progress,
    required String date,
  }) {
    final String rawStatus = (task.status ?? 'pending').toLowerCase();
    final bool isCompleted = rawStatus == 'completed' || rawStatus == 'approved';
    final bool isRejected = rawStatus == 'rejected';

    final Color lightBg = isCompleted
        ? Colors.green.shade50
        : isRejected
            ? Colors.red.shade50
            : Colors.orange.shade50;
    final Color lightBorder = isCompleted
        ? Colors.green.shade200
        : isRejected
            ? Colors.red.shade200
            : Colors.orange.shade200;
    final Color darkText = isCompleted
        ? Colors.green.shade700
        : isRejected
            ? Colors.red.shade700
            : Colors.orange.shade700;

    final int progressInt = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: lightBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (serialNumber != null) ...[
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(color: Colors.grey.shade700, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    '$serialNumber',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.secondaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.customerNumber != null && task.customerNumber!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () => _makeCall(task.customerNumber!),
                        child: Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              task.customerNumber!,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: lightBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: lightBorder, width: 1),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 12, color: darkText, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.miscellaneous_services_outlined,
            "Service",
            task.serviceCategory?.name ??
                (task.services?.where((s) => s.name != null).map((s) => s.name!).join(', ') ?? '-'),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today, "Date Range", _formatDateRange(task.assignDate, task.deadline)),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, "Address", task.customerAddress ?? '-'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: lightBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle_outline : Icons.hourglass_bottom,
                      color: statusColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Progress",
                      style: TextStyle(color: darkText, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "$progressInt%",
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => context.pushNamed('adminEditTaskScreen', extra: task),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF234176).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF234176)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _confirmDelete(task.id ?? ''),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColor.primaryColor, size: 16),
        const SizedBox(width: 8),
        Text(
          "$title: ",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColor.secondaryColor, fontSize: 12, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDateRange(DateTime? from, DateTime? to) {
    String fmt(DateTime? dt) {
      if (dt == null) return '-';
      return '${dt.day}/${dt.month}/${dt.year}';
    }
    return '${fmt(from)} – ${fmt(to)}';
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