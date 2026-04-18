import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/features/admin_home/presentation/widget/custom_loader.dart';
import '../../../constants/app_color.dart';
import '../../../controller/admincontroller/admin_home_controller.dart';
import '../../../models/admin-model/all_attendance_list_model.dart';
import '../../../services/api_constants.dart';
import '../../../shared_widgets/custom_text.dart';
import 'admin_view_attendance_screen.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  late AdminHomeController adminHomeController;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Pending';
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    adminHomeController = Get.find<AdminHomeController>();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAttendance();
    });
  }

  void _fetchAttendance() {
    adminHomeController.getAdminAllAttendance(
      month: _selectedMonth.month,
      year: _selectedMonth.year,
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year + ((_selectedMonth.month + delta - 1) ~/ 12),
        ((_selectedMonth.month - 1 + delta) % 12) + 1,
      );
    });
    _fetchAttendance();
  }

  Future<void> _showMonthPicker() async {
    int pickerYear = _selectedMonth.year;
    int pickerMonth = _selectedMonth.month;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () =>
                      setDialogState(() => pickerYear--),
                ),
                Text(
                  '$pickerYear',
                  style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () =>
                      setDialogState(() => pickerYear++),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (_, i) {
                  final isSelected =
                      i + 1 == pickerMonth && pickerYear == _selectedMonth.year;
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() => pickerMonth = i + 1);
                      setState(() {
                        _selectedMonth =
                            DateTime(pickerYear, i + 1);
                      });
                      _fetchAttendance();
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFFEC526A),
                                  Color(0xFFF77F6E)
                                ],
                              )
                            : null,
                        color: isSelected ? null : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        _monthNames[i].substring(0, 3),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
      },
    );
  }

  List<Attendance> _applyFilters(List<Attendance> all) {
    return all.where((a) {
      // Month filter
      if (a.clockIn != null) {
        if (a.clockIn!.month != _selectedMonth.month ||
            a.clockIn!.year != _selectedMonth.year) {
          return false;
        }
      }
      // Status filter
      final status = (a.status ?? '').toLowerCase();
      if (_selectedStatus == 'Pending' &&
          status != 'pending' &&
          status != '') {
        if (status == 'approved') return false;
      }
      if (_selectedStatus == 'Approved' && status != 'approved') {
        return false;
      }
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final name = (a.employee?.displayName ?? '').toLowerCase();
        final role = (a.employee?.role ?? '').toLowerCase();
        if (!name.contains(_searchQuery) && !role.contains(_searchQuery)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              text: "Attendance",
              color: AppColor.secondaryColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Search & Month Picker
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey, size: 23.r),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                hintText: "Search employee...",
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintStyle: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () => _searchController.clear(),
                              child: Icon(Icons.close,
                                  color: Colors.grey, size: 16.r),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),

                  /// Month Navigation
                  Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                              minWidth: 28.w, minHeight: 40.h),
                          icon: Icon(Icons.chevron_left,
                              size: 20.r, color: Colors.black),
                          onPressed: () => _changeMonth(-1),
                        ),
                        GestureDetector(
                          onTap: _showMonthPicker,
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 4.w),
                            child: Row(
                              children: [
                                CustomText(
                                  text:
                                      "${_monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}",
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                SizedBox(width: 4.w),
                                Icon(Icons.calendar_today_outlined,
                                    color: const Color(0xFFEC526A),
                                    size: 14.r),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                              minWidth: 28.w, minHeight: 40.h),
                          icon: Icon(Icons.chevron_right,
                              size: 20.r, color: Colors.black),
                          onPressed: () => _changeMonth(1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              /// Summary Cards
              Obx(() {
                final data = adminHomeController.allAttendance.value;
                int safe(int? v) => (v ?? 0) < 0 ? 0 : (v ?? 0);
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSummaryCard(
                      "${safe(data.totalPresent)}",
                      "Present",
                      const Color(0xFFC4EAD5),
                      const Color(0xFF31712B),
                    ),
                    _buildSummaryCard(
                      "${safe(data.totalAbsent)}",
                      "Absent",
                      const Color(0xFFD2E8F8),
                      const Color(0xFF0B59A1),
                    ),
                    _buildSummaryCard(
                      "${safe(data.totalLateIn)}",
                      "Late In",
                      const Color(0xFFF3E8C1),
                      const Color(0xFFE3A607),
                    ),
                    _buildSummaryCard(
                      "${safe(data.totalEarlyOut)}",
                      "Early Out",
                      const Color(0xFFFCCCCC),
                      const Color(0xFFEE3E3E),
                    ),
                  ],
                );
              }),

              SizedBox(height: 20.h),

              /// Status Filter — Pending / Approved only
              Row(
                children: [
                  _buildStatusChip("Pending", _selectedStatus == "Pending"),
                  SizedBox(width: 10.w),
                  _buildStatusChip("Approved", _selectedStatus == "Approved"),
                ],
              ),
              SizedBox(height: 20.h),

              /// Employee List Header
              Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  text: "Employee List",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),

              /// Employee Cards
              Obx(() {
                if (adminHomeController.getAdminAllAttendanceLoading.value) {
                  return const Center(child: CustomLoader());
                }

                final all =
                    adminHomeController.allAttendance.value.results ?? [];
                final filtered = _applyFilters(all);

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'No results for "$_searchQuery"'
                            : 'No attendance records found',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 13.sp),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final attendance = filtered[index];

                    String checkInTime = _formatTime(attendance.clockIn);
                    String checkOutTime = _formatTime(attendance.clockOut);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminViewAttendanceScreen(
                              employeeName:
                                  attendance.employee?.displayName ??
                                      "Unknown",
                              role: attendance.employee?.role ?? "N/A",
                              employeeEmail:
                                  attendance.employee?.email,
                              image: attendance.employee?.image,
                              checkIn: checkInTime,
                              breakTime: "N/A",
                              checkOut: checkOutTime,
                            ),
                          ),
                        );
                      },
                      child: _buildEmployeeCard(
                        attendance.employee?.displayName ?? "Unknown",
                        attendance.employee?.role ?? "N/A",
                        checkInTime,
                        checkOutTime,
                        attendance.employee?.image,
                        attendance.status,
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return 'N/A';
    final local = dt.toLocal();
    final period = local.hour < 12 ? 'AM' : 'PM';
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final min = local.minute.toString().padLeft(2, '0');
    return '${hour.toString().padLeft(2, '0')}:$min $period';
  }

  Widget _buildSummaryCard(
    String count,
    String label,
    Color bgColor,
    Color topShadowColor,
  ) {
    return Container(
      width: 172.w,
      height: 90.h,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9.29.r),
        boxShadow: [
          BoxShadow(
            color: topShadowColor.withOpacity(0.75),
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              text: count,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0B2750),
            ),
            SizedBox(height: 4.h),
            CustomText(
              text: label,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0B2750),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = text),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFEC526A), Color(0xFFF77F6E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: !isSelected ? Colors.white : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CustomText(
          text: text,
          fontSize: 14.sp,
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(
    String name,
    String role,
    String checkIn,
    String checkOut,
    String? imageUrl,
    String? status,
  ) {
    final statusLower = (status ?? '').toLowerCase();
    Color statusColor = statusLower == 'approved'
        ? Colors.green
        : statusLower == 'rejected'
            ? Colors.red
            : Colors.orange;
    String statusLabel = statusLower.isEmpty
        ? 'Pending'
        : status![0].toUpperCase() + status.substring(1);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                ? NetworkImage(_getImageUrl(imageUrl))
                : AssetImage('assets/images/profile.png') as ImageProvider,
            child: imageUrl == null || imageUrl.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: name,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  text: role,
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    CustomText(
                      text: "In: ",
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                    CustomText(
                      text: checkIn,
                      fontSize: 10.sp,
                      color: Colors.green,
                    ),
                    CustomText(
                      text: "  Out: ",
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                    CustomText(
                      text: checkOut,
                      fontSize: 10.sp,
                      color: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11.sp,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return "${ApiConstants.imageBaseUrl}$imageUrl";
  }
}
