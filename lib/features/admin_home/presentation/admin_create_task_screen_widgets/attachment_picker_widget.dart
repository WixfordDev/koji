import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AttachmentPickerWidget extends StatefulWidget {
  final List<File> selectedImages;
  final Function(File file) onImageAdded;
  final Function(int index) onImageRemoved;

  const AttachmentPickerWidget({
    Key? key,
    required this.selectedImages,
    required this.onImageAdded,
    required this.onImageRemoved,
  }) : super(key: key);

  @override
  State<AttachmentPickerWidget> createState() => _AttachmentPickerWidgetState();
}

class _AttachmentPickerWidgetState extends State<AttachmentPickerWidget> {
  final ImagePicker _picker = ImagePicker();

  static const int _maxFileSizeBytes = 20 * 1024 * 1024; // 20MB

  Future<void> _pickImage() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      for (final image in images) {
        final bytes = await image.readAsBytes();
        if (bytes.length > _maxFileSizeBytes) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${image.name} exceeds 20MB limit'), backgroundColor: Colors.red),
            );
          }
          continue;
        }
        final dir = await getApplicationDocumentsDirectory();
        final ext = image.path.contains('.') ? '.${image.path.split('.').last}' : '.jpg';
        final fileName = 'attachment_${DateTime.now().millisecondsSinceEpoch}$ext';
        final permanent = File('${dir.path}/$fileName');
        await permanent.writeAsBytes(bytes);
        widget.onImageAdded(permanent);
      }
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
          "Format should be in .jpeg .png less than 20MB",
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            ...List.generate(widget.selectedImages.length, (index) {
              return Stack(
                children: [
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        widget.selectedImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4.w,
                    right: 4.w,
                    child: GestureDetector(
                      onTap: () => widget.onImageRemoved(index),
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: Icon(Icons.close, size: 12.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }),
            GestureDetector(
              onTap: _pickImage,
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
                  color: const Color(0xFFF5F5FF),
                ),
                child: Center(
                  child: Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 28.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
