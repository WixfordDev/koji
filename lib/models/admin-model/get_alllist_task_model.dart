// To parse this JSON data, do
//
//     final getAllListTaskModel = getAllListTaskModelFromJson(jsonString);

import 'dart:convert';
import 'package:koji/global/utils/date_utils.dart';

GetAllListTaskModel getAllListTaskModelFromJson(String str) => GetAllListTaskModel.fromJson(json.decode(str));

String getAllListTaskModelToJson(GetAllListTaskModel data) => json.encode(data.toJson());

class GetAllListTaskModel {
  final List<Result>? results;
  final int? page;
  final int? limit;
  final int? totalPages;
  final int? totalResults;

  GetAllListTaskModel({
    this.results,
    this.page,
    this.limit,
    this.totalPages,
    this.totalResults,
  });

  factory GetAllListTaskModel.fromJson(Map<String, dynamic> json) => GetAllListTaskModel(
    results: json["results"] == null ? [] : List<Result>.from(json["results"]!.map((x) => Result.fromJson(x))),
    page: json["page"],
    limit: json["limit"],
    totalPages: json["totalPages"],
    totalResults: json["totalResults"],
  );

  Map<String, dynamic> toJson() => {
    "results": results == null ? [] : List<dynamic>.from(results!.map((x) => x.toJson())),
    "page": page,
    "limit": limit,
    "totalPages": totalPages,
    "totalResults": totalResults,
  };
}

class Result {
  final dynamic customerSignature;
  final String? id;
  final String? createdBy;
  final String? department;
  final ServiceCategoryRef? serviceCategory;
  final String? vehicle;
  final String? customerName;
  final String? customerNumber;
  final String? customerAddress;
  final DateTime? assignDate;
  final DateTime? deadline;
  final List<Service>? services;
  final String? priority;
  final String? difficulty;
  final List<String>? assignTo;
  final int? otherAmount;
  final int? totalAmount;
  final String? status;
  final List<String>? attachments;
  final List<dynamic>? submitedDoc;
  final bool? isSubmited;
  final String? notes;
  final bool? isDeleted;
  final dynamic invoicePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final int? progressPercent;

  Result({
    this.customerSignature,
    this.id,
    this.createdBy,
    this.department,
    this.serviceCategory,
    this.vehicle,
    this.customerName,
    this.customerNumber,
    this.customerAddress,
    this.assignDate,
    this.deadline,
    this.services,
    this.priority,
    this.difficulty,
    this.assignTo,
    this.otherAmount,
    this.totalAmount,
    this.status,
    this.attachments,
    this.submitedDoc,
    this.isSubmited,
    this.notes,
    this.isDeleted,
    this.invoicePath,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.progressPercent,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    customerSignature: json["customerSignature"],
    id: json["id"] ?? json["_id"],
    createdBy: json["createdBy"],
    department: json["department"]?.toString(),
    serviceCategory: _parseServiceCategory(json["serviceCategory"]),
    vehicle: json["vehicle"],
    customerName: json["customerName"],
    customerNumber: json["customerNumber"],
    customerAddress: json["customerAddress"],
    assignDate: json["assignDate"] == null ? null : toSgt(DateTime.parse(json["assignDate"])),
    deadline: json["deadline"] == null ? null : toSgt(DateTime.parse(json["deadline"])),
    services: json["services"] == null ? [] : List<Service>.from(json["services"]!.map((x) => Service.fromJson(x))),
    priority: json["priority"],
    difficulty: json["difficulty"],
    assignTo: json["assignTo"] == null ? [] : List<String>.from(json["assignTo"]!.map((x) => x.toString())),
    otherAmount: json["otherAmount"],
    totalAmount: json["totalAmount"],
    status: json["status"],
    attachments: json["attachments"] == null ? [] : List<String>.from(json["attachments"]!.map((x) => x)),
    submitedDoc: json["submitedDoc"] == null ? [] : List<dynamic>.from(json["submitedDoc"]!.map((x) => x)),
    isSubmited: json["isSubmited"],
    notes: json["notes"],
    isDeleted: json["isDeleted"],
    invoicePath: json["invoicePath"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    progressPercent: json["progressPercent"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "customerSignature": customerSignature,
    "id": id,
    "createdBy": createdBy,
    "department": department,
    "serviceCategory": serviceCategory?.toJson(),
    "vehicle": vehicle,
    "customerName": customerName,
    "customerNumber": customerNumber,
    "customerAddress": customerAddress,
    "assignDate": assignDate?.toIso8601String(),
    "deadline": deadline?.toIso8601String(),
    "services": services == null ? [] : List<dynamic>.from(services!.map((x) => x.toJson())),
    "priority": priority,
    "difficulty": difficulty,
    "assignTo": assignTo == null ? [] : List<dynamic>.from(assignTo!.map((x) => x)),
    "otherAmount": otherAmount,
    "totalAmount": totalAmount,
    "status": status,
    "attachments": attachments == null ? [] : List<dynamic>.from(attachments!.map((x) => x)),
    "submitedDoc": submitedDoc == null ? [] : List<dynamic>.from(submitedDoc!.map((x) => x)),
    "isSubmited": isSubmited,
    "notes": notes,
    "isDeleted": isDeleted,
    "invoicePath": invoicePath,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "progressPercent": progressPercent,
  };
}

ServiceCategoryRef? _parseServiceCategory(dynamic data) {
  if (data == null) return null;
  if (data is Map<String, dynamic>) return ServiceCategoryRef.fromJson(data);
  return ServiceCategoryRef(id: data.toString(), name: null);
}

class ServiceCategoryRef {
  final String? id;
  final String? name;

  ServiceCategoryRef({this.id, this.name});

  factory ServiceCategoryRef.fromJson(Map<String, dynamic> json) => ServiceCategoryRef(
    id: json["_id"]?.toString() ?? json["id"]?.toString(),
    name: json["name"]?.toString(),
  );

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class Service {
  final String? name;
  final int? price;
  final int? quantity;
  final String? id;

  Service({
    this.name,
    this.price,
    this.quantity,
    this.id,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    name: json["name"],
    price: json["price"],
    quantity: json["quantity"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "price": price,
    "quantity": quantity,
    "_id": id,
  };
}