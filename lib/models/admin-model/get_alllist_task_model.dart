// To parse this JSON data, do
//
//     final getAllListTaskModel = getAllListTaskModelFromJson(jsonString);

import 'dart:convert';

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
  final Department? department;
  final Department? serviceCategory;
  final String? vehicle;
  final String? customerName;
  final String? customerNumber;
  final String? customerAddress;
  final DateTime? assignDate;
  final DateTime? deadline;
  final List<Service>? services;
  final String? priority;
  final String? difficulty;
  final String? assignTo;
  final int? otherAmount;
  final int? totalAmount;
  final Status? status;
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
    id: json["_id"],
    createdBy: json["createdBy"],
    department: json["department"] == null ? null : Department.fromJson(json["department"]),
    serviceCategory: json["serviceCategory"] == null ? null : Department.fromJson(json["serviceCategory"]),
    vehicle: json["vehicle"],
    customerName: json["customerName"],
    customerNumber: json["customerNumber"],
    customerAddress: json["customerAddress"],
    assignDate: json["assignDate"] == null ? null : DateTime.parse(json["assignDate"]),
    deadline: json["deadline"] == null ? null : DateTime.parse(json["deadline"]),
    services: json["services"] == null ? [] : List<Service>.from(json["services"]!.map((x) => Service.fromJson(x))),
    priority: json["priority"],
    difficulty: json["difficulty"],
    assignTo: json["assignTo"],
    otherAmount: json["otherAmount"],
    totalAmount: json["totalAmount"],
    status: _parseStatus(json["status"]),
    attachments: json["attachments"] == null ? [] : List<String>.from(json["attachments"]!.map((x) => x)),
    submitedDoc: json["submitedDoc"] == null ? [] : List<dynamic>.from(json["submitedDoc"]!.map((x) => x)),
    isSubmited: json["isSubmited"],
    notes: json["notes"],
    isDeleted: json["isDeleted"],
    invoicePath: json["invoicePath"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
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
    "assignDate": assignDate?.toIso8601String(),
    "deadline": deadline?.toIso8601String(),
    "services": services == null ? [] : List<dynamic>.from(services!.map((x) => x.toJson())),
    "priority": priority,
    "difficulty": difficulty,
    "assignTo": assignTo,
    "otherAmount": otherAmount,
    "totalAmount": totalAmount,
    "status": status?.toString().split('.').last.toLowerCase(),
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

enum Status {
  PENDING,
  PROGRESS,
  SUBMITED
}

Status _parseStatus(String? status) {
  if (status == null) return Status.PENDING;
  switch (status.toLowerCase()) {
    case 'pending':
      return Status.PENDING;
    case 'in_progress':
    case 'progress':
      return Status.PROGRESS;
    case 'submitted':
    case 'submited':
      return Status.SUBMITED;
    default:
      return Status.PENDING;
  }
}

class Department {
  final Id? id;
  final DepartmentName? name;

  Department({
    this.id,
    this.name,
  });

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    id: idValues.map[json["_id"]]!,
    name: departmentNameValues.map[json["name"]]!,
  );

  Map<String, dynamic> toJson() => {
    "_id": idValues.reverse[id],
    "name": departmentNameValues.reverse[name],
  };
}

enum Id {
  THE_691_A2210_FB67_F0_B04_E2_D7_CA0,
  THE_693_ECE9_F027_F6_F6_A151729_DE
}

final idValues = EnumValues({
  "691a2210fb67f0b04e2d7ca0": Id.THE_691_A2210_FB67_F0_B04_E2_D7_CA0,
  "693ece9f027f6f6a151729de": Id.THE_693_ECE9_F027_F6_F6_A151729_DE
});

enum DepartmentName {
  DFDSFDSFD,
  SAYED
}

final departmentNameValues = EnumValues({
  "dfdsfdsfd": DepartmentName.DFDSFDSFD,
  "sayed": DepartmentName.SAYED
});

class Service {
  final ServiceName? name;
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
    name: serviceNameValues.map[json["name"]]!,
    price: json["price"],
    quantity: json["quantity"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "name": serviceNameValues.reverse[name],
    "price": price,
    "quantity": quantity,
    "_id": id,
  };
}

enum ServiceName {
  A_SERVICE,
  B_SERVICE
}

final serviceNameValues = EnumValues({
  "A Service": ServiceName.A_SERVICE,
  "B Service": ServiceName.B_SERVICE
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
