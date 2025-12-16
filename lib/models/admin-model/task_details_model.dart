import 'dart:convert';

TaskDetailsModel taskDetailsModelFromJson(String str) => TaskDetailsModel.fromJson(json.decode(str));

String taskDetailsModelToJson(TaskDetailsModel data) => json.encode(data.toJson());

class TaskDetailsModel {
  final AssignTo? createdBy;
  final Department? department;
  final Department? serviceCategory;
  final String? customerName;
  final String? customerNumber;
  final String? customerAddress;
  final DateTime? assignDate;
  final DateTime? deadline;
  final List<Service>? services;
  final String? priority;
  final String? difficulty;
  final AssignTo? assignTo;
  final int? otherAmount;
  final int? totalAmount;
  final String? status;
  final List<String>? attachments;
  final List<String>? submitedDoc;
  final bool? isSubmited;
  final String? notes;
  final String? invoicePath;
  final DateTime? createdAt;
  final String? customerEmail;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? customerSignature;
  final String? id;

  TaskDetailsModel({
    this.createdBy,
    this.department,
    this.serviceCategory,
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
    this.invoicePath,
    this.createdAt,
    this.customerEmail,
    this.paymentMethod,
    this.paymentStatus,
    this.customerSignature,
    this.id,
  });

  factory TaskDetailsModel.fromJson(Map<String, dynamic> json) => TaskDetailsModel(
    createdBy: json["createdBy"] == null ? null : AssignTo.fromJson(json["createdBy"]),
    department: json["department"] == null ? null : Department.fromJson(json["department"]),
    serviceCategory: json["serviceCategory"] == null ? null : Department.fromJson(json["serviceCategory"]),
    customerName: json["customerName"],
    customerNumber: json["customerNumber"],
    customerAddress: json["customerAddress"],
    assignDate: json["assignDate"] == null ? null : DateTime.parse(json["assignDate"]),
    deadline: json["deadline"] == null ? null : DateTime.parse(json["deadline"]),
    services: json["services"] == null ? [] : List<Service>.from(json["services"]!.map((x) => Service.fromJson(x))),
    priority: json["priority"],
    difficulty: json["difficulty"],
    assignTo: json["assignTo"] == null ? null : AssignTo.fromJson(json["assignTo"]),
    otherAmount: json["otherAmount"],
    totalAmount: json["totalAmount"],
    status: json["status"],
    attachments: json["attachments"] == null ? [] : List<String>.from(json["attachments"]!.map((x) => x)),
    submitedDoc: json["submitedDoc"] == null ? [] : List<String>.from(json["submitedDoc"]!.map((x) => x)),
    isSubmited: json["isSubmited"],
    notes: json["notes"],
    invoicePath: json["invoicePath"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    customerEmail: json["customerEmail"],
    paymentMethod: json["paymentMethod"],
    paymentStatus: json["paymentStatus"],
    customerSignature: json["customerSignature"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "createdBy": createdBy?.toJson(),
    "department": department?.toJson(),
    "serviceCategory": serviceCategory?.toJson(),
    "customerName": customerName,
    "customerNumber": customerNumber,
    "customerAddress": customerAddress,
    "assignDate": assignDate?.toIso8601String(),
    "deadline": deadline?.toIso8601String(),
    "services": services == null ? [] : List<dynamic>.from(services!.map((x) => x.toJson())),
    "priority": priority,
    "difficulty": difficulty,
    "assignTo": assignTo?.toJson(),
    "otherAmount": otherAmount,
    "totalAmount": totalAmount,
    "status": status,
    "attachments": attachments == null ? [] : List<dynamic>.from(attachments!.map((x) => x)),
    "submitedDoc": submitedDoc == null ? [] : List<dynamic>.from(submitedDoc!.map((x) => x)),
    "isSubmited": isSubmited,
    "notes": notes,
    "invoicePath": invoicePath,
    "createdAt": createdAt?.toIso8601String(),
    "customerEmail": customerEmail,
    "paymentMethod": paymentMethod,
    "paymentStatus": paymentStatus,
    "customerSignature": customerSignature,
    "id": id,
  };
}

class AssignTo {
  final Location? location;
  final String? fullName;
  final String? email;
  final String? image;
  final String? phoneNumber;
  final String? id;

  AssignTo({
    this.location,
    this.fullName,
    this.email,
    this.image,
    this.phoneNumber,
    this.id,
  });

  factory AssignTo.fromJson(Map<String, dynamic> json) => AssignTo(
    location: json["location"] == null ? null : Location.fromJson(json["location"]),
    fullName: json["fullName"],
    email: json["email"],
    image: json["image"],
    phoneNumber: json["phoneNumber"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "location": location?.toJson(),
    "fullName": fullName,
    "email": email,
    "image": image,
    "phoneNumber": phoneNumber,
    "id": id,
  };
}

class Location {
  final String? type;
  final List<double>? coordinates;
  final String? locationName;

  Location({
    this.type,
    this.coordinates,
    this.locationName,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    type: json["type"],
    coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
    locationName: json["locationName"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
    "locationName": locationName,
  };
}

class Department {
  final String? name;
  final String? id;

  Department({
    this.name,
    this.id,
  });

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    name: json["name"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "id": id,
  };
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
