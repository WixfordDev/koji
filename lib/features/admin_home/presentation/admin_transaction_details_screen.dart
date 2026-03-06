import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koji/features/admin_home/presentation/widget/transaction_details_widget.dart';
import 'package:koji/helpers/toast_message_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controller/admincontroller/admin_home_controller.dart';
import '../../../services/api_constants.dart';

class AdminInvoiceDetailsScreen extends StatefulWidget {
  final String? invoiceType; // "invoice" or "quote"
  final String billingId;

  const AdminInvoiceDetailsScreen({
    super.key,
    this.invoiceType,
    required this.billingId,
  });

  @override
  State<AdminInvoiceDetailsScreen> createState() =>
      _AdminInvoiceDetailsScreenState();
}

class _AdminInvoiceDetailsScreenState
    extends State<AdminInvoiceDetailsScreen> {
  late AdminHomeController adminHomeController;

  @override
  void initState() {
    super.initState();
    adminHomeController = Get.find<AdminHomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adminHomeController.getBillingDetails(widget.billingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String appBarTitle =
        widget.invoiceType == "quote" ? "Quote Details" : "Invoice Details";
    final String buttonLabel =
        widget.invoiceType == "quote" ? "Download Quote" : "Download Invoice";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          appBarTitle,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // ── Loading state
        if (adminHomeController.getBillingDetailsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF7D7D)),
          );
        }

        final billing = adminHomeController.billingDetails.value;

        // ── Empty / not yet loaded
        if (billing.id == null) {
          return const Center(child: Text('No details available.'));
        }

        // ── Build service name list for display
        final List<String> serviceNames = billing.services
                ?.map((s) => s.name ?? '')
                .where((n) => n.isNotEmpty)
                .toList() ??
            [];

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16.h),

              // ── Detail Card with real data
              InvoiceDetailsWidget(
                staffName: billing.createdBy ?? '-',
                category: serviceNames.isNotEmpty ? serviceNames.first : '-',
                serviceList: serviceNames,
                customerName: billing.customerName ?? '-',
                customerNumber: billing.customerNumber ?? '-',
                customerAddress: billing.customerAddress ?? '-',
                assignTo: billing.createdBy ?? '-',
                time: billing.invoiceDate != null
                    ? '${_formatDate(billing.invoiceDate)} – ${_formatDate(billing.dueDate)}'
                    : '-',
                invoiceNumber: billing.invoiceNumber ?? '-',
                dueDate: _formatDate(billing.dueDate),
                notes: billing.notes ?? [],
                otherAmount: billing.otherAmount ?? 0,
                gst: billing.gst ?? 0,
                totalDue: billing.totalDue ?? 0,
              ),

              SizedBox(height: 16.h),

              // ── Bank Details Card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bank Details',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _bankRow('Bank', billing.bankDetails?.bank),
                    _bankRow(
                        'Account Name', billing.bankDetails?.accountName),
                    _bankRow(
                        'Account Number', billing.bankDetails?.accountNumber),
                    _bankRow('SWIFT Code', billing.bankDetails?.swiftCode),
                    if (billing.bankDetails?.qrCode != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            billing.bankDetails!.qrCode!,
                            height: 120.h,
                            width: 120.w,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120.h,
                                width: 120.w,
                                color: Colors.grey[200],
                                child: Icon(Icons.qr_code, size: 60.r),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Download Button
              Padding(
                padding: EdgeInsets.all(17.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Get PDF path from billing details
                      final pdfPath = billing.pdfPath;

                      if (pdfPath != null && pdfPath.isNotEmpty) {
                        final fullUrl = pdfPath.startsWith('http')
                            ? pdfPath
                            : '${ApiConstants.imageBaseUrl}$pdfPath';
                        final uri = Uri.tryParse(fullUrl);
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(
                              uri, mode: LaunchMode.externalApplication);
                        } else {
                          ToastMessageHelper.showToastMessage(
                            'Cannot open the PDF link. Please try again.',
                            title: 'Error',
                            context: context,
                          );
                        }
                      } else {
                        ToastMessageHelper.showToastMessage(
                          'PDF not available yet. The invoice has been created but PDF is still being generated.',
                          title: 'Info',
                          context: context,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7D7D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          buttonLabel,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.download,
                          color: Colors.white,
                          size: 20.r,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  Widget _bankRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style:
                TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
