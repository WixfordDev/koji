import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/app_color.dart';

class NotesWidget extends StatelessWidget {
  final List<String> notes;
  final Function(List<String>) onNotesChanged;

  const NotesWidget({
    super.key,
    required this.notes,
    required this.onNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Notes (Quotation Only)",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            InkWell(
              onTap: () {
                _showAddNoteDialog(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEC526A),
                      Color(0xFFF77F6E),
                    ],
                    stops: [0.0075, 0.9527],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18.r, color: Colors.white),
                    SizedBox(width: 4.w),
                    Text(
                      "Add Note",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        if (notes.isEmpty)
          Container(
            padding: EdgeInsets.all(40.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 48.r,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "No notes added yet",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...notes.asMap().entries.map((entry) {
            int index = entry.key;
            String note = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24.r,
                    height: 24.r,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      note,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _showEditNoteDialog(context, index, note);
                        },
                        icon: Icon(Icons.edit, size: 18.r, color: Colors.grey),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                      SizedBox(width: 12.w),
                      IconButton(
                        onPressed: () {
                          List<String> updatedNotes = List.from(notes);
                          updatedNotes.removeAt(index);
                          onNotesChanged(updatedNotes);
                        },
                        icon: Icon(Icons.delete, size: 18.r, color: Colors.red),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Text(
            "Add Note",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter note",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            InkWell(
              onTap: () {
                if (noteController.text.trim().isNotEmpty) {
                  List<String> updatedNotes = List.from(notes);
                  updatedNotes.add(noteController.text.trim());
                  onNotesChanged(updatedNotes);
                  Navigator.pop(context);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEC526A),
                      Color(0xFFF77F6E),
                    ],
                    stops: [0.0075, 0.9527],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  "Add",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditNoteDialog(BuildContext context, int index, String currentNote) {
    TextEditingController noteController =
    TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Text(
            "Edit Note",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter note",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            InkWell(
              onTap: () {
                if (noteController.text.trim().isNotEmpty) {
                  List<String> updatedNotes = List.from(notes);
                  updatedNotes[index] = noteController.text.trim();
                  onNotesChanged(updatedNotes);
                  Navigator.pop(context);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEC526A),
                      Color(0xFFF77F6E),
                    ],
                    stops: [0.0075, 0.9527],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  "Update",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}