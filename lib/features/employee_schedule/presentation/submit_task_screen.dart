import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koji/models/task_model.dart';
import 'package:koji/services/api_client.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class TaskScreen extends StatefulWidget {
  final String taskId;
  final Map<String, dynamic> taskData;

  const TaskScreen({super.key, required this.taskId, required this.taskData});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  bool _isSubmitting = false;
  String _selectedPaymentMethod = 'Cash';
  String _selectedPaymentStatus = 'Payment Paid';
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // Original services
  final List<Map<String, dynamic>> _originalServices = [];

  @override
  void initState() {
    super.initState();
    _loadOriginalServices();
  }

  // Load original services from taskData
  void _loadOriginalServices() {
    var servicesData = widget.taskData['service'];

    if (servicesData is List<Service>) {
      // Handle Service objects
      for (var service in servicesData) {
        _originalServices.add({
          'name': service.name ?? 'N/A',
          'price': service.price?.toDouble() ?? 0.0,
          'quantity': service.quantity?.toString() ?? '1',
        });
      }
    } else if (servicesData is List) {
      // Handle Maps or other list formats
      for (var service in servicesData) {
        if (service is Map<String, dynamic>) {
          _originalServices.add({
            'name': service['name'] ?? 'N/A',
            'price': (service['price'] is double)
                ? service['price']
                : double.tryParse(service['price'].toString()) ?? 0.0,
            'quantity': service['quantity']?.toString() ?? '1',
          });
        }
      }
    }
  }

  // Extra services that can be added
  final List<Map<String, dynamic>> _extraServices = [];

  // GST percentage
  final double _gstPercentage = 9.0;

  double get _subtotal {
    double subtotal = 0;
    // Add original services
    for (var service in _originalServices) {
      subtotal += service['price'];
    }
    // Add extra services
    for (var service in _extraServices) {
      subtotal += service['price'];
    }
    return subtotal;
  }

  double get _gstAmount {
    return (_subtotal * _gstPercentage) / 100;
  }

  double get _totalPrice {
    return _subtotal + _gstAmount;
  }

  // JSON data structure
  Map<String, String> get _taskJson {
    // Combine original and extra services
    List<Map<String, dynamic>> allServices = [];

    // Add original services
    allServices.addAll(
      _originalServices.map(
        (service) => {
          'name': service['name'],
          'price': service['price'].toString(),
          'quantity': service['quantity'],
        },
      ),
    );

    // Add extra services
    allServices.addAll(
      _extraServices.map(
        (service) => {
          'name': service['name'],
          'price': service['price'].toString(),
          'quantity': service['quantity'],
        },
      ),
    );

    return {
      "customerName": widget.taskData['customerName'] ?? 'N/A',
      "customerNumber": widget.taskData['customerNumber'] ?? 'N/A',
      "customerAddress": widget.taskData['customerAddress'] ?? 'N/A',
      "customerEmail": widget.taskData['customerEmail'] ?? 'N/A',
      "service": json.encode(allServices),
      "totalAmount": "$_totalPrice",
      "paymentMethod": _selectedPaymentMethod,
      "paymentStatus": _selectedPaymentStatus,
      "notes": widget.taskData['notes'] ?? '',
    };
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 3) {
      Get.snackbar(
        'Maximum Limit',
        'You can only select up to 3 images',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final List<XFile>? images = await _picker.pickMultiImage(
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (images != null) {
      int remainingSlots = 3 - _selectedImages.length;
      if (images.length > remainingSlots) {
        Get.snackbar(
          'Limit Exceeded',
          'Only $remainingSlots more images allowed',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }

      final allowedImages = images.take(remainingSlots).toList();

      setState(() {
        _selectedImages.addAll(allowedImages.map((image) => File(image.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitTask() async {
    if (_selectedImages.isEmpty) {
      Get.snackbar(
        'Signature Required',
        'Please add customer signature before submitting',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Show Customer Signature Dialog first
    _showCustomerSignatureDialog();
  }

  void _showCustomerSignatureDialog() {
    bool isUploading = false;
    final GlobalKey<SfSignaturePadState> _signatureKey = GlobalKey();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Customer Signature',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Signature pad
                  Container(
                    width: double.infinity,
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SfSignaturePad(
                      key: _signatureKey,
                      backgroundColor: Colors.white,
                      strokeColor: Colors.black,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Clear signature button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        _signatureKey.currentState?.clear();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.clear, size: 16.sp, color: Colors.red),
                          SizedBox(width: 4.w),
                          Text(
                            'Clear Signature',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isUploading
                          ? null
                          : () async {
                              // Get the signature as an image
                              final signatureImage = await _signatureKey
                                  .currentState
                                  ?.toImage();

                              if (signatureImage == null) {
                                Get.snackbar(
                                  'Required',
                                  'Please add customer signature',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              setDialogState(() {
                                isUploading = true;
                              });

                              try {
                                // Convert the signature image to a file
                                final ByteData? byteData = await signatureImage
                                    .toByteData(format: ImageByteFormat.png);
                                if (byteData == null) {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to process signature',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                final Uint8List pngBytes = byteData.buffer
                                    .asUint8List();
                                final tempDir = await getTemporaryDirectory();
                                final file = await File(
                                  '${tempDir.path}/signature.png',
                                ).create();
                                await file.writeAsBytes(pngBytes);

                                // Call accept API with signature
                                List<MultipartBody> signatureBody = [
                                  MultipartBody("signature", file),
                                ];

                                final acceptResponse =
                                    await ApiClient.postMultipartData(
                                      '/tasks/${widget.taskId}/accept',
                                      {},
                                      multipartBody: signatureBody,
                                    );

                                if (acceptResponse.statusCode == 200) {
                                  // Now submit the task with attachments
                                  List<MultipartBody> photoList = [];
                                  for (var photo in _selectedImages) {
                                    photoList.add(
                                      MultipartBody("attachments", photo),
                                    );
                                  }

                                  final submitResponse =
                                      await ApiClient.postMultipartData(
                                        '/tasks/${widget.taskId}/submit',
                                        _taskJson,
                                        multipartBody: photoList,
                                      );

                                  if (submitResponse.statusCode == 200) {
                                    // Close signature dialog
                                    Navigator.pop(dialogContext);
                                    // Show success dialog
                                    _showSuccessDialog();
                                  } else {
                                    Get.snackbar(
                                      'Error',
                                      'Failed to submit task',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to accept task',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  'Failed to process: $e',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              } finally {
                                setDialogState(() {
                                  isUploading = false;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A90E2),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: isUploading
                          ? SizedBox(
                              height: 24.h,
                              width: 24.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: isUploading
                          ? null
                          : () => Navigator.pop(dialogContext),
                      child: Text(
                        'No, Let Me Check',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: Color(0xFF4A90E2).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF4A90E2),
                  size: 50.sp,
                ),
              ),

              SizedBox(height: 20.h),

              // Success Title
              Text(
                'Success',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 12.h),

              // Success Message
              Text(
                'Your task has been submitted successfully.\nYou will be notified once it is reviewed by\nyour admin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              SizedBox(height: 24.h),

              // View List Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close success dialog
                    Navigator.pop(context); // Go back from TaskScreen
                    Navigator.pop(context); // Go back from TaskDetailsScreen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A90E2),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'View List',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddServiceDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Extra Service',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20.h),

              // Service Name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Service Price
              TextField(
                controller: priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  prefixText: '\$',
                ),
              ),

              SizedBox(height: 24.h),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final price =
                            double.tryParse(priceController.text) ?? 0.0;

                        if (name.isNotEmpty && price > 0) {
                          setState(() {
                            _extraServices.add({
                              'name': name,
                              'price': price,
                              "quantity": "1",
                            });
                          });
                          Navigator.pop(context);
                        } else {
                          Get.snackbar(
                            'Error',
                            'Please enter valid service name and price',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeExtraService(int index) {
    setState(() {
      _extraServices.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Task',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              // Attachment & Signature Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attachment',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Format should be in .pdf .jpeg .png less than 5MB',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Image Grid
                    if (_selectedImages.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.w,
                          mainAxisSpacing: 8.h,
                          childAspectRatio: 1,
                        ),
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  image: DecorationImage(
                                    image: FileImage(_selectedImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4.w,
                                right: 4.w,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 14.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                    SizedBox(height: 16.h),

                    // Add Signature Button
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: double.infinity,
                        height: 120.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 32.sp,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              _selectedImages.isEmpty
                                  ? 'Browse Files from device'
                                  : 'Tap to add more (${3 - _selectedImages.length} remaining)',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_selectedImages.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text(
                                  '${_selectedImages.length}/3 images selected',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Service List Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service List',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Original services (non-editable)
                    if (_originalServices.isNotEmpty)
                      ...List.generate(_originalServices.length, (index) {
                        final service = _originalServices[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _buildServiceItem(
                            service['name'],
                            service['price'],
                            service['quantity'],
                          ),
                        );
                      }),

                    // Show message if no original services
                    if (_originalServices.isEmpty && _extraServices.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Text(
                          'No services available',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),

                    // Extra services (with delete option)
                    ...List.generate(_extraServices.length, (index) {
                      final service = _extraServices[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildServiceItem(
                          service['name'],
                          service['price'],
                          service['quantity'],
                          showDelete: true,
                          onDelete: () => _removeExtraService(index),
                        ),
                      );
                    }),

                    SizedBox(height: 8.h),

                    // GST Row
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GST $_gstPercentage%',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '\$${_gstAmount.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Total Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Price',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '\$${_totalPrice.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A90E2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Payment Method Section
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _radioItem(
                          title: 'Cash',
                          value: 'Cash',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (val) {
                            setState(() {
                              _selectedPaymentStatus = val!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Payment Method Section
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        _radioItem(
                          title: 'Cash',
                          value: 'Cash',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (val) {
                            setState(() {
                              _selectedPaymentMethod = val!;
                            });
                          },
                        ),
                        SizedBox(width: 20.w),
                        _radioItem(
                          title: 'Online Banking',
                          value: 'Online Banking',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (val) {
                            setState(() {
                              _selectedPaymentMethod = val!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),
              // Add Extra Service Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _showAddServiceDialog,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    side: BorderSide(color: Color(0xFF4A90E2), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20.sp, color: Color(0xFF4A90E2)),
                      SizedBox(width: 8.w),
                      Text(
                        'Add Extra Service',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A90E2),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 24.h,
                          width: 24.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Confirm & Submit Task',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 12.h),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'No, Let Me Check',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _radioItem({
    required String title,
    required String value,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
        Text(title, style: TextStyle(fontSize: 14.sp)),
      ],
    );
  }

  Widget _buildServiceItem(
    String name,
    double price,
    String? quantity, {
    bool showDelete = false,
    VoidCallback? onDelete,
  }) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (showDelete)
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.1),
                      ),
                      child: Icon(Icons.close, size: 16.sp, color: Colors.red),
                    ),
                  ),
                if (showDelete) SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${price.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
