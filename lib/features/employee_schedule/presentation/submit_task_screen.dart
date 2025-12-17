import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koji/models/task_model.dart';
import 'package:koji/services/api_client.dart';

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

  // Extra services that can be added
  final List<Map<String, dynamic>> _extraServices = [];

  // GST percentage
  final double _gstPercentage = 9.0;

  double get _subtotal {
    double subtotal = 0;
    // Add original service
    var servicesData = widget.taskData['service'];
    if (servicesData is List<Service>) {
      // Handle Service objects
      for (var service in servicesData) {
        subtotal += service.price?.toDouble() ?? 0.0;
      }
    } else {
      // Handle Maps (existing format) for backward compatibility
      for (var service in servicesData) {
        subtotal += service['price'];
      }
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
    // Convert Service objects to Maps if needed
    var serviceData = widget.taskData['service'];
    List<Map<String, dynamic>> convertedServices = [];

    if (serviceData is List<Service>) {
      // Convert Service objects to Maps
      convertedServices = serviceData.map((service) => {
        'name': service.name ?? 'N/A',
        'price': service.price?.toString() ?? '0',
        'quantity': service.quantity?.toString() ?? '1',
        'id': service.id,
      }).toList();
    } else if (serviceData is List<Map<String, dynamic>>) {
      // Already in the correct format
      convertedServices = serviceData;
    } else {
      // Fallback to empty list
      convertedServices = [];
    }

    return {
      "customerName": widget.taskData['customerName'] ?? 'N/A',
      "customerNumber": widget.taskData['customerNumber'] ?? 'N/A',
      "customerAddress": widget.taskData['customerAddress'] ?? 'N/A',
      "customerEmail": widget.taskData['customerEmail'] ?? 'N/A',
      "service": json.encode(convertedServices), // Encode to JSON string
      // "originalServices": "$_originalServices",
      // "extraServices": "$_extraServices",
      // "subtotal": "$_subtotal",
      // "gstPercentage": "$_gstPercentage",
      // "gstAmount": "$_gstAmount",
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

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Here you would typically upload images to server first
      // Then send the task data with image URLs

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      List<MultipartBody> photoList = [];
      for (var photos in _selectedImages) {
        photoList.add(MultipartBody("attachments", photos));
      }
      List<MultipartBody> multipartBody = photoList ?? [];

      // Call the API with the JSON data
      final response = await ApiClient.postMultipartData(
        '/tasks/${widget.taskId}/submit', // Replace with your actual API endpoint
        _taskJson,
        multipartBody: photoList,
      );

      if (response.statusCode == 200) {
        // Show success dialog
        _showSuccessDialog();
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit task. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit task: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
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
                    Navigator.pop(context); // Close dialog
                    Get.back(); // Go back to previous screen
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
              // Customer Information
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
                    _buildCustomerInfo(
                      'Customer Number',
                      widget.taskData['customerNumber'] ?? '+880 1757054846',
                    ),
                    SizedBox(height: 12.h),
                    _buildCustomerInfo(
                      'Customer Address',
                      widget.taskData['customerAddress'] ?? 'Dhaka, Bangladesh',
                    ),
                    SizedBox(height: 12.h),
                    _buildCustomerInfo(
                      'Assign To',
                      widget.taskData['assignTo'] ?? 'Koji Tech 123',
                    ),
                  ],
                ),
              ),

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
                    SizedBox(height: 20.h),

                    // Customer Signature Title
                    Text(
                      'Customer Signature',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),

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
                                  ? 'Tap to add signature'
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
                    SizedBox(height: 20.h),

                    // Original services (non-editable)
                    for (var service in _originalServices)
                      _buildServiceItem(
                        service['name'],
                        service['price'],
                        service['quantity'],
                      ),

                    // Extra services (with delete option)
                    for (int i = 0; i < _extraServices.length; i++)
                      Column(
                        children: [
                          SizedBox(height: 12.h),
                          _buildServiceItem(
                            _extraServices[i]['name'],
                            _extraServices[i]['price'],
                            _extraServices[i]['quantity'],
                            showDelete: true,
                            onDelete: () => _removeExtraService(i),
                          ),
                        ],
                      ),

                    SizedBox(height: 20.h),

                    // GST Row
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!, width: 1),
                          bottom: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
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
                            color: Colors.black,
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
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPaymentOption(
                            'Cash',
                            _selectedPaymentMethod == 'Cash',
                            () {
                              setState(() {
                                _selectedPaymentMethod = 'Cash';
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildPaymentOption(
                            'Online Banking',
                            _selectedPaymentMethod == 'Online Banking',
                            () {
                              setState(() {
                                _selectedPaymentMethod = 'Online Banking';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Payment Status Section
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
                      'Payment Status',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPaymentOption(
                            'Payment Paid',
                            _selectedPaymentStatus == 'Payment Paid',
                            () {
                              setState(() {
                                _selectedPaymentStatus = 'Payment Paid';
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildPaymentOption(
                            'Payment Unpaid',
                            _selectedPaymentStatus == 'Payment Unpaid',
                            () {
                              setState(() {
                                _selectedPaymentStatus = 'Payment Unpaid';
                              });
                            },
                          ),
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

  Widget _buildCustomerInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
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
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
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
                      fontWeight: FontWeight.normal,
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

  Widget _buildPaymentOption(String title, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: selected ? Color(0xFF4A90E2) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected ? Color(0xFF4A90E2) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}
