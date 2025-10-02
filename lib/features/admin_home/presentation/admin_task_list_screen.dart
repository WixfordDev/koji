import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/features/admin_home/presentation/widget/hotizontal_list.dart';

class AdminTaskListScreen extends StatefulWidget {
  const AdminTaskListScreen({super.key});

  @override
  State<AdminTaskListScreen> createState() => _AdminTaskListScreenState();
}

class _AdminTaskListScreenState extends State<AdminTaskListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("My Task"), centerTitle: true),
      body: Padding(padding: EdgeInsets.all(10.sp),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HorizontalListExample(
          items: [
            {"id": 1, "title": "Apple"},
            {"id": 2, "title": "Banana"},
            {"id": 3, "title": "Orange"},
            {"id": 3, "title": "Orange"},
            {"id": 3, "title": "Orange"},
          ],
          onItemSelected: (selectedItem) {
            print("You clicked: ${selectedItem["title"]}, ID: ${selectedItem["id"]}");
          },
        ),
        SizedBox(height: 10.h,),
        Expanded(child: ListView.builder(
          shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: 12,
            itemBuilder: (context,index){
              return  Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2), // shadow color
                      spreadRadius: 2, // how much it spreads
                      blurRadius: 6, // how soft the shadow looks
                      offset: Offset(2, 3), // horizontal, vertical shift
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding:EdgeInsets.all(5.sp),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20.r)
                          ),
                          child: Icon(Icons.rocket_launch_outlined,color: Colors.white,),
                        ),
                        SizedBox(width: 5.w,),
                        Text("Hand Painting Service",style: TextStyle(fontSize: 18.sp),),

                      ],
                    ),
                    SizedBox(height: 10.h,),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5.sp),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2), // shadow color
                                spreadRadius: 2, // how much it spreads
                                blurRadius: 6, // how soft the shadow looks
                                offset: Offset(2, 3), // horizontal, vertical shift
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.currency_lira),
                              Text("In Progress",style: TextStyle(fontSize: 17.sp),)
                            ],
                          ),
                        ),
                        SizedBox(width: 10,),
                        Container(
                          padding: EdgeInsets.all(5.sp),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2), // shadow color
                                spreadRadius: 2, // how much it spreads
                                blurRadius: 6, // how soft the shadow looks
                                offset: Offset(2, 3), // horizontal, vertical shift
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.currency_lira,color: Colors.white,),
                              Text("In Progress",style: TextStyle(fontSize: 17.sp,color: Colors.white),)
                            ],
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 10.h,),
                    LinearProgressIndicator(
                      value: 0.14, // null = indeterminate
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(10.r),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                    SizedBox(height: 10.h,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.person),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(5.sp),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2), // shadow color
                                    spreadRadius: 2, // how much it spreads
                                    blurRadius: 6, // how soft the shadow looks
                                    offset: Offset(2, 3), // horizontal, vertical shift
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_month),
                                  Text("27 Step",style: TextStyle(fontSize: 17.sp),)
                                ],
                              ),
                            ),
                            SizedBox(width: 10,),
                            Container(
                              padding: EdgeInsets.all(5.sp),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2), // shadow color
                                    spreadRadius: 2, // how much it spreads
                                    blurRadius: 6, // how soft the shadow looks
                                    offset: Offset(2, 3), // horizontal, vertical shift
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.message,color: Colors.white,),
                                  Text("2",style: TextStyle(fontSize: 17.sp,color: Colors.white),)
                                ],
                              ),
                            ),

                          ],
                        ),
                      ],
                    )
                  ],
                ),
              );
            }
          ))


      ],
    ),
    ),
      bottomSheet: Container(
        height: 80.h,
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.all(10.sp),
        child: Center(
          child: Container(
            alignment: Alignment.center,
            height: 50.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10.r)
                
            ),
            child: Text("Create Task",style:TextStyle(color: Colors.white),),
          ),
        ),
      ),
    
    );
  }
}
