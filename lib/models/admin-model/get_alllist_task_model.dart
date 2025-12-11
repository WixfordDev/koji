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
  final String? id;
  final CreatedBy? createdBy;
  final Department? department;
  final ServiceCategory? serviceCategory;
  final String? customerName;
  final String? customerNumber;
  final CustomerAddress? customerAddress;
  final DateTime? assignDate;
  final DateTime? deadline;
  final List<Service>? services;
  final Priority? priority;
  final Difficulty? difficulty;
  final String? assignTo;
  final int? otherAmount;
  final int? totalAmount;
  final Status? status;
  final List<String>? attachments;
  final List<String>? submitedDoc;
  final bool? isSubmited;
  final Notes? notes;
  final bool? isDeleted;
  final String? invoicePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? customerEmail;
  final String? paymentMethod;
  final Status? paymentStatus;
  final int? progressPercent;

  Result({
    this.id,
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
    this.isDeleted,
    this.invoicePath,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.customerEmail,
    this.paymentMethod,
    this.paymentStatus,
    this.progressPercent,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["_id"],
    createdBy: createdByValues.map[json["createdBy"]]!,
    department: departmentValues.map[json["department"]]!,
    serviceCategory: serviceCategoryValues.map[json["serviceCategory"]]!,
    customerName: json["customerName"],
    customerNumber: json["customerNumber"],
    customerAddress: customerAddressValues.map[json["customerAddress"]]!,
    assignDate: json["assignDate"] == null ? null : DateTime.parse(json["assignDate"]),
    deadline: json["deadline"] == null ? null : DateTime.parse(json["deadline"]),
    services: json["services"] == null ? [] : List<Service>.from(json["services"]!.map((x) => Service.fromJson(x))),
    priority: priorityValues.map[json["priority"]]!,
    difficulty: difficultyValues.map[json["difficulty"]]!,
    assignTo: json["assignTo"],
    otherAmount: json["otherAmount"],
    totalAmount: json["totalAmount"],
    status: statusValues.map[json["status"]]!,
    attachments: json["attachments"] == null ? [] : List<String>.from(json["attachments"]!.map((x) => x)),
    submitedDoc: json["submitedDoc"] == null ? [] : List<String>.from(json["submitedDoc"]!.map((x) => x)),
    isSubmited: json["isSubmited"],
    notes: notesValues.map[json["notes"]]!,
    isDeleted: json["isDeleted"],
    invoicePath: json["invoicePath"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    customerEmail: json["customerEmail"],
    paymentMethod: json["paymentMethod"],
    paymentStatus: statusValues.map[json["paymentStatus"]]!,
    progressPercent: json["progressPercent"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "createdBy": createdByValues.reverse[createdBy],
    "department": departmentValues.reverse[department],
    "serviceCategory": serviceCategoryValues.reverse[serviceCategory],
    "customerName": customerName,
    "customerNumber": customerNumber,
    "customerAddress": customerAddressValues.reverse[customerAddress],
    "assignDate": assignDate?.toIso8601String(),
    "deadline": deadline?.toIso8601String(),
    "services": services == null ? [] : List<dynamic>.from(services!.map((x) => x.toJson())),
    "priority": priorityValues.reverse[priority],
    "difficulty": difficultyValues.reverse[difficulty],
    "assignTo": assignTo,
    "otherAmount": otherAmount,
    "totalAmount": totalAmount,
    "status": statusValues.reverse[status],
    "attachments": attachments == null ? [] : List<dynamic>.from(attachments!.map((x) => x)),
    "submitedDoc": submitedDoc == null ? [] : List<dynamic>.from(submitedDoc!.map((x) => x)),
    "isSubmited": isSubmited,
    "notes": notesValues.reverse[notes],
    "isDeleted": isDeleted,
    "invoicePath": invoicePath,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "customerEmail": customerEmail,
    "paymentMethod": paymentMethod,
    "paymentStatus": statusValues.reverse[paymentStatus],
    "progressPercent": progressPercent,
  };
}

enum CreatedBy {
  THE_68_FFB63_E25_EDFF0158577499
}

final createdByValues = EnumValues({
  "68ffb63e25edff0158577499": CreatedBy.THE_68_FFB63_E25_EDFF0158577499
});

enum CustomerAddress {
  DFSFD,
  HOUSE_12_ROAD_7_DHANMONDI_DHAKA,
  HOUSE_77_ROAD_7_DHANMONDI_DHAKA
}

final customerAddressValues = EnumValues({
  "dfsfd": CustomerAddress.DFSFD,
  "House 12, Road 7, Dhanmondi, Dhaka": CustomerAddress.HOUSE_12_ROAD_7_DHANMONDI_DHAKA,
  "House 77, Road 7, Dhanmondi, Dhaka": CustomerAddress.HOUSE_77_ROAD_7_DHANMONDI_DHAKA
});

enum Department {
  THE_690_A0_B65860_CE1617_D61862_C,
  THE_6913678_ABFD403_C13215_C321,
  THE_691_A2210_FB67_F0_B04_E2_D7_CA0
}

final departmentValues = EnumValues({
  "690a0b65860ce1617d61862c": Department.THE_690_A0_B65860_CE1617_D61862_C,
  "6913678abfd403c13215c321": Department.THE_6913678_ABFD403_C13215_C321,
  "691a2210fb67f0b04e2d7ca0": Department.THE_691_A2210_FB67_F0_B04_E2_D7_CA0
});

enum Difficulty {
  MODERATE,
  VERY_EASY
}

final difficultyValues = EnumValues({
  "moderate": Difficulty.MODERATE,
  "very easy": Difficulty.VERY_EASY
});

enum Notes {
  CUSTOMER_REQUESTED_INSTALLATION_BEFORE_NOON,
  EMPTY
}

final notesValues = EnumValues({
  "Customer requested installation before noon.": Notes.CUSTOMER_REQUESTED_INSTALLATION_BEFORE_NOON,
  "": Notes.EMPTY
});

enum Status {
  PENDING,
  PROGRESS,
  SUBMITED
}

final statusValues = EnumValues({
  "pending": Status.PENDING,
  "progress": Status.PROGRESS,
  "submited": Status.SUBMITED
});

enum Priority {
  MEDIUM
}

final priorityValues = EnumValues({
  "medium": Priority.MEDIUM
});

enum ServiceCategory {
  THE_690_A1088223815_BCB3528_A5_B,
  THE_691_A224_FFB67_F0_B04_E2_D7_CB7
}

final serviceCategoryValues = EnumValues({
  "690a1088223815bcb3528a5b": ServiceCategory.THE_690_A1088223815_BCB3528_A5_B,
  "691a224ffb67f0b04e2d7cb7": ServiceCategory.THE_691_A224_FFB67_F0_B04_E2_D7_CB7
});

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

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
