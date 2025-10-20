import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/shared_widgets/custom_button.dart';

import '../../../constants/app_color.dart';
import '../../../shared_widgets/custom_text.dart';

class MyTaskScreen extends StatefulWidget {
  const MyTaskScreen({super.key});

  @override
  State<MyTaskScreen> createState() => _MyTaskScreenState();
}

class _MyTaskScreenState extends State<MyTaskScreen> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              text: "My Task",
              color: AppColor.secondaryColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),

      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // Attachment Section
              Text(
                "Attachment",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Format should be in .pdf .jpeg .png less than 5MB",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
              SizedBox(height: 12.h),

              // Upload Boxes Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  3,
                      (index) => Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.upload_rounded,
                        size: 28.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // TextFields
              _buildTextField(label: "Department", hint: "Handy Man"),
              _buildTextField(label: "Service Category", hint: "Plumbing Service"),
              _buildTextField(label: "Service Description", hint: "Plumbing Service", maxLines: 3),
              _buildTextField(label: "Customer Name", hint: "Najibur Rahman"),
              _buildTextField(label: "Customer Number", hint: "+650554955114"),
              _buildTextField(label: "Customer Address", hint: "Dhaka, Bangladesh"),
              _buildTextField(label: "Assign To", hint: "Koji Tech 123"),

              // Date Pickers
              _buildDateTimeRow(
                label: "Assign Date",
                startHint: startDate == null
                    ? "Start Date"
                    : "${startDate!.day}/${startDate!.month}/${startDate!.year}",
                endHint: endDate == null
                    ? "End Date"
                    : "${endDate!.day}/${endDate!.month}/${endDate!.year}",
                startOnTap: () => _pickDate(true),
                endOnTap: () => _pickDate(false),
                icon: Icons.calendar_today_outlined,
              ),

              // Time Pickers
              _buildDateTimeRow(
                label: "Assign Time",
                startHint:
                startTime == null ? "Start Time" : startTime!.format(context),
                endHint:
                endTime == null ? "End Time" : endTime!.format(context),
                startOnTap: () => _pickTime(true),
                endOnTap: () => _pickTime(false),
                icon: Icons.access_time_outlined,
              ),


              _buildTextField(label: "Priority", hint: "Important"),
              _buildTextField(label: "Difficulty", hint: "Medium"),

              SizedBox(height: 30.h),




              CustomButton(
                title: 'Accept',
                onpress: () {
                  context.push('/submitTaskScreen');

                },),


              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: TextField
  Widget _buildTextField({required String label, required String hint, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 6.h),
          TextField(
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeRow({
    required String label,
    required String startHint,
    required String endHint,
    required VoidCallback startOnTap,
    required VoidCallback endOnTap,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: startOnTap,
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon:
                        Icon(icon, color: Colors.grey.shade600, size: 20.sp),
                        hintText: startHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide:
                          BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 12.h),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: endOnTap,
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon:
                        Icon(icon, color: Colors.grey.shade600, size: 20.sp),
                        hintText: endHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide:
                          BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 12.h),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }
}
