import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AdminMyTaskScreen extends StatefulWidget {
  const AdminMyTaskScreen({super.key});

  @override
  State<AdminMyTaskScreen> createState() => _AdminMyTaskScreenState();
}

class _AdminMyTaskScreenState extends State<AdminMyTaskScreen> {
  String selectedFilter = 'All';
  int tapCount = 0;

  // Easter egg: Triple tap the title to reveal a fun message!
  void _handleTitleTap() {
    setState(() {
      tapCount++;
      if (tapCount >= 3) {
        _showEasterEgg();
        tapCount = 0;
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => tapCount = 0);
    });
  }

  void _showEasterEgg() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEC526A), Color(0xFFF77F6E)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16.h),
              Text(
                'You found it!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '// TODO: Remove before production\n// JK, this is a feature 😄',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14.sp,
                  fontFamily: 'monospace',
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFEC526A),
                ),
                child: const Text('Back to work! 💪'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: GestureDetector(
            onTap: _handleTitleTap,
            child: Text(
              'My Task',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Filter tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                children: [
                  _buildFilterChip('All', 15),
                  SizedBox(width: 12.w),
                  _buildFilterChip('Pending', 0),
                  SizedBox(width: 12.w),
                  _buildFilterChip('InProgress', 0),
                  SizedBox(width: 12.w),
                  _buildFilterChip('Complete', 0),
                ],
              ),
            ),

            // Task list
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: [
                  _buildTaskCard(
                    title: 'Hand Painting Service',
                    status: 'In Progress',
                    progress: 0.96,
                    date: '27 Sept',
                    comments: 2,
                  ),
                  SizedBox(height: 16.h),
                  _buildTaskCard(
                    title: 'Plumbing Service',
                    status: 'In Progress',
                    progress: 0.96,
                    date: '27 Sept',
                    comments: 2,
                  ),
                  SizedBox(height: 16.h),
                  _buildTaskCard(
                    title: 'House Cleaning Service',
                    status: 'Done',
                    progress: 1.0,
                    date: '27 Sept',
                    comments: 2,
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Container(
          width: 342.w,
          height: 56.h,
          margin: EdgeInsets.only(left: 30.w),
          child: ElevatedButton(
            onPressed: () {
              context.push("/adminCreateTaskScreen");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC526A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Text(
              'Create Task',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEC526A), Color(0xFFF77F6E)],
          )
              : null,
          color: isSelected ? null : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          count > 0 ? '$label ($count)' : label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String status,
    required double progress,
    required String date,
    required int comments,
  }) {
    final isDone = status == 'Done';
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC526A), Color(0xFFF77F6E)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home_repair_service, color: Colors.white),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isDone ? Colors.green[100] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDone ? Icons.check_circle : Icons.access_time,
                      size: 12.sp,
                      color: isDone ? Colors.green : Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDone ? Colors.green : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(0.75, 0),
                    end: Alignment(95.27, 0),
                    colors: [Color(0xFFEC526A), Color(0xFFF77F6E)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'High',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Color(0xFFEC526A)),
              minHeight: 6.h,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              SizedBox(
                width: 80.w,
                child: Stack(
                  children: List.generate(
                    3,
                        (index) => Positioned(
                      left: index * 20.0,
                      child: CircleAvatar(
                        radius: 16.w,
                        backgroundColor: Colors.amber[100 + (index * 100)],
                        child: Text(
                          '👤',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                date,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.chat_bubble_outline, size: 16.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                '$comments',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}