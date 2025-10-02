import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.person),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Md. Omar Faruk"),
            Text("admin")
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.notification_add))
        ],

      ),

      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
             headerCardWidget(text1: 'Total Employee', text2: '4005'),
             headerCardWidget(text1: 'Total Employee', text2: '4005'),
           ],),
            SizedBox(
              height: 10.h,
            ),
           headerTitle(text1: "Quick Action"),
            gridCard(),
            SizedBox(
              height: 10.h,
            ),
            headerTitle(text1: "Today's Attendance summary"),
            Container(
              padding: EdgeInsets.all(5.sp),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2), // shadow color
                      spreadRadius: 2, // how much it spreads
                      blurRadius: 6,   // how soft the shadow looks
                      offset: Offset(2, 3), // horizontal, vertical shift
                    ),
                  ]
              ),
              child: Column(children: [
                cardWidgerRow(),
                cardWidgerRow(),
                cardWidgerRow(),
              ],),
            ),
            headerTitle(text1: "Today's Task summary"),
            Container(
              padding: EdgeInsets.all(5.sp),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2), // shadow color
                      spreadRadius: 2, // how much it spreads
                      blurRadius: 6,   // how soft the shadow looks
                      offset: Offset(2, 3), // horizontal, vertical shift
                    ),
                  ]
              ),
              child: Column(children: [
                cardWidgerRow(),
                cardWidgerRow(),
                cardWidgerRow(),
              ],),
            ),

          ],
        ),
        ),
      ),
    );
  }

  Widget cardWidgerRow(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              height:10,
              width: 10,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(50)
              ),
            ),
            SizedBox(width: 10,),
            Text("Employee",style: TextStyle(fontSize: 20.sp),),
          ],
        ),
        Row(
          children: [
            Text("103",style: TextStyle(fontSize: 20.sp),),
            SizedBox(width: 10,),
            Icon(Icons.arrow_forward_ios)

          ],
        ),

      ],
    );
  }

  Widget headerCardWidget(
  {
  required String text1,
  required String text2
  }
      ){
    return Container(
      padding: EdgeInsets.all(5.sp),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2), // shadow color
              spreadRadius: 2, // how much it spreads
              blurRadius: 6,   // how soft the shadow looks
              offset: Offset(2, 3), // horizontal, vertical shift
            ),
          ]
      ),
      child: Row(
          children: [
            Icon(Icons.person,size: 60,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(text1),
                Text(text2,style: TextStyle(fontSize: 40),),

              ],
            )
          ]
      ),
    );
  }
  Widget gridCard(){
    return    Container(
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2), // shadow color
              spreadRadius: 2, // how much it spreads
              blurRadius: 6,   // how soft the shadow looks
              offset: Offset(2, 3), // horizontal, vertical shift
            ),
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.outbond_rounded,size: 50,),
          SizedBox(
            height: 10.h,
          ),
          Text("View",style: TextStyle(fontSize: 20.sp),),
          Text("Attendance",style: TextStyle(fontSize: 30.sp),)
        ],
      ),
    );
  }

  Widget headerTitle({required String text1}){
    return  Text(text1,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,),);
  }
}
