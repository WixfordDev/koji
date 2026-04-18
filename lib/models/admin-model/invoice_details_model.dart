import 'dart:convert';

InvoiceDetailsModel invoiceDetailsModelFromJson(String str) => InvoiceDetailsModel.fromJson(json.decode(str));

String invoiceDetailsModelToJson(InvoiceDetailsModel data) => json.encode(data.toJson());

class InvoiceDetailsModel {
  String? createdBy;
  String? type;
  String? customerName;
  String? customerAddress;
  String? customerNumber;
  String? coustomerEmail;
  String? invoiceNumber;
  String? quoteNumber;
  String? invoiceDate;
  String? dueDate;
  List<Service>? services;
  int? otherAmount;
  int? gst;
  int? totalDue;
  List<String>? notes;
  BankDetails? bankDetails;
  String? createdAt;
  String? id;
  String? pdfPath;

  InvoiceDetailsModel({
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
    this.pdfPath,
  });

  static String? _extractName(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map) {
      return raw['fullName']?.toString() ??
          raw['name']?.toString() ??
          raw['_id']?.toString();
    }
    return raw.toString();
  }

  factory InvoiceDetailsModel.fromJson(Map<String, dynamic> json) => InvoiceDetailsModel(
    createdBy: _extractName(json["createdBy"]),
    type: json["type"],
    customerName: json["customerName"],
    customerAddress: json["customerAddress"],
    customerNumber: json["customerNumber"],
    coustomerEmail: json["coustomerEmail"],
    invoiceNumber: json["invoiceNumber"],
    quoteNumber: json["quoteNumber"],
    invoiceDate: json["invoiceDate"],
    dueDate: json["dueDate"],
    services: json["services"] == null ? [] : List<Service>.from(json["services"]!.map((x) => Service.fromJson(x))),
    otherAmount: json["otherAmount"],
    gst: json["gst"],
    totalDue: json["totalDue"],
    notes: json["notes"] == null ? [] : List<String>.from(json["notes"]!.map((x) => x)),
    bankDetails: json["bankDetails"] == null ? null : BankDetails.fromJson(json["bankDetails"]),
    createdAt: json["createdAt"],
    id: json["_id"] ?? json["id"],
    pdfPath: json["pdfPath"],
  );

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
    "services": services == null ? [] : List<dynamic>.from(services!.map((x) => x.toJson())),
    "otherAmount": otherAmount,
    "gst": gst,
    "totalDue": totalDue,
    "notes": notes == null ? [] : List<dynamic>.from(notes!.map((x) => x)),
    "bankDetails": bankDetails?.toJson(),
    "createdAt": createdAt,
    "id": id,
    "pdfPath": pdfPath,
  };
}

class Service {
  String? name;
  int? quantity;
  int? price;
  String? id;

  Service({
    this.name,
    this.quantity,
    this.price,
    this.id,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
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

class BankDetails {
  String? bank;
  String? accountName;
  String? accountNumber;
  String? swiftCode;
  String? qrCode;
  String? id;

  BankDetails({
    this.bank,
    this.accountName,
    this.accountNumber,
    this.swiftCode,
    this.qrCode,
    this.id,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
    bank: json["bank"],
    accountName: json["accountName"],
    accountNumber: json["accountNumber"],
    swiftCode: json["SWIFTCode"],
    qrCode: json["QRCode"],
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