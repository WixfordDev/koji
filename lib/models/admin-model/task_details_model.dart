import 'dart:convert';

TaskDetailsModel taskDetailsModelFromJson(String str) => TaskDetailsModel.fromJson(json.decode(str));

String taskDetailsModelToJson(TaskDetailsModel data) => json.encode(data.toJson());

class TaskDetailsModel {
  final AssignTo? createdBy;
  final Department? department;
  final Department? serviceCategory;
  final String? vehicle;  // Added vehicle field
  final String? customerName;
  final String? customerNumber;
  final String? customerAddress;
  final DateTime? assignDate;
  final DateTime? deadline;
  final List<Service>? services;
  final String? priority;
  final String? difficulty;
  final dynamic assignTo; // Changed to dynamic to handle different formats
  final int? otherAmount;
  final int? totalAmount;
  final String? status;
  final List<String>? attachments;
  final List<dynamic>? submitedDoc; // Changed to dynamic list
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
    vehicle: json["vehicle"]?.toString(), // Added vehicle field and ensure it's a string
    customerName: json["customerName"]?.toString(),
    customerNumber: json["customerNumber"]?.toString(),
    customerAddress: json["customerAddress"]?.toString(),
    assignDate: json["assignDate"] == null ? null : DateTime.parse(json["assignDate"].toString()).toLocal(),
    deadline: json["deadline"] == null ? null : DateTime.parse(json["deadline"].toString()).toLocal(),
    services: json["services"] == null ? [] : List<Service>.from(json["services"]!.map((x) => Service.fromJson(x))),
    priority: json["priority"]?.toString(),
    difficulty: json["difficulty"]?.toString(),
    assignTo: json["assignTo"], // Changed to dynamic, handle differently based on API response
    otherAmount: json["otherAmount"] is int ? json["otherAmount"] : (json["otherAmount"]?.toString() != null ? int.tryParse(json["otherAmount"].toString()) : null),
    totalAmount: json["totalAmount"] is int ? json["totalAmount"] : (json["totalAmount"]?.toString() != null ? int.tryParse(json["totalAmount"].toString()) : null),
    status: json["status"]?.toString(),
    attachments: json["attachments"] == null ? [] : List<String>.from(json["attachments"]!.map((x) => x.toString())),
    submitedDoc: json["submitedDoc"] == null ? [] : List<dynamic>.from(json["submitedDoc"]!.map((x) => x)), // Updated to dynamic
    isSubmited: json["isSubmited"] is bool ? json["isSubmited"] : (json["isSubmited"]?.toString() == 'true' || json["isSubmited"] == 1),
    notes: json["notes"]?.toString(),
    invoicePath: json["invoicePath"]?.toString(),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"].toString()),
    customerEmail: json["customerEmail"]?.toString(),
    paymentMethod: json["paymentMethod"]?.toString(),
    paymentStatus: json["paymentStatus"]?.toString(),
    customerSignature: json["customerSignature"]?.toString(),
    id: json["id"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "createdBy": createdBy?.toJson(),
    "department": department?.toJson(),
    "serviceCategory": serviceCategory?.toJson(),
    "vehicle": vehicle, // Added vehicle field
    "customerName": customerName,
    "customerNumber": customerNumber,
    "customerAddress": customerAddress,
    "assignDate": assignDate?.toIso8601String(),
    "deadline": deadline?.toIso8601String(),
    "services": services == null ? [] : List<dynamic>.from(services!.map((x) => x.toJson())),
    "priority": priority,
    "difficulty": difficulty,
    "assignTo": assignTo, // Changed to dynamic
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
    fullName: json["fullName"]?.toString(),
    email: json["email"]?.toString(),
    image: json["image"]?.toString(),
    phoneNumber: json["phoneNumber"]?.toString(),
    id: json["id"]?.toString(),
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
  final List<num>? coordinates;
  final String? locationName;

  Location({
    this.type,
    this.coordinates,
    this.locationName,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    type: json["type"]?.toString(),
    coordinates: json["coordinates"] == null ? [] : List<num>.from(json["coordinates"].map((x) => x is num ? x : (x?.toString() != null ? num.tryParse(x.toString()) ?? 0 : 0))),
    locationName: json["locationName"]?.toString(),
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
    name: json["name"]?.toString(),
    id: json["id"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "id": id,
  };
}

class Service {
  final String? name;
  final num? price;  // Changed to num to handle both int and double
  final int? quantity;
  final String? id;

  Service({
    this.name,
    this.price,
    this.quantity,
    this.id,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    name: json["name"]?.toString(),
    price: json["price"] is num ? json["price"] : (json["price"]?.toString() != null ? num.tryParse(json["price"].toString()) : null),
    quantity: json["quantity"] is int ? json["quantity"] : (json["quantity"]?.toString() != null ? int.tryParse(json["quantity"].toString()) : null),
    id: json["_id"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "price": price,
    "quantity": quantity,
    "_id": id,
  };
}
