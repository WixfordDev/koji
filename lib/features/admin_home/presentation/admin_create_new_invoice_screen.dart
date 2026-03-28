import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/features/admin_home/presentation/widget/adjustments_widget.dart';
import 'package:koji/features/admin_home/presentation/widget/amount_details_widget.dart';
import 'package:koji/features/admin_home/presentation/widget/bank_details_widgets.dart';
import 'package:koji/features/admin_home/presentation/widget/customer_details_widgets.dart';
import 'package:koji/features/admin_home/presentation/widget/date_selection_widget.dart';
import 'package:koji/features/admin_home/presentation/widget/notes_widget.dart';
import 'package:koji/features/admin_home/presentation/widget/service_item_widget.dart';
import 'package:koji/features/admin_home/presentation/widget/type_toggle_widget.dart';
import 'package:koji/shared_widgets/custom_button.dart';

import '../../../controller/admincontroller/admin_home_controller.dart';
import '../../../controller/admincontroller/department_controller.dart';
import '../../../helpers/toast_message_helper.dart';

class AdminCreateInvoiceScreen extends StatefulWidget {
  const AdminCreateInvoiceScreen({super.key});

  @override
  State<AdminCreateInvoiceScreen> createState() =>
      _AdminCreateInvoiceScreenState();
}

class _AdminCreateInvoiceScreenState extends State<AdminCreateInvoiceScreen> {
  late AdminHomeController adminHomeController;
  late DepartmentController departmentController;

  // Type selection (Invoice or Quote)
  String selectedType = "invoice"; // "invoice" or "quote"

  // Customer Details Controllers
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _customerNumberController = TextEditingController();
  final TextEditingController _customerEmailController = TextEditingController();

  // Date Controllers
  DateTime? invoiceDate;
  DateTime? dueDate;

  // Service Items
  List<Map<String, dynamic>> serviceItems = [];

  // Amount Controllers
  final TextEditingController _otherAmountController = TextEditingController(text: "0");
  final TextEditingController _gstController = TextEditingController(text: "9");

  // Bank Details Controllers
  final TextEditingController _bankNameController = TextEditingController(text: "OCBC");
  final TextEditingController _accountNameController = TextEditingController(text: "Koji Engineering Pte Ltd");
  final TextEditingController _accountNumberController = TextEditingController(text: "595-679788-001");
  final TextEditingController _swiftCodeController = TextEditingController(text: "OCBCSGSGGCF");
  final TextEditingController _qrCodeController = TextEditingController(
      text: "https://raw.githubusercontent.com/u2hhzgf0/image-server/refs/heads/main/Koji%20Engineering%20Pte%20Ltd%20QRCode.jpg");

  // Adjustments (Deposit/Discount)
  List<Map<String, dynamic>> adjustments = [];

  // Notes (only for quotation)
  List<String> notes = [
    "The price stated in this quotation is final.",
    "This quotation is valid for 30 days"
  ];

  @override
  void initState() {
    super.initState();
    adminHomeController = Get.find<AdminHomeController>();
    departmentController = Get.find<DepartmentController>();

    // Load service list for selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      departmentController.getAllServiceList();
    });
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _customerNumberController.dispose();
    _customerEmailController.dispose();
    _otherAmountController.dispose();
    _gstController.dispose();
    _bankNameController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _swiftCodeController.dispose();
    _qrCodeController.dispose();
    for (var adj in adjustments) {
      (adj['controller'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _addAdjustment() {
    setState(() {
      adjustments.add({
        'type': 'discount',
        'controller': TextEditingController(text: '0'),
      });
    });
  }

  void _removeAdjustment(int index) {
    setState(() {
      (adjustments[index]['controller'] as TextEditingController).dispose();
      adjustments.removeAt(index);
    });
  }

  void _onAdjustmentTypeChanged(int index, String type) {
    setState(() {
      adjustments[index]['type'] = type;
    });
  }

  double _calculateSubtotal() {
    double subtotal = 0.0;
    for (var service in serviceItems) {
      double price = double.tryParse(service['price'].toString()) ?? 0.0;
      int quantity = int.tryParse(service['quantity'].toString()) ?? 0;
      subtotal += price * quantity;
    }
    return subtotal;
  }

  double _calculateAdjustmentTotal() {
    return adjustments.fold(0.0, (sum, adj) {
      return sum +
          (double.tryParse(
                  (adj['controller'] as TextEditingController).text) ??
              0.0);
    });
  }

  double _calculateTotal() {
    double subtotal = _calculateSubtotal();
    double otherAmount = double.tryParse(_otherAmountController.text) ?? 0.0;
    double gst = double.tryParse(_gstController.text) ?? 0.0;
    double gstAmount = (subtotal + otherAmount) * (gst / 100);
    double adjustmentTotal = _calculateAdjustmentTotal();
    return subtotal + otherAmount + gstAmount - adjustmentTotal;
  }

  void _addServiceItem(Map<String, dynamic> service) {
    setState(() {
      serviceItems.add(service);
    });
  }

  void _removeServiceItem(int index) {
    setState(() {
      serviceItems.removeAt(index);
    });
  }

  void _editServiceItem(int index, Map<String, dynamic> updatedService) {
    setState(() {
      serviceItems[index] = updatedService;
    });
  }

  Future<void> _createInvoiceOrQuotation() async {
    // Validation
    if (_customerNameController.text.trim().isEmpty) {
      ToastMessageHelper.showToastMessage("Please enter customer name");
      return;
    }

    if (_customerNumberController.text.trim().isEmpty) {
      ToastMessageHelper.showToastMessage("Please enter customer number");
      return;
    }

    if (_customerEmailController.text.trim().isEmpty) {
      ToastMessageHelper.showToastMessage("Please enter customer email");
      return;
    }

    if (invoiceDate == null) {
      ToastMessageHelper.showToastMessage("Please select invoice date");
      return;
    }

    if (dueDate == null) {
      ToastMessageHelper.showToastMessage("Please select due date");
      return;
    }

    if (serviceItems.isEmpty) {
      ToastMessageHelper.showToastMessage("Please add at least one service item");
      return;
    }

    // Prepare the request body
    Map<String, dynamic> requestBody = {
      "type": selectedType,
      "customerName": _customerNameController.text.trim(),
      "customerAddress": _customerAddressController.text.trim(),
      "customerNumber": _customerNumberController.text.trim(),
      "coustomerEmail": _customerEmailController.text.trim(),
      "invoiceDate": _formatDateForApi(invoiceDate!),
      "dueDate": _formatDateForApi(dueDate!),
      "services": serviceItems,
      "otherAmount": _otherAmountController.text.trim(),
      "gst": _gstController.text.trim(),
      "adjustments": adjustments
          .map((adj) => {
                "type": adj['type'],
                "amount":
                    (adj['controller'] as TextEditingController).text.trim(),
              })
          .toList(),
      "bankDetails": {
        "bank": _bankNameController.text.trim(),
        "accountName": _accountNameController.text.trim(),
        "accountNumber": _accountNumberController.text.trim(),
        "SWIFTCode": _swiftCodeController.text.trim(),
        "QRCode": _qrCodeController.text.trim(),
      },
    };

    // Add notes only for quotation
    if (selectedType == "quote") {
      requestBody["notes"] = notes;
    }

    // Call the appropriate API
    bool success;
    if (selectedType == "invoice") {
      final result = await adminHomeController.createInvoice(requestBody);
      success = result != null;
    } else {
      final result = await adminHomeController.createQuotation(requestBody);
      success = result != null;
    }

    if (success) {
      // Reset form
      _resetForm();
      // Navigate back
      Navigator.pop(context);
      ToastMessageHelper.showToastMessage(
          "${selectedType == 'invoice' ? 'Invoice' : 'Quotation'} created successfully!");
    }
  }

  void _resetForm() {
    setState(() {
      _customerNameController.clear();
      _customerAddressController.clear();
      _customerNumberController.clear();
      _customerEmailController.clear();
      invoiceDate = null;
      dueDate = null;
      serviceItems.clear();
      _otherAmountController.text = "0";
      _gstController.text = "9";
      for (var adj in adjustments) {
        (adj['controller'] as TextEditingController).dispose();
      }
      adjustments.clear();
    });
  }

  String _formatDateForApi(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Create New ${selectedType == 'invoice' ? 'Invoice' : 'Quotation'}",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Toggle (Invoice/Quote)
            TypeToggleWidget(
              selectedType: selectedType,
              onTypeChanged: (type) {
                setState(() {
                  selectedType = type;
                });
              },
            ),
            SizedBox(height: 24.h),

            // Customer Details
            CustomerDetailsWidget(
              nameController: _customerNameController,
              addressController: _customerAddressController,
              numberController: _customerNumberController,
              emailController: _customerEmailController,
            ),
            SizedBox(height: 24.h),

            // Date Selection
            DateSelectionWidget(
              invoiceDate: invoiceDate,
              dueDate: dueDate,
              onInvoiceDateSelected: (date) {
                setState(() {
                  invoiceDate = date;
                });
              },
              onDueDateSelected: (date) {
                setState(() {
                  dueDate = date;
                });
              },
            ),
            SizedBox(height: 24.h),

            // Service Items
            ServiceItemsWidget(
              serviceItems: serviceItems,
              availableServices: departmentController.serviceList.value.results ?? [],
              onAddService: _addServiceItem,
              onRemoveService: _removeServiceItem,
              onEditService: _editServiceItem,
            ),
            SizedBox(height: 24.h),

            // Amount Details
            AmountDetailsWidget(
              subtotal: _calculateSubtotal(),
              otherAmountController: _otherAmountController,
              gstController: _gstController,
              total: _calculateTotal(),
              onAmountChanged: () {
                setState(() {});
              },
            ),
            SizedBox(height: 24.h),

            // Adjustments
            AdjustmentsWidget(
              adjustments: adjustments,
              onAdd: _addAdjustment,
              onRemove: _removeAdjustment,
              onTypeChanged: _onAdjustmentTypeChanged,
              onChanged: () => setState(() {}),
            ),
            SizedBox(height: 24.h),

            // Bank Details
            BankDetailsWidget(
              bankNameController: _bankNameController,
              accountNameController: _accountNameController,
              accountNumberController: _accountNumberController,
              swiftCodeController: _swiftCodeController,
              qrCodeController: _qrCodeController,
            ),
            SizedBox(height: 24.h),

            // Notes (only for quotation)
            if (selectedType == "quote")
              NotesWidget(
                notes: notes,
                onNotesChanged: (updatedNotes) {
                  setState(() {
                    notes = updatedNotes;
                  });
                },
              ),

            if (selectedType == "quote") SizedBox(height: 24.h),

            // Create Button
            Obx(() => CustomButton(
              title: adminHomeController.createInvoiceLoading.value ||
                  adminHomeController.createQuotationLoading.value
                  ? 'Creating...'
                  : 'Create ${selectedType == 'invoice' ? 'Invoice' : 'Quotation'}',
              onpress: _createInvoiceOrQuotation,
              loading: adminHomeController.createInvoiceLoading.value ||
                  adminHomeController.createQuotationLoading.value,
            )),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}