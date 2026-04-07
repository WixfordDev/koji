import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AttachmentPickerWidget extends StatefulWidget {
  final List<File?> selectedImages;
  final Function(int index, File file) onImagePicked;

  const AttachmentPickerWidget({
    Key? key,
    required this.selectedImages,
    required this.onImagePicked,
  }) : super(key: key);

  @override
  State<AttachmentPickerWidget> createState() => _AttachmentPickerWidgetState();
}

class _AttachmentPickerWidgetState extends State<AttachmentPickerWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int index) async {
    // No quality params — avoids scaled_ temp files that get deleted before upload
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Read bytes immediately, then write to permanent storage
      final bytes = await image.readAsBytes();
      final dir = await getApplicationDocumentsDirectory();
      final ext = image.path.contains('.') ? '.${image.path.split('.').last}' : '.jpg';
      final fileName = 'attachment_${DateTime.now().millisecondsSinceEpoch}$ext';
      final permanent = File('${dir.path}/$fileName');
      await permanent.writeAsBytes(bytes);
      widget.onImagePicked(index, permanent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Attachment",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "Format should be in .mp4 .pdf .jpeg .png less than 5MB",
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            3,
                (index) => GestureDetector(
              onTap: () => _pickImage(index),
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  color: Color(0xFFF5F5FF),
                ),
                child: widget.selectedImages[index] == null
                    ? Center(
                  child: Icon(
                    Icons.upload_rounded,
                    size: 28.sp,
                    color: Colors.grey.shade400,
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.file(
                    widget.selectedImages[index]!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}