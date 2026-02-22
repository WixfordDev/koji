import 'dart:convert';

BillingDocsModel billingDocsModelFromJson(String str) =>
    BillingDocsModel.fromJson(json.decode(str));

String billingDocsModelToJson(BillingDocsModel data) =>
    json.encode(data.toJson());

class BillingDocsModel {
  final List<BillingDocResult>? results;
  final int? page;
  final int? limit;
  final int? totalPages;
  final int? totalResults;

  BillingDocsModel({
    this.results,
    this.page,
    this.limit,
    this.totalPages,
    this.totalResults,
  });

  factory BillingDocsModel.fromJson(Map<String, dynamic> json) =>
      BillingDocsModel(
        results: json["results"] == null
            ? []
            : List<BillingDocResult>.from(
            json["results"].map((x) => BillingDocResult.fromJson(x))),
        page: json["page"],
        limit: json["limit"],
        totalPages: json["totalPages"],
        totalResults: json["totalResults"],
      );

  Map<String, dynamic> toJson() => {
    "results": results == null
        ? []
        : List<dynamic>.from(results!.map((x) => x.toJson())),
    "page": page,
    "limit": limit,
    "totalPages": totalPages,
    "totalResults": totalResults,
  };
}

// ── BillingDocResult ──────────────────────────────────────────────────────────

class BillingDocResult {
  final String? createdBy;
  final String? type;
  final String? customerName;
  final String? customerAddress;
  final String? customerNumber;
  final String? coustomerEmail;
  final String? invoiceNumber;
  final String? quoteNumber;
  final String? invoiceDate;
  final String? dueDate;
  final List<BillingService>? services;
  final int? otherAmount;
  final int? gst;
  final int? totalDue;
  final List<String>? notes;
  final BillingBankDetails? bankDetails;
  final String? createdAt;
  final String? id;

  BillingDocResult({
    this.createdBy,
    this.type,
    this.customerName,
    this.customerAddress,
    this.customerNumber,
    this.coustomerEmail,
    this.invoiceNumber,
    this.quoteNumber,
    this.invoiceDate,
    this.dueDate,
    this.services,
    this.otherAmount,
    this.gst,
    this.totalDue,
    this.notes,
    this.bankDetails,
    this.createdAt,
    this.id,
  });

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool get isInvoice => type == 'invoice';

  /// API returns totalDue = 0, so calculate manually:
  /// subtotal = Σ(qty × price) + otherAmount
  /// total    = subtotal + (subtotal × gst / 100)
  double get calculatedTotal {
    double subtotal = 0;
    for (final s in services ?? []) {
      subtotal += (s.quantity ?? 0) * (s.price ?? 0);
    }
    subtotal += (otherAmount ?? 0);
    final double gstAmount = subtotal * ((gst ?? 0) / 100);
    return subtotal + gstAmount;
  }

  /// e.g. "$239.80"
  String get formattedTotal => '\$${calculatedTotal.toStringAsFixed(2)}';

  /// Invoice number or Quote number
  String get docNumber =>
      (isInvoice ? invoiceNumber : quoteNumber) ?? 'N/A';

  /// "19.2.2026"
  String get formattedInvoiceDate => _formatDate(invoiceDate);
  String get formattedDueDate => _formatDate(dueDate);

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}.${dt.month}.${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  // ── fromJson ───────────────────────────────────────────────────────────────

  factory BillingDocResult.fromJson(Map<String, dynamic> json) =>
      BillingDocResult(
        createdBy: json["createdBy"],
        type: json["type"],
        customerName: json["customerName"],
        customerAddress: json["customerAddress"],
        customerNumber: json["customerNumber"],
        coustomerEmail: json["coustomerEmail"],
        invoiceNumber: json["invoiceNumber"],
        quoteNumber: json["quoteNumber"],
        invoiceDate: json["invoiceDate"],
        dueDate: json["dueDate"],
        services: json["services"] == null
            ? []
            : List<BillingService>.from(
            json["services"].map((x) => BillingService.fromJson(x))),
        otherAmount: json["otherAmount"],
        gst: json["gst"],
        totalDue: json["totalDue"],
        notes: json["notes"] == null
            ? []
            : List<String>.from(json["notes"].map((x) => x.toString())),
        bankDetails: json["bankDetails"] == null
            ? null
            : BillingBankDetails.fromJson(json["bankDetails"]),
        createdAt: json["createdAt"],
        id: json["id"],
      );

  // ── toJson ─────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    "createdBy": createdBy,
    "type": type,
    "customerName": customerName,
    "customerAddress": customerAddress,
    "customerNumber": customerNumber,
    "coustomerEmail": coustomerEmail,
    "invoiceNumber": invoiceNumber,
    "quoteNumber": quoteNumber,
    "invoiceDate": invoiceDate,
    "dueDate": dueDate,
    "services": services == null
        ? []
        : List<dynamic>.from(services!.map((x) => x.toJson())),
    "otherAmount": otherAmount,
    "gst": gst,
    "totalDue": totalDue,
    "notes": notes == null
        ? []
        : List<dynamic>.from(notes!.map((x) => x)),
    "bankDetails": bankDetails?.toJson(),
    "createdAt": createdAt,
    "id": id,
  };
}

// ── BillingService ────────────────────────────────────────────────────────────

class BillingService {
  final String? name;
  final int? quantity;
  final int? price;
  final String? id;

  BillingService({
    this.name,
    this.quantity,
    this.price,
    this.id,
  });

  /// Line total: qty × price
  double get lineTotal => (quantity ?? 0) * (price ?? 0).toDouble();

  factory BillingService.fromJson(Map<String, dynamic> json) => BillingService(
    name: json["name"],
    quantity: json["quantity"],
    price: json["price"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "quantity": quantity,
    "price": price,
    "_id": id,
  };
}

// ── BillingBankDetails ────────────────────────────────────────────────────────

class BillingBankDetails {
  final String? bank;
  final String? accountName;
  final String? accountNumber;
  final String? swiftCode;
  final String? qrCode;
  final String? id;

  BillingBankDetails({
    this.bank,
    this.accountName,
    this.accountNumber,
    this.swiftCode,
    this.qrCode,
    this.id,
  });

  factory BillingBankDetails.fromJson(Map<String, dynamic> json) =>
      BillingBankDetails(
        bank: json["bank"],
        accountName: json["accountName"],
        accountNumber: json["accountNumber"],
        swiftCode: json["SWIFTCode"],   // note: capital SWIFT in API
        qrCode: json["QRCode"],         // note: capital QR in API
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
    "bank": bank,
    "accountName": accountName,
    "accountNumber": accountNumber,
    "SWIFTCode": swiftCode,
    "QRCode": qrCode,
    "_id": id,
  };
}