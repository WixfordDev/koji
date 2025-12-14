// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:go_router/go_router.dart';

// import '../../../constants/app_color.dart';
// import '../../../shared_widgets/custom_button.dart';
// import '../../../shared_widgets/custom_text.dart';

// class SubmitTaskScreen extends StatefulWidget {
//   const SubmitTaskScreen({super.key});

//   @override
//   State<SubmitTaskScreen> createState() => _SubmitTaskScreenState();
// }

// class _SubmitTaskScreenState extends State<SubmitTaskScreen> {
//   DateTime? startDate;
//   DateTime? endDate;
//   TimeOfDay? startTime;
//   TimeOfDay? endTime;

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   void _showSignaturePopup() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Center(
//         child: Material(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12.r),
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 30.h),
//             child: SizedBox(
//               width: 358.w,
//               height: 382.h,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Customer Signature",
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   SizedBox(height: 10.h),
//                   Container(
//                     height: 150.h,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8.r),
//                       border: Border.all(color: Colors.grey.shade300),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     // child: Signature(
//                     //   controller: _signatureController,
//                     //   backgroundColor: Colors.white,
//                     // ),
//                   ),
//                   SizedBox(height: 30.h),
//                   // Submit Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 48.h,
//                     child: ElevatedButton(
//                       onPressed: () async {

//                       },
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.r),
//                         ),
//                         padding: EdgeInsets.zero,
//                         elevation: 0,
//                         backgroundColor: Colors.transparent,
//                       ),
//                       child: Ink(
//                         decoration: const BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment(0.1, -0.9),
//                             end: Alignment(0.8, 1.0),
//                             colors: [Color(0xFF4082FB), Color(0xFF4082FB)],
//                           ),
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                         ),
//                         child: Center(
//                           child: Text(
//                             "Submit",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 15.sp,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10.h),
//                   // Cancel Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 48.h,
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: Color(0xFF4082FB)),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.r),
//                         ),
//                         padding: EdgeInsets.symmetric(vertical: 14.h),
//                       ),
//                       child: Text(
//                         "No, Let Me Check",
//                         style: TextStyle(
//                           fontSize: 15.sp,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xFF4082FB),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ----------------------------------------------------
//   // ------------------ MAIN UI -------------------------
//   // ----------------------------------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         forceMaterialTransparency: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         titleSpacing: 0,
//         title: Row(
//           children: [
//             IconButton(
//               padding: EdgeInsets.zero,
//               icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.r),
//               onPressed: () => Navigator.pop(context),
//             ),
//             SizedBox(width: 12.w),
//             CustomText(
//               text: "Submit Task",
//               color: AppColor.secondaryColor,
//               fontSize: 20.sp,
//               fontWeight: FontWeight.w500,
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 20.h),

//               Text(
//                 "Attachment",
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               SizedBox(height: 4.h),
//               Text(
//                 "Format should be in .pdf .jpeg .png less than 5MB",
//                 style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//               ),
//               SizedBox(height: 12.h),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: List.generate(
//                   3,
//                       (index) => Container(
//                     width: 100.w,
//                     height: 100.w,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8.r),
//                       border: Border.all(
//                         color: Colors.grey.shade400,
//                         width: 1,
//                       ),
//                     ),
//                     child: Center(
//                       child: Icon(
//                         Icons.upload_rounded,
//                         size: 28.sp,
//                         color: Colors.grey.shade400,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 24.h),

//               _buildTextField(label: "Department", hint: "Handy Man"),
//               _buildTextField(label: "Service Category", hint: "Plumbing Service"),
//               _buildTextField(label: "Service Description", hint: "Plumbing Service", maxLines: 3),
//               _buildTextField(label: "Customer Name", hint: "Najibur Rahman"),
//               _buildTextField(label: "Customer Number", hint: "+650554955114"),
//               _buildTextField(label: "Customer Address", hint: "Dhaka, Bangladesh"),
//               _buildTextField(label: "Assign To", hint: "Koji Tech 123"),

//               _buildDateTimeRow(
//                 label: "Assign Date",
//                 startHint: startDate == null
//                     ? "Start Date"
//                     : "${startDate!.day}/${startDate!.month}/${startDate!.year}",
//                 endHint: endDate == null
//                     ? "End Date"
//                     : "${endDate!.day}/${endDate!.month}/${endDate!.year}",
//                 startOnTap: () => _pickDate(true),
//                 endOnTap: () => _pickDate(false),
//                 iconPath: "assets/icons/calendar.svg",
//               ),

//               _buildDateTimeRow(
//                 label: "Assign Time",
//                 startHint: startTime == null ? "Start Time" : startTime!.format(context),
//                 endHint: endTime == null ? "End Time" : endTime!.format(context),
//                 startOnTap: () => _pickTime(true),
//                 endOnTap: () => _pickTime(false),
//                 iconPath: "assets/icons/time.svg",
//               ),

//               _buildTextField(label: "Priority", hint: "Important"),
//               _buildTextField(label: "Difficulty", hint: "Medium"),
//               _buildDropdown(label: "Payment Method", hint: "Select Method"),
//               _buildDropdown(label: "Payment Status", hint: "Select Status"),

//               SizedBox(height: 30.h),

//               // 🔹 Popup Trigger Button
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   onPressed: _showSignaturePopup,
//                   style: OutlinedButton.styleFrom(
//                     side: BorderSide(color: Colors.grey.shade300, width: 1),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     padding: EdgeInsets.symmetric(vertical: 14.h),
//                   ),
//                   child: Text(
//                     "Add Extra Service",
//                     style: TextStyle(
//                       fontSize: 15.sp,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.h),

//               CustomButton(
//                 title: 'Confirm and Submit Task',
//                 onpress: () {},
//               ),

//               SizedBox(height: 40.h),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------- Helper Widgets ----------------

//   Widget _buildTextField({
//     required String label,
//     required String hint,
//     int maxLines = 1,
//   }) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 16.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
//           SizedBox(height: 6.h),
//           TextField(
//             maxLines: maxLines,
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle: TextStyle(color: Colors.grey.shade600),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.r),
//                 borderSide: BorderSide(color: Colors.grey.shade400),
//               ),
//               contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateTimeRow({
//     required String label,
//     required String startHint,
//     required String endHint,
//     required VoidCallback startOnTap,
//     required VoidCallback endOnTap,
//     required String iconPath,
//   }) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 16.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
//           SizedBox(height: 6.h),
//           Row(
//             children: [
//               Expanded(
//                 child: GestureDetector(
//                   onTap: startOnTap,
//                   child: AbsorbPointer(
//                     child: TextField(
//                       decoration: InputDecoration(
//                         prefixIcon: Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 10.w),
//                           child: SvgPicture.asset(
//                             iconPath,
//                             width: 17.w,
//                             height: 17.h,
//                             colorFilter: ColorFilter.mode(
//                               Colors.grey.shade600,
//                               BlendMode.srcIn,
//                             ),
//                           ),
//                         ),
//                         hintText: startHint,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8.r),
//                           borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
//                         ),
//                         contentPadding:
//                         EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: GestureDetector(
//                   onTap: endOnTap,
//                   child: AbsorbPointer(
//                     child: TextField(
//                       decoration: InputDecoration(
//                         prefixIcon: Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 10.w),
//                           child: SvgPicture.asset(
//                             iconPath,
//                             width: 17.w,
//                             height: 17.h,
//                             colorFilter: ColorFilter.mode(
//                               Colors.grey.shade600,
//                               BlendMode.srcIn,
//                             ),
//                           ),),
//                         hintText: endHint,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8.r),
//                           borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
//                         ),
//                         contentPadding:
//                         EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDropdown({required String label, required String hint}) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 16.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
//           SizedBox(height: 6.h),
//           DropdownButtonFormField<String>(
//             icon: SvgPicture.asset(
//               "assets/icons/arrowdown.svg",
//             ),
//             decoration: InputDecoration(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.r),
//                 borderSide: BorderSide(color: Colors.grey.shade400),
//               ),
//               contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
//             ),
//             hint: Text(hint, style: TextStyle(color: Colors.grey.shade600)),
//             items: const [
//               DropdownMenuItem(value: 'option1', child: Text('Option 1')),
//               DropdownMenuItem(value: 'option2', child: Text('Option 2')),
//             ],
//             onChanged: (value) {},
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------------- Date & Time Pickers ----------------

//   Future<void> _pickDate(bool isStart) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStart) {
//           startDate = picked;
//         } else {
//           endDate = picked;
//         }
//       });
//     }
//   }

//   Future<void> _pickTime(bool isStart) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStart) {
//           startTime = picked;
//         } else {
//           endTime = picked;
//         }
//       });
//     }
//   }
// }
