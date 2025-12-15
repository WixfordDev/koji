class TaskModel {
  final String? customerEmail;
  final List<dynamic> submitedDoc;
  final bool isSubmited;
  final String? invoicePath;
  final String paymentStatus;
  final String? paymentMethod;
  final String id;
  final String createdBy;
  final String department;
  final String serviceCategory;
  final String customerName;
  final String customerNumber;
  final String customerAddress;
  final String assignDate;
  final String deadline;
  final List<Service> services;
  final String assignTo;
  final int otherAmount;
  final int totalAmount;
  final String status;
  final List<dynamic> attachments;
  final String notes;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final int v;
  final String difficulty;
  final String priority;
  final int progressPercent;

  TaskModel({
    this.customerEmail,
    required this.submitedDoc,
    required this.isSubmited,
    this.invoicePath,
    required this.paymentStatus,
    this.paymentMethod,
    required this.id,
    required this.createdBy,
    required this.department,
    required this.serviceCategory,
    required this.customerName,
    required this.customerNumber,
    required this.customerAddress,
    required this.assignDate,
    required this.deadline,
    required this.services,
    required this.assignTo,
    required this.otherAmount,
    required this.totalAmount,
    required this.status,
    required this.attachments,
    required this.notes,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.difficulty,
    required this.priority,
    required this.progressPercent,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      customerEmail: json['customerEmail'],
      submitedDoc: json['submitedDoc'] ?? [],
      isSubmited: json['isSubmited'] ?? false,
      invoicePath: json['invoicePath'],
      paymentStatus: json['paymentStatus'] ?? '',
      paymentMethod: json['paymentMethod'],
      id: json['_id'] ?? '',
      createdBy: json['createdBy'] ?? '',
      department: json['department'] ?? '',
      serviceCategory: json['serviceCategory'] ?? '',
      customerName: json['customerName'] ?? '',
      customerNumber: json['customerNumber'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      assignDate: json['assignDate'] ?? '',
      deadline: json['deadline'] ?? '',
      services:
          (json['services'] as List<dynamic>?)
              ?.map((e) => Service.fromJson(e))
              .toList() ??
          [],
      assignTo: json['assignTo'] ?? '',
      otherAmount: json['otherAmount'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,
      status: json['status'] ?? '',
      attachments: json['attachments'] ?? [],
      notes: json['notes'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
      difficulty: json['difficulty'] ?? '',
      priority: json['priority'] ?? '',
      progressPercent: json['progressPercent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerEmail': customerEmail,
      'submitedDoc': submitedDoc,
      'isSubmited': isSubmited,
      'invoicePath': invoicePath,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'id': id,
      'createdBy': createdBy,
      'department': department,
      'serviceCategory': serviceCategory,
      'customerName': customerName,
      'customerNumber': customerNumber,
      'customerAddress': customerAddress,
      'assignDate': assignDate,
      'deadline': deadline,
      'services': services.map((e) => e.toJson()).toList(),
      'assignTo': assignTo,
      'otherAmount': otherAmount,
      'totalAmount': totalAmount,
      'status': status,
      'attachments': attachments,
      'notes': notes,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'difficulty': difficulty,
      'priority': priority,
      'progressPercent': progressPercent,
    };
  }
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

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 0,
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      '_id': id,
    };
  }
}

class TaskResponse {
  final int code;
  final String message;
  final TaskData data;

  TaskResponse({required this.code, required this.message, required this.data});

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    return TaskResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: TaskData.fromJson(json['data']),
    );
  }
}

class TaskData {
  final Attributes attributes;

  TaskData({required this.attributes});

  factory TaskData.fromJson(Map<String, dynamic> json) {
    return TaskData(attributes: Attributes.fromJson(json['attributes']));
  }
}

class Attributes {
  final List<TaskModel> results;
  final int page;
  final int limit;
  final int totalPages;
  final int totalResults;

  Attributes({
    required this.results,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalResults,
  });

  factory Attributes.fromJson(Map<String, dynamic> json) {
    return Attributes(
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => TaskModel.fromJson(e))
              .toList() ??
          [],
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
      totalResults: json['totalResults'] ?? 0,
    );
  }
}
