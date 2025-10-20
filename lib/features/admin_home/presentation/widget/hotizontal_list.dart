import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared_widgets/custom_text.dart';

class HorizontalListExample extends StatefulWidget {
  final List<Map<String, dynamic>> items; // pass your data list
  final Function(Map<String, dynamic>) onItemSelected; // callback when tapped

  const HorizontalListExample({
    super.key,
    required this.items,
    required this.onItemSelected,
  });

  @override
  State<HorizontalListExample> createState() => _HorizontalListExampleState();
}

class _HorizontalListExampleState extends State<HorizontalListExample> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length,
        separatorBuilder: (context, index) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              widget.onItemSelected(item); // return object
            },
            child: Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                border: isSelected?null: Border.all(
                  width: 1,
                  color: Colors.black
                ),
                color: isSelected ? Colors.red : Colors.white,
                borderRadius: BorderRadius.circular(30.r),
              ),
              alignment: Alignment.center,
              child:     CustomText(
                text: "${item["title"]}",
                fontSize: 10.sp,
                color:  isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
                top: 0.h,
                bottom: 0.h,
              ),
              // child: Text(
              //   item["title"], // show map value
              //   style: const TextStyle(color: Colors.white),
              // ),
            ),
          );
        },
      ),
    );
  }
}
