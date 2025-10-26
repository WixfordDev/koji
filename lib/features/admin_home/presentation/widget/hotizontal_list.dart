import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
              // width: 80.w,
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey,
                ),
                color: isSelected ? Colors.red : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Center(
                child: Text(
                  item["title"], // show map value
                  style: TextStyle(
                    fontSize: 13.h,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
