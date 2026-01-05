import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/constants/app_color.dart';
import 'package:koji/services/api_constants.dart';
import 'package:koji/shared_widgets/custom_button.dart';
import 'package:koji/shared_widgets/custom_network_image.dart';
import 'package:koji/shared_widgets/custom_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koji/services/attendance_service.dart';
import 'package:koji/helpers/toast_message_helper.dart';
import 'package:koji/models/attendance.dart';
import 'package:koji/helpers/prefs_helper.dart';
import 'package:koji/core/app_constants.dart';
import 'package:koji/controller/employee_location_controller.dart';
import 'package:get/get.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  bool isCheckedIn = false;
  bool isCheckedOutComplete =
      false; // true if user already has both clockIn and clockOut for today

  // optionally hold last attendance id or records count if needed later
  int attendanceCount = 0;
  List<Attendance> attendances = [];
  Attendance? todayAttendance;
  DateTime _now = DateTime.now();
  Timer? _clockTimer;
  String userName = '';
  String userImage = '';

  @override
  void initState() {
    super.initState();
    // Initialize location tracking when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocationTracking();
      _fetchAttendanceList();
      _loadUserName();
    });
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  /// Initialize location tracking for the employee
  void _initializeLocationTracking() {
    // Get the location controller to start location updates
    final locationController = Get.put(EmployeeLocationController());

    // Start location tracking
    locationController.startLocationTracking();
  }

  Future<void> _loadUserName() async {
    try {
      final name = await PrefsHelper.getString(AppConstants.name);
      final image = await PrefsHelper.getString(AppConstants.image);
      if (mounted) {
        setState(() {
          userName = name.isNotEmpty ? name : '';
          userImage = image.isNotEmpty ? image : '';
        });
      }
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAttendanceList() async {
    final now = DateTime.now();
    final month =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    try {
      final resp = await AttendanceService.getEmployeeList(date: month);
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final results = resp.body?['data']?['attributes']?['results'];
        if (results is List) {
          final parsed = results
              .whereType<Map<String, dynamic>>()
              .map((e) => Attendance.fromJson(e))
              .toList();
          // set attendance list and count
          setState(() {
            attendances = parsed;
            attendanceCount = parsed.length;
          });

          // pick today's attendance (UTC date match)
          final nowUtc = DateTime.now().toUtc();
          Attendance? found;
          for (final a in parsed) {
            if (a.date != null) {
              final d = a.date!.toUtc();
              if (d.year == nowUtc.year &&
                  d.month == nowUtc.month &&
                  d.day == nowUtc.day) {
                found = a;
                break;
              }
            }
          }
          setState(() {
            todayAttendance =
                found ?? (parsed.isNotEmpty ? parsed.first : null);
            // Detect current attendance state
            if (todayAttendance != null) {
              final hasClockIn = todayAttendance!.clockIn != null;
              final hasClockOut = todayAttendance!.clockOut != null;
              isCheckedIn = hasClockIn && !hasClockOut; // Currently checked in
              isCheckedOutComplete =
                  hasClockIn && hasClockOut; // Already completed for today
            } else {
              isCheckedIn = false;
              isCheckedOutComplete = false;
            }
          });
        }
      }
    } catch (e) {
      // ignore background fetch errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                image: const DecorationImage(
                  image: AssetImage('assets/images/homeBG.png'),

                  fit: BoxFit.contain,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Profile Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CustomNetworkImage(
                            imageUrl: userImage.isNotEmpty
                                ? "${ApiConstants.imageBaseUrl}$userImage"
                                : "https://example.com/image.jpg",
                            height: 40.h,
                            width: 40.w,
                            boxShape: BoxShape.circle,
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: _greeting(),
                                color: const Color(0xff8F8F8F),
                                fontSize: 12.sp,
                              ),
                              CustomText(
                                text: userName.isNotEmpty ? userName : 'User',
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push('/notificationScreen');
                        },
                        child: Icon(
                          Icons.notifications_none_outlined,
                          color: const Color(0xff8F8F8F),
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 96.h),

                  // Center Clock and Date (live)
                  Center(
                    child: Column(
                      children: [
                        CustomText(
                          text: _formatClock(_now),
                          fontWeight: FontWeight.bold,
                          fontSize: 60.sp,
                        ),
                        CustomText(
                          text: _formatDate(_now),
                          color: const Color(0xff8F8F8F),
                          fontSize: 26.sp,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60.h),

                  // Check In / Check Out Button
                  Center(
                    child: GestureDetector(
                      onTap: isCheckedIn
                          ? _showConfirmCheckOutDialog
                          : _performCheckIn,
                      child: Container(
                        height: 229.h,
                        width: 229.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isCheckedIn
                                ? [Colors.redAccent, Colors.red]
                                : [Colors.blueAccent, Colors.blue],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/hand.svg',
                              height: 60,
                              width: 60,
                            ),

                            SizedBox(height: 5.h),
                            CustomText(
                              text: isCheckedIn ? "CHECK OUT" : "CHECK IN",
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Location Text (dynamic from attendance if available)
                  Center(
                    child: CustomText(
                      text: _locationLabel(),
                      color: const Color(0xff8F8F8F),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 62.h),

                  // Bottom Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _infoItem(
                        _formatTime(todayAttendance?.clockIn),
                        "Clock In",
                      ),
                      _infoItem(
                        _formatTime(todayAttendance?.clockOut),
                        "Clock Out",
                      ),
                      _infoItem(
                        _formatTotalHours(todayAttendance),
                        "Total Hours",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String time, String label) {
    return Column(
      children: [
        CustomText(text: time, fontWeight: FontWeight.w600, fontSize: 20.sp),
        SizedBox(height: 4.h),
        CustomText(
          text: label,
          color: const Color(0xff8F8F8F),
          fontSize: 12.sp,
        ),
      ],
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatTotalHours(Attendance? a) {
    if (a == null) return '--:--';
    if (a.totalHours != null) return '${a.totalHours}h';
    if (a.clockIn != null && a.clockOut != null) {
      final diff = a.clockOut!.toLocal().difference(a.clockIn!.toLocal());
      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
    return '--:--';
  }

  String _formatClock(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime dt) {
    final weekday = _weekdayName(dt.weekday);
    final month = _monthName(dt.month);
    final day = dt.day;
    return '$weekday, $month $day';
  }

  String _weekdayName(int w) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(w - 1) % 7];
  }

  String _monthName(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[(m - 1) % 12];
  }

  String _locationLabel() {
    try {
      final loc = todayAttendance?.location;
      if (loc is Map<String, dynamic>) {
        final name = loc['name'];
        if (name != null && name.toString().isNotEmpty)
          return 'Location: ${name.toString()}';
      }
      if (isCheckedIn) return 'Location: You are currently checked in';
      return 'Location: Singapore, Adam Park';
    } catch (_) {
      return 'Location: Singapore, Adam Park';
    }
  }

  String _greeting() {
    final hour = _now.hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  void _showConfirmCheckOutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 90.h,
                  width: 90.w,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(15.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.access_time, color: Colors.white),
                ),

                SizedBox(height: 10.h),
                CustomText(
                  text: "Confirm Check Out",
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  maxline: 5,

                  text:
                      "Once you Check out, you won’t be able to edit this time. Please double-check your hours before proceeding.",
                  color: Colors.grey,
                  fontSize: 12.sp,
                  textAlign: TextAlign.start,
                ),

                SizedBox(height: 20.h),

                CustomButton(
                  title: "Yes Check Out",
                  onpress: () {
                    Navigator.pop(context);
                    _showCheckoutNoteDialog();
                  },
                ),

                SizedBox(height: 10.h),

                CustomButton(
                  color: Colors.transparent,
                  boderColor: AppColor.primaryColor,
                  titlecolor: AppColor.primaryColor,
                  title: "No, Let Me Check",
                  onpress: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCheckoutNoteDialog() {
    TextEditingController noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: "Daily Checkout Note",
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
                SizedBox(height: 10.h),
                CustomText(
                  text:
                      "Before You End Your Day, Please Take A Moment To Write Your Daily Checkout Note. Summarize The Tasks You Completed, Highlight Any Pending Work, And Mention If You Faced Any Challenges.",
                  color: Colors.grey,
                  fontSize: 12.sp,
                  maxline: 5,
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 15.h),
                TextField(
                  controller: noteCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Write your note here...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 15.h),

                CustomButton(
                  title: "Submit",
                  onpress: () async {
                    final note = noteCtrl.text.trim();
                    Navigator.pop(context);
                    await _performCheckOut(note);
                  },
                ),

                SizedBox(height: 10.h),

                CustomButton(
                  color: Colors.transparent,
                  boderColor: AppColor.primaryColor,
                  titlecolor: AppColor.primaryColor,
                  title: "Skip",
                  onpress: () async {
                    Navigator.pop(context);
                    await _performCheckOut("");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _timeBox(String label, String time) {
    return Container(
      width: 120.w,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.grey.shade100,
      ),
      child: Column(
        children: [
          CustomText(text: label, fontWeight: FontWeight.w500),
          SizedBox(height: 5.h),
          CustomText(text: time, color: Colors.grey),
        ],
      ),
    );
  }

  Future<void> _performCheckIn() async {
    // Prevent duplicate check-in if already checked in today
    if (isCheckedIn) {
      ToastMessageHelper.showToastMessage(
        'You are already checked in today. Please check out first.',
        title: 'Info',
        context: context,
      );
      return;
    }

    // Prevent check-in if already completed for today
    if (isCheckedOutComplete) {
      ToastMessageHelper.showToastMessage(
        'You already completed check-in and check-out today.',
        title: 'Info',
        context: context,
      );
      return;
    }

    final nowIso = DateTime.now().toUtc().toIso8601String();
    try {
      final resp = await AttendanceService.checkIn(clockIn: nowIso);
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        setState(() => isCheckedIn = true);
        final msg = resp.body != null && resp.body["message"] != null
            ? resp.body["message"]
            : 'Checked in successfully';
        ToastMessageHelper.showToastMessage(msg, context: context);
        // Refresh attendance data to show updated check-in time
        await _fetchAttendanceList();
      } else {
        ToastMessageHelper.showToastMessage(
          resp.statusText ?? 'Check-in failed',
          title: 'Error',
          context: context,
        );
      }
    } catch (e) {
      ToastMessageHelper.showToastMessage(
        'Check-in failed',
        title: 'Error',
        context: context,
      );
    }
  }

  Future<void> _performCheckOut(String? notes) async {
    // Prevent check-out if not currently checked in
    if (!isCheckedIn) {
      ToastMessageHelper.showToastMessage(
        'You need to check in first before checking out.',
        title: 'Info',
        context: context,
      );
      return;
    }

    final nowIso = DateTime.now().toUtc().toIso8601String();
    try {
      final resp = await AttendanceService.checkOut(
        clockOut: nowIso,
        notes: notes,
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        setState(() {
          isCheckedIn = false;
          isCheckedOutComplete = true;
        });
        final msg = resp.body != null && resp.body["message"] != null
            ? resp.body["message"]
            : 'Checked out successfully';
        ToastMessageHelper.showToastMessage(msg, context: context);
        // Refresh attendance data to show updated check-out time
        await _fetchAttendanceList();
      } else {
        ToastMessageHelper.showToastMessage(
          resp.statusText ?? 'Check-out failed',
          title: 'Error',
          context: context,
        );
      }
    } catch (e) {
      ToastMessageHelper.showToastMessage(
        'Check-out failed',
        title: 'Error',
        context: context,
      );
    }
  }
}
