import 'dart:convert';

TransactionModel transactionModelFromJson(String str) => TransactionModel.fromJson(json.decode(str));

String transactionModelToJson(TransactionModel data) => json.encode(data.toJson());

class TransactionModel {
  final List<Result>? results;
  final int? page;
  final int? limit;
  final int? totalPages;
  final int? totalResults;

  TransactionModel({
    this.results,
    this.page,
    this.limit,
    this.totalPages,
    this.totalResults,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
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
  final EmployeeId? employeeId;
  final String? taskId;
  final String? transactionId;
  final int? amount;
  final String? invoice;
  final String? paymentMethod;
  final String? paymentStatus;
  final DateTime? createdAt;
  final String? id;

  Result({
    this.employeeId,
    this.taskId,
    this.transactionId,
    this.amount,
    this.invoice,
    this.paymentMethod,
    this.paymentStatus,
    this.createdAt,
    this.id,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    employeeId: json["employeeId"] == null ? null : EmployeeId.fromJson(json["employeeId"]),
    taskId: json["taskId"],
    transactionId: json["transactionId"],
    amount: json["amount"],
    invoice: json["invoice"],
    paymentMethod: json["paymentMethod"],
    paymentStatus: json["paymentStatus"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "employeeId": employeeId?.toJson(),
    "taskId": taskId,
    "transactionId": transactionId,
    "amount": amount,
    "invoice": invoice,
    "paymentMethod": paymentMethod,
    "paymentStatus": paymentStatus,
    "createdAt": createdAt?.toIso8601String(),
    "id": id,
  };
}

class EmployeeId {
  final String? fullName;
  final String? email;
  final String? image;
  final String? id;

  EmployeeId({
    this.fullName,
    this.email,
    this.image,
    this.id,
  });

  factory EmployeeId.fromJson(Map<String, dynamic> json) => EmployeeId(
    fullName: json["fullName"],
    email: json["email"],
    image: json["image"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "fullName": fullName,
    "email": email,
    "image": image,
    "id": id,
  };
}
