// To parse this JSON data, do
//
//     final taskModel = taskModelFromJson(jsonString);

import 'dart:convert';

TaskModel taskModelFromJson(String str) => TaskModel.fromJson(json.decode(str));

String taskModelToJson(TaskModel data) => json.encode(data.toJson());

class TaskModel {
  final dynamic customerSignature;
  final String? id;
  final String? createdBy;
  final Department? department;
  final Department? serviceCategory;
  final String? vehicle;
  final String? customerName;
  final String? customerNumber;
  final String? customerAddress;
  final String? customerEmail;
  final DateTime? assignDate;
  final DateTime? deadline;
  final List<Service>? services;
  final String? priority;
  final String? difficulty;
  final String? assignTo;
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

  TaskModel({
    this.customerSignature,
    this.id,
    this.createdBy,
    this.department,
    this.serviceCategory,
    this.vehicle,
    this.customerName,
    this.customerNumber,
    this.customerAddress,
    this.customerEmail,
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

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    customerSignature: json["customerSignature"],
    id: json["_id"],
    createdBy: json["createdBy"],
    department: _parseDepartment(json["department"]),
    serviceCategory: _parseDepartment(json["serviceCategory"]),
    vehicle: json["vehicle"],
    customerName: json["customerName"],
    customerNumber: json["customerNumber"],
    customerAddress: json["customerAddress"],
    customerEmail: json["customerEmail"],
    assignDate: json["assignDate"] == null
        ? null
        : DateTime.parse(json["assignDate"]),
    deadline: json["deadline"] == null
        ? null
        : DateTime.parse(json["deadline"]),
    services: (json["services"] ?? json["service"]) == null
        ? []
        : List<Service>.from((json["services"] ?? json["service"])!.map((x) => Service.fromJson(x))),
    priority: json["priority"],
    difficulty: json["difficulty"],
    assignTo: json["assignTo"],
    otherAmount: json["otherAmount"],
    totalAmount: json["totalAmount"],
    status: json["status"],
    attachments: json["attachments"] == null
        ? []
        : List<String>.from(json["attachments"]!.map((x) => x)),
    submitedDoc: json["submitedDoc"] == null
        ? []
        : List<dynamic>.from(json["submitedDoc"]!.map((x) => x)),
    isSubmited: json["isSubmited"],
    notes: json["notes"],
    isDeleted: json["isDeleted"],
    invoicePath: json["invoicePath"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    progressPercent: json["progressPercent"],
  );

  Map<String, dynamic> toJson() => {
    "customerSignature": customerSignature,
    "_id": id,
    "createdBy": createdBy,
    "department": department?.toJson(),
    "serviceCategory": serviceCategory?.toJson(),
    "vehicle": vehicle,
    "customerName": customerName,
    "customerNumber": customerNumber,
    "customerAddress": customerAddress,
    "customerEmail": customerEmail,
    "assignDate": assignDate?.toIso8601String(),
    "deadline": deadline?.toIso8601String(),
    "services": services == null
        ? []
        : List<dynamic>.from(services!.map((x) => x.toJson())),
    "service": services == null
        ? []
        : List<dynamic>.from(services!.map((x) => x.toJson())), // Alias for backward compatibility
    "priority": priority,
    "difficulty": difficulty,
    "assignTo": assignTo,
    "otherAmount": otherAmount,
    "totalAmount": totalAmount,
    "status": status,
    "attachments": attachments == null
        ? []
        : List<dynamic>.from(attachments!.map((x) => x)),
    "submitedDoc": submitedDoc == null
        ? []
        : List<dynamic>.from(submitedDoc!.map((x) => x)),
    "isSubmited": isSubmited,
    "notes": notes,
    "isDeleted": isDeleted,
    "invoicePath": invoicePath,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "progressPercent": progressPercent,
  };

  // Getter to provide backward compatibility for 'service' field
  List<Service>? get service => services;
}

class Department {
  final String? id;
  final String? name;

  Department({this.id, this.name});

  factory Department.fromJson(Map<String, dynamic> json) =>
      Department(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class Service {
  final String? name;
  final num? price;
  final int? quantity;
  final String? id;

  Service({this.name, this.price, this.quantity, this.id});

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

// Helper function to parse department field which might be a string ID or a full object
Department? _parseDepartment(dynamic departmentData) {
  if (departmentData == null) {
    return null;
  } else if (departmentData is String) {
    // If it's a string (ID), create a minimal Department object
    return Department(id: departmentData, name: '');
  } else if (departmentData is Map<String, dynamic>) {
    // If it's a map (full object), parse normally
    return Department.fromJson(departmentData);
  } else {
    // Fallback case
    return Department(id: departmentData.toString(), name: '');
  }
}
