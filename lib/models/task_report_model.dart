class TaskReportModel {
  final int code;
  final String message;
  final TaskReportData data;

  TaskReportModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory TaskReportModel.fromJson(Map<String, dynamic> json) {
    return TaskReportModel(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: TaskReportData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class TaskReportData {
  final TaskReportAttributes attributes;

  TaskReportData({required this.attributes});

  factory TaskReportData.fromJson(Map<String, dynamic> json) {
    return TaskReportData(
      attributes: TaskReportAttributes.fromJson(json['attributes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attributes': attributes.toJson(),
    };
  }
}

class TaskReportAttributes {
  final User createdBy;
  final Department department;
  final ServiceCategory serviceCategory;
  final String customerName;
  final String customerNumber;
  final String customerAddress;
  final String assignDate;
  final String deadline;
  final List<Service> services;
  final String priority;
  final String difficulty;
  final User assignTo;
  final int otherAmount;
  final int totalAmount;
  final String status;
  final List<String> attachments;
  final List<String> submitedDoc;
  final bool isSubmited;
  final String notes;
  final String? invoicePath;
  final String createdAt;
  final String? customerEmail;
  final String? paymentMethod;
  final String paymentStatus;
  final String id;

  TaskReportAttributes({
    required this.createdBy,
    required this.department,
    required this.serviceCategory,
    required this.customerName,
    required this.customerNumber,
    required this.customerAddress,
    required this.assignDate,
    required this.deadline,
    required this.services,
    required this.priority,
    required this.difficulty,
    required this.assignTo,
    required this.otherAmount,
    required this.totalAmount,
    required this.status,
    required this.attachments,
    required this.submitedDoc,
    required this.isSubmited,
    required this.notes,
    this.invoicePath,
    required this.createdAt,
    this.customerEmail,
    this.paymentMethod,
    required this.paymentStatus,
    required this.id,
  });

  factory TaskReportAttributes.fromJson(Map<String, dynamic> json) {
    return TaskReportAttributes(
      createdBy: User.fromJson(json['createdBy']),
      department: Department.fromJson(json['department']),
      serviceCategory: ServiceCategory.fromJson(json['serviceCategory']),
      customerName: json['customerName'] ?? '',
      customerNumber: json['customerNumber'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      assignDate: json['assignDate'] ?? '',
      deadline: json['deadline'] ?? '',
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => Service.fromJson(e))
              .toList() ??
          [],
      priority: json['priority'] ?? '',
      difficulty: json['difficulty'] ?? '',
      assignTo: User.fromJson(json['assignTo']),
      otherAmount: json['otherAmount'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,
      status: json['status'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
      submitedDoc: List<String>.from(json['submitedDoc'] ?? []),
      isSubmited: json['isSubmited'] ?? false,
      notes: json['notes'] ?? '',
      invoicePath: json['invoicePath'],
      createdAt: json['createdAt'] ?? '',
      customerEmail: json['customerEmail'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdBy': createdBy.toJson(),
      'department': department.toJson(),
      'serviceCategory': serviceCategory.toJson(),
      'customerName': customerName,
      'customerNumber': customerNumber,
      'customerAddress': customerAddress,
      'assignDate': assignDate,
      'deadline': deadline,
      'services': services.map((e) => e.toJson()).toList(),
      'priority': priority,
      'difficulty': difficulty,
      'assignTo': assignTo.toJson(),
      'otherAmount': otherAmount,
      'totalAmount': totalAmount,
      'status': status,
      'attachments': attachments,
      'submitedDoc': submitedDoc,
      'isSubmited': isSubmited,
      'notes': notes,
      'invoicePath': invoicePath,
      'createdAt': createdAt,
      'customerEmail': customerEmail,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'id': id,
    };
  }
}

class User {
  final Location location;
  final String? officeStartTime;
  final String? officeEndTime;
  final String firstName;
  final String? lastName;
  final String fullName;
  final String email;
  final String image;
  final String role;
  final String callingCode;
  final String phoneNumber;
  final String? dateOfBirth;
  final String? address;
  final bool isProfileCompleted;
  final bool isAdminApproved;
  final bool isAcceptPolicyTerms;
  final String createdAt;
  final String id;

  User({
    required this.location,
    this.officeStartTime,
    this.officeEndTime,
    required this.firstName,
    this.lastName,
    required this.fullName,
    required this.email,
    required this.image,
    required this.role,
    required this.callingCode,
    required this.phoneNumber,
    this.dateOfBirth,
    this.address,
    required this.isProfileCompleted,
    required this.isAdminApproved,
    required this.isAcceptPolicyTerms,
    required this.createdAt,
    required this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      location: Location.fromJson(json['location']),
      officeStartTime: json['officeStartTime'],
      officeEndTime: json['officeEndTime'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      role: json['role'] ?? '',
      callingCode: json['callingCode'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      dateOfBirth: json['dateOfBirth'],
      address: json['address'],
      isProfileCompleted: json['isProfileCompleted'] ?? false,
      isAdminApproved: json['isAdminApproved'] ?? false,
      isAcceptPolicyTerms: json['isAcceptPolicyTerms'] ?? false,
      createdAt: json['createdAt'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'officeStartTime': officeStartTime,
      'officeEndTime': officeEndTime,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'email': email,
      'image': image,
      'role': role,
      'callingCode': callingCode,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'isProfileCompleted': isProfileCompleted,
      'isAdminApproved': isAdminApproved,
      'isAcceptPolicyTerms': isAcceptPolicyTerms,
      'createdAt': createdAt,
      'id': id,
    };
  }
}

class Location {
  final String type;
  final List<double> coordinates;
  final String locationName;

  Location({
    required this.type,
    required this.coordinates,
    required this.locationName,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? '',
      coordinates: List<double>.from(json['coordinates'] ?? []),
      locationName: json['locationName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
      'locationName': locationName,
    };
  }
}

class Department {
  final String createdBy;
  final String name;
  final String? description;
  final String createdAt;
  final String id;

  Department({
    required this.createdBy,
    required this.name,
    this.description,
    required this.createdAt,
    required this.id,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      createdBy: json['createdBy'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      createdAt: json['createdAt'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdBy': createdBy,
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'id': id,
    };
  }
}

class ServiceCategory {
  final String createdBy;
  final String type;
  final String name;
  final String? description;
  final String createdAt;
  final String id;

  ServiceCategory({
    required this.createdBy,
    required this.type,
    required this.name,
    this.description,
    required this.createdAt,
    required this.id,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      createdBy: json['createdBy'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      createdAt: json['createdAt'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdBy': createdBy,
      'type': type,
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'id': id,
    };
  }
}

class Service {
  final String name;
  final int price;
  final int quantity;
  final String id;

  Service({
    required this.name,
    required this.price,
    required this.quantity,
    required this.id,
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
      'id': id,
    };
  }
}