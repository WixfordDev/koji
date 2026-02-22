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
  String _selectedPaymentMethod = 'cash';
  String _selectedPaymentStatus = 'paid';
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _originalServices = [];

  // Gradient colors
  static const Color primaryDark = Color(0xFF162238);
  static const Color primaryBlue = Color(0xFF4082FB);

  @override
  void initState() {
    super.initState();
    _loadOriginalServices();
  }

  void _loadOriginalServices() {
    var servicesData = widget.taskData['service'];
    if (servicesData is List<Service>) {
      for (var service in servicesData) {
        _originalServices.add({
          'name': service.name ?? 'N/A',
          'price': service.price?.toDouble() ?? 0.0,
          'quantity': service.quantity?.toString() ?? '1',
        });
      }
    } else if (servicesData is List) {
      for (var service in servicesData) {
        if (service is Map<String, dynamic>) {
          _originalServices.add({
            'name': service['name'] ?? 'N/A',
            'price': (service['price'] is double) ? service['price'] : double.tryParse(service['price'].toString()) ?? 0.0,
            'quantity': service['quantity']?.toString() ?? '1',
          });
        }
      }
    }
  }

  final List<Map<String, dynamic>> _extraServices = [];
  final double _gstPercentage = 0;

  double get _subtotal {
    double subtotal = 0;
    for (var service in _originalServices) {
      subtotal += service['price'] * int.parse(service['quantity']);
    }
    for (var service in _extraServices) {
      subtotal += service['price'] * int.parse(service['quantity']);
    }
    return subtotal;
  }

  double get _gstAmount => (_subtotal * _gstPercentage) / 100;
  double get _totalPrice => _subtotal + _gstAmount;

  Map<String, String> get _taskJson {
    List<Map<String, dynamic>> allServices = [];
    allServices.addAll(_originalServices.map((s) => {'name': s['name'], 'price': s['price'].toString(), 'quantity': s['quantity']}));
    allServices.addAll(_extraServices.map((s) => {'name': s['name'], 'price': s['price'].toString(), 'quantity': s['quantity']}));
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

  /// Reusable gradient button
  Widget _gradientButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          gradient: onPressed == null
              ? null
              : const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            transform: GradientRotation(344.45 * 3.14159 / 180),
            colors: [primaryDark, primaryBlue],
          ),
          color: onPressed == null ? Colors.grey.shade300 : null,
          borderRadius: BorderRadius.circular(100.r),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
          height: 22.h,
          width: 22.h,
          child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
            ],
            Text(
              label,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// Outlined gradient button (for Add Extra Service)
  Widget _outlinedGradientButton({required String label, required VoidCallback onPressed, IconData? icon}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(color: primaryBlue, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: primaryBlue, size: 20.sp),
              SizedBox(width: 8.w),
            ],
            Text(
              label,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: primaryBlue),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 3) {
      Get.snackbar('Maximum Limit', 'You can only select up to 3 images', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    final List<XFile>? images = await _picker.pickMultiImage(maxWidth: 1080, maxHeight: 1080, imageQuality: 85);
    if (images != null) {
      int remainingSlots = 3 - _selectedImages.length;
      if (images.length > remainingSlots) {
        Get.snackbar('Limit Exceeded', 'Only $remainingSlots more images allowed', backgroundColor: Colors.orange, colorText: Colors.white);
      }
      setState(() {
        _selectedImages.addAll(images.take(remainingSlots).map((image) => File(image.path)));
      });
    }
  }

  void _removeImage(int index) => setState(() => _selectedImages.removeAt(index));

  Future<void> _submitTask() async {
    if (_selectedImages.isEmpty) {
      Get.snackbar('Signature Required', 'Please add customer signature before submitting', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    _showCustomerSignatureDialog();
  }

  void _showCustomerSignatureDialog() {
    bool isUploading = false;
    final GlobalKey<SfSignaturePadState> signatureKey = GlobalKey();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Customer Signature', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20.h),
                  Container(
                    width: double.infinity,
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SfSignaturePad(key: signatureKey, backgroundColor: Colors.white, strokeColor: Colors.black),
                  ),
                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => signatureKey.currentState?.clear(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.clear, size: 16.sp, color: Colors.red),
                          SizedBox(width: 4.w),
                          Text('Clear Signature', style: TextStyle(fontSize: 14.sp, color: Colors.red)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Submit button — gradient
                  GestureDetector(
                    onTap: isUploading
                        ? null
                        : () async {
                      final signatureImage = await signatureKey.currentState?.toImage();
                      if (signatureImage == null) {
                        Get.snackbar('Required', 'Please add customer signature', backgroundColor: Colors.red, colorText: Colors.white);
                        return;
                      }
                      setDialogState(() => isUploading = true);
                      try {
                        final ByteData? byteData = await signatureImage.toByteData(format: ImageByteFormat.png);
                        if (byteData == null) return;
                        final Uint8List pngBytes = byteData.buffer.asUint8List();
                        final tempDir = await getTemporaryDirectory();
                        final file = await File('${tempDir.path}/signature.png').create();
                        await file.writeAsBytes(pngBytes);

                        final acceptResponse = await ApiClient.postMultipartData(
                          '/tasks/${widget.taskId}/accept',
                          {},
                          multipartBody: [MultipartBody("signature", file)],
                        );

                        if (acceptResponse.statusCode == 200) {
                          List<MultipartBody> photoList = _selectedImages.map((p) => MultipartBody("attachments", p)).toList();
                          final submitResponse = await ApiClient.postMultipartData(
                            '/tasks/${widget.taskId}/submit',
                            _taskJson,
                            multipartBody: photoList,
                          );
                          if (submitResponse.statusCode == 200) {
                            Navigator.pop(dialogContext);
                            _showSuccessDialog();
                          } else {
                            Get.snackbar('Error', 'Failed to submit task', backgroundColor: Colors.red, colorText: Colors.white);
                          }
                        } else {
                          Get.snackbar('Error', 'Failed to accept task', backgroundColor: Colors.red, colorText: Colors.white);
                        }
                      } catch (e) {
                        Get.snackbar('Error', 'Failed to process: $e', backgroundColor: Colors.red, colorText: Colors.white);
                      } finally {
                        setDialogState(() => isUploading = false);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48.h,
                      decoration: BoxDecoration(
                        gradient: isUploading
                            ? null
                            : const LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          transform: GradientRotation(344.45 * 3.14159 / 180),
                          colors: [primaryDark, primaryBlue],
                        ),
                        color: isUploading ? Colors.grey.shade300 : null,
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      alignment: Alignment.center,
                      child: isUploading
                          ? SizedBox(height: 22.h, width: 22.h, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Submit', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),

                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: isUploading ? null : () => Navigator.pop(dialogContext),
                      child: Text('No, Let Me Check', style: TextStyle(fontSize: 16.sp, color: Colors.grey[600])),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    transform: GradientRotation(344.45 * 3.14159 / 180),
                    colors: [primaryDark, primaryBlue],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.white, size: 50.sp),
              ),
              SizedBox(height: 20.h),
              Text('Success', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 12.h),
              Text(
                'Your task has been submitted successfully.\nYou will be notified once it is reviewed by\nyour admin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600], height: 1.5),
              ),
              SizedBox(height: 24.h),

              // View List — gradient button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      transform: GradientRotation(344.45 * 3.14159 / 180),
                      colors: [primaryDark, primaryBlue],
                    ),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  alignment: Alignment.center,
                  child: Text('View List', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Extra Service', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 20.h),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
                      child: Text('Cancel', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final name = nameController.text.trim();
                        final price = double.tryParse(priceController.text) ?? 0.0;
                        if (name.isNotEmpty && price > 0) {
                          setState(() {
                            _extraServices.add({'name': name, 'price': price, "quantity": "1"});
                          });
                          Navigator.pop(context);
                        } else {
                          Get.snackbar('Error', 'Please enter valid service name and price', backgroundColor: Colors.red, colorText: Colors.white);
                        }
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            transform: GradientRotation(344.45 * 3.14159 / 180),
                            colors: [primaryDark, primaryBlue],
                          ),
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        alignment: Alignment.center,
                        child: Text('Add', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
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

  void _removeExtraService(int index) => setState(() => _extraServices.removeAt(index));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('My Task', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              // Attachment Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12.r)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attachment', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black)),
                    SizedBox(height: 4.h),
                    Text('Format should be in .pdf .jpeg .png less than 5MB', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                    SizedBox(height: 10.h),
                    if (_selectedImages.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                                  image: DecorationImage(image: FileImage(_selectedImages[index]), fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                top: 4.w,
                                right: 4.w,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.5)),
                                    child: Icon(Icons.close, size: 14.sp, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    SizedBox(height: 16.h),
                    if (_selectedImages.length < 3)
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
                              Icon(Icons.add_photo_alternate, size: 32.sp, color: Colors.grey[400]),
                              SizedBox(height: 8.h),
                              Text(
                                _selectedImages.isEmpty ? 'Browse Files from device' : 'Tap to add more (${3 - _selectedImages.length} remaining)',
                                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                              ),
                              if (_selectedImages.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 4.h),
                                  child: Text('${_selectedImages.length}/3 images selected', style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
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
                    Text('Service List', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black)),
                    SizedBox(height: 16.h),
                    if (_originalServices.isNotEmpty)
                      ...List.generate(_originalServices.length, (index) {
                        final service = _originalServices[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _buildServiceItem('${service['name']} (x${service['quantity']})', service['price'], service['quantity']),
                        );
                      }),
                    if (_originalServices.isEmpty && _extraServices.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Text('No services available', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                      ),
                    ...List.generate(_extraServices.length, (index) {
                      final service = _extraServices[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildServiceItem(
                          '${service['name']} (x${service['quantity']})',
                          service['price'],
                          service['quantity'],
                          showDelete: true,
                          onDelete: () => _removeExtraService(index),
                        ),
                      );
                    }),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('GST \$9%', style: TextStyle(fontSize: 14.sp, color: Colors.grey[700])),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Price', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black)),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(colors: [primaryDark, primaryBlue]).createShader(bounds),
                          child: Text('\$${_totalPrice.toStringAsFixed(1)}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Payment Method
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text('Payment Method', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                  ),
                  Row(
                    children: [
                      _radioItem(title: 'Cash', value: 'cash', groupValue: _selectedPaymentMethod, onChanged: (val) => setState(() => _selectedPaymentMethod = val!)),
                      _radioItem(title: 'Online Banking', value: 'online_banking', groupValue: _selectedPaymentMethod, onChanged: (val) => setState(() => _selectedPaymentMethod = val!)),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Payment Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text('Payment Status', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                  ),
                  Row(
                    children: [
                      _radioItem(title: 'Payment Paid', value: 'paid', groupValue: _selectedPaymentStatus, onChanged: (val) => setState(() => _selectedPaymentStatus = val!)),
                      SizedBox(width: 20.w),
                      _radioItem(title: 'Payment Unpaid', value: 'unpaid', groupValue: _selectedPaymentStatus, onChanged: (val) => setState(() => _selectedPaymentStatus = val!)),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Add Extra Service — outlined gradient border
              _outlinedGradientButton(
                label: 'Add Extra Service',
                onPressed: _showAddServiceDialog,
                icon: Icons.add,
              ),

              SizedBox(height: 24.h),

              // Confirm & Submit — full gradient
              _gradientButton(
                label: 'Confirm & Submit Task',
                onPressed: _isSubmitting ? null : _submitTask,
                isLoading: _isSubmitting,
              ),

              SizedBox(height: 36.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _radioItem({required String title, required String value, required String? groupValue, required ValueChanged<String?> onChanged}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(value: value, groupValue: groupValue, onChanged: onChanged, activeColor: primaryBlue),
        Text(title, style: TextStyle(fontSize: 14.sp)),
      ],
    );
  }

  Widget _buildServiceItem(String name, double price, String? quantity, {bool showDelete = false, VoidCallback? onDelete}) {
    int qty = int.tryParse(quantity ?? '1') ?? 1;
    double total = price * qty;
    return Row(
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
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withOpacity(0.1)),
                    child: Icon(Icons.close, size: 16.sp, color: Colors.red),
                  ),
                ),
              if (showDelete) SizedBox(width: 12.w),
              Expanded(child: Text(name, style: TextStyle(fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.w500))),
            ],
          ),
        ),
        Text('\$${total.toStringAsFixed(1)}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }
}