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

class AdminEmployeeRequestScreen extends StatefulWidget {
  const AdminEmployeeRequestScreen({super.key});

  @override
  State<AdminEmployeeRequestScreen> createState() =>
      _AdminEmployeeRequestScreenState();
}

class _AdminEmployeeRequestScreenState
    extends State<AdminEmployeeRequestScreen> {

  TextEditingController searchCtrl = TextEditingController();




  late AdminHomeController adminHomeController;

  @override
  void initState() {
    super.initState();
    adminHomeController = Get.find<AdminHomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adminHomeController.getEmployeeRequest();


    });
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
            CustomAuthTextField(controller: searchCtrl, hintText: "Search"),

            SizedBox(height: 12.h),

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

            SizedBox(height: 12.h),

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
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: user.image != null && user.image!.isNotEmpty
                                ? NetworkImage(user.image!)
                                : null,
                            child: user.image == null || user.image!.isEmpty
                                ? Icon(Icons.person)
                                : null,
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
}
