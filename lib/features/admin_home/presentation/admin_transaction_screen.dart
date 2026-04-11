import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controller/admincontroller/admin_home_controller.dart';
import '../../../models/admin-model/billing_docs_model.dart';
import '../../../models/admin-model/invoice_details_model.dart';
import 'admin_create_new_invoice_screen.dart';
import 'admin_transaction_details_screen.dart';

class AdminTransactionScreen extends StatefulWidget {
  const AdminTransactionScreen({super.key});

  @override
  State<AdminTransactionScreen> createState() => _AdminTransactionScreenState();
}

class _AdminTransactionScreenState extends State<AdminTransactionScreen> {
  late AdminHomeController adminHomeController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  /// 0 = All, 1 = Invoices, 2 = Quotes
  int _selectedTabIndex = 0;

  final List<String> _tabLabels = ['All', 'Invoices', 'Quotes'];
  final List<String> _tabTypes  = ['', 'invoice', 'quote'];

  @override
  void initState() {
    super.initState();
    adminHomeController = Get.find<AdminHomeController>();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adminHomeController.getBillingDocs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    setState(() => _selectedTabIndex = index);
    adminHomeController.getBillingDocs(type: _tabTypes[index]);
  }

  List<BillingDocResult> _applySearch(List<BillingDocResult> items) {
    if (_searchQuery.isEmpty) return items;
    return items.where((doc) {
      final name = (doc.customerName ?? '').toLowerCase();
      final number = (doc.customerNumber ?? '').toLowerCase();
      final invoice = (doc.invoiceNumber ?? '').toLowerCase();
      final quote = (doc.quoteNumber ?? '').toLowerCase();
      return name.contains(_searchQuery) ||
          number.contains(_searchQuery) ||
          invoice.contains(_searchQuery) ||
          quote.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
          'Transaction Report',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(25.w, 16.h, 25.w, 16.h),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  Icon(Icons.search, color: const Color(0xFF9E9E9E), size: 20.sp),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name, number, invoice no...',
                        hintStyle: TextStyle(
                          color: const Color(0xFF9E9E9E),
                          fontSize: 14.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () => _searchController.clear(),
                      child: Icon(Icons.close, color: const Color(0xFF9E9E9E), size: 18.sp),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // ── Filter Tabs ─────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 12.h),
            child: Row(
              children: List.generate(_tabLabels.length, (i) {
                final bool active = _selectedTabIndex == i;
                return Padding(
                  padding: EdgeInsets.only(right: i < _tabLabels.length - 1 ? 8.w : 0),
                  child: GestureDetector(
                    onTap: () => _onTabTap(i),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        gradient: active
                            ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFEC526A), Color(0xFFF77F6E)],
                          stops: [0.0075, 0.9527],
                        )
                            : null,
                        borderRadius: BorderRadius.circular(30.r),
                        border: active
                            ? null
                            : Border.all(color: const Color(0xFFC8C8C8)),
                      ),
                      child: Text(
                        _tabLabels[i],
                        style: TextStyle(
                          color: active ? Colors.white : const Color(0xFF424242),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── List ────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (adminHomeController.getBillingDocsLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<BillingDocResult> allItems =
                  List<BillingDocResult>.from(
                      adminHomeController.billingDocs.value.results ?? [])
                    ..sort((a, b) {
                      final aDate = a.invoiceDate != null
                          ? DateTime.tryParse(a.invoiceDate!)
                          : null;
                      final bDate = b.invoiceDate != null
                          ? DateTime.tryParse(b.invoiceDate!)
                          : null;
                      if (aDate == null && bDate == null) return 0;
                      if (aDate == null) return 1;
                      if (bDate == null) return -1;
                      return bDate.compareTo(aDate); // newest first
                    });

              final List<BillingDocResult> items = _applySearch(allItems);

              if (allItems.isEmpty) {
                return const Center(child: Text('No records found'));
              }

              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'No results for "$_searchQuery"',
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) =>
                    _BillingDocCard(doc: items[index]),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (_) => AdminCreateInvoiceScreen(),
          ))
              .then((_) => adminHomeController.getBillingDocs(
              type: _tabTypes[_selectedTabIndex]));
        },
        backgroundColor: const Color(0xFFF95555),
        child: Icon(Icons.add, color: Colors.white, size: 24.sp),
      ),
    );
  }
}

// ── Billing Doc Card ─────────────────────────────────────────────────────────

class _BillingDocCard extends StatelessWidget {
  final BillingDocResult doc;
  const _BillingDocCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final bool isInvoice = doc.type == 'invoice';
    final String docNumber =
        (isInvoice ? doc.invoiceNumber : doc.quoteNumber) ?? 'N/A';
    final String label = isInvoice ? 'Invoice' : 'Quote';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AdminInvoiceDetailsScreen(
            billingId: doc.id!,
            invoiceType: doc.type, // "invoice" or "quote"
          ),
        ));
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: isInvoice
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                isInvoice ? Icons.receipt_long : Icons.request_quote,
                color: isInvoice
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF2196F3),
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.customerName ?? '-',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF212121),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$label No: $docNumber',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF757575),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Customer: ${doc.customerNumber ?? '-'}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),

            // Amount + date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${doc.totalDue ?? 0}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatDate(doc.invoiceDate),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}.${dt.month}.${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}