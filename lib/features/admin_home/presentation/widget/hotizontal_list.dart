import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HorizontalListExample extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>) onItemSelected;

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
              widget.onItemSelected(item);
            },
            child: Container(
              width: isSelected ? 77.w : 110.w,
              height: 36.h,
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: isSelected
                    ? Border.all(color: Colors.transparent)
                    : Border.all(color: const Color(0xFFC8C8C8)),
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xffEC526A), Color(0xffF77F6E)],
                        begin: Alignment(0.00, -1.00),
                        end: Alignment(0.00, 1.00),
                        stops: [0.00, 0.95],
                      )
                    : null,
                color: isSelected ? null : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  item["title"],
                  style: TextStyle(
                    fontSize: 13.h,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF717171),
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
