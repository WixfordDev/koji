import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/features/admin_home/presentation/admin_employee_view.dart';
import 'package:koji/features/admin_home/presentation/widget/custom_loader.dart';
import 'package:koji/features/admin_home/presentation/widget/hotizontal_list.dart';
import 'package:koji/shared_widgets/custom_auth_text_field.dart';
import 'package:koji/shared_widgets/custom_button.dart';
import 'package:koji/shared_widgets/custom_text.dart';
import '../../../controller/admincontroller/admin_home_controller.dart';
import '../../../services/api_constants.dart';

class AdminEmployeeRequestScreen extends StatefulWidget {
  const AdminEmployeeRequestScreen({super.key});

  @override
  State<AdminEmployeeRequestScreen> createState() =>
      _AdminEmployeeRequestScreenState();
}

class _AdminEmployeeRequestScreenState
    extends State<AdminEmployeeRequestScreen> {

  TextEditingController searchCtrl = TextEditingController();
  String selectedFilter = "All";



  late AdminHomeController adminHomeController;

  @override
  void initState() {
    super.initState();
    adminHomeController = Get.find<AdminHomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adminHomeController.getEmployeeRequest();


    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Filter by",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              _buildFilterOption("Employee List", "All"),
              _buildFilterOption("Employee Request", "All"),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  String _getImageUrl(String imageUrl) {
    // If the image URL is already a full URL (starts with http:// or https://), return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    // Otherwise, append it to the base URL from the API constants
    String baseUrl = ApiConstants.imageBaseUrl; // Using the image base URL from API constants
    return "$baseUrl$imageUrl";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee"),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Column(
          children: [

            SizedBox(height: 12.h),

            // Search and Filter Row
            Row(
              children: [
                // Search Field
                Expanded(
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[400],
                          size: 22.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // Filter Dropdown Button
                GestureDetector(
                  onTap: _showFilterBottomSheet,
                  child: Container(
                    height: 48.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "All",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),


            HorizontalListExample(
              items: [
                {"id": 1, "title": "All Shift"},
                {"id": 2, "title": "Morning Shift"},
                {"id": 3, "title": "Evening Shift"},
                {"id": 3, "title": "Night Shift"},
              ],
              onItemSelected: (selectedItem) {
                print(
                  "You clicked: ${selectedItem["title"]}, ID: ${selectedItem["id"]}",
                );
              },
            ),

            SizedBox(height: 28.h),

            Expanded(
              child: GetX<AdminHomeController>(
                builder: (controller) {
                  if (controller.getEmployeeRequestLoading.value) {
                    return const Center(child: CustomLoader());
                  }

                  final employees = controller.employeeRequest.value.results ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final user = employees[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            child: ClipOval(
                              child: user.image != null && user.image!.isNotEmpty
                                  ? Image.network(
                                      _getImageUrl(user.image!),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[300],
                                          child: Icon(Icons.person, color: Colors.grey[600]),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.person, color: Colors.grey[600]),
                                    ),
                            ),
                          ),
                          title: CustomText(
                            text: "${user.firstName ?? user.fullName ?? "N/A"}",
                            fontSize: 16.h,
                            textAlign: TextAlign.start,
                            fontWeight: FontWeight.w600,
                          ),
                          subtitle: CustomText(
                            text: user.role ?? "No role",
                            textAlign: TextAlign.start,
                            color: Colors.black54,
                          ),
                          trailing: CustomButton(
                            loaderIgnore: true,
                            width: 80.w,
                            fontSize: 13.h,
                            boderColor: Colors.transparent,
                            color: Color(0xffF4726D),
                            title: "View",
                            onpress: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AdminEmployeeView(
                                    employee: user,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),


          ],
        ),
      ),
    );
  }


  Widget _buildFilterOption(String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: selectedFilter == value
          ? Icon(Icons.check, color: Color(0xffF4726D))
          : null,
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
        Navigator.pop(context);
        // Add your filter logic here
      },
    );
  }

}
