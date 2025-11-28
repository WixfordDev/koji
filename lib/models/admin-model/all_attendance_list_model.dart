import 'dart:convert';

AllAttendanceModel allAttendanceModelFromJson(String str) => AllAttendanceModel.fromJson(json.decode(str));

String allAttendanceModelToJson(AllAttendanceModel data) => json.encode(data.toJson());

class AllAttendanceModel {
  final List<Attendance>? results;
  final int? totalResults;

  AllAttendanceModel({
    this.results,
    this.totalResults,
  });

  factory AllAttendanceModel.fromJson(Map<String, dynamic> json) => AllAttendanceModel(
    results: json["results"] == null
        ? []
        : List<Attendance>.from(json["results"].map((x) => Attendance.fromJson(x))),
    totalResults: json["totalResults"],
  );

  Map<String, dynamic> toJson() => {
    "results": results == null ? [] : List<dynamic>.from(results!.map((x) => x.toJson())),
    "totalResults": totalResults,
  };
}

class Attendance {
  final String? id;
  final String? status;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final String? notes;
  final Employee? employee;

  Attendance({
    this.id,
    this.status,
    this.clockIn,
    this.clockOut,
    this.notes,
    this.employee,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
    id: json["id"],
    status: json["status"],
    clockIn: json["clockIn"] == null ? null : DateTime.parse(json["clockIn"]),
    clockOut: json["clockOut"] == null ? null : DateTime.parse(json["clockOut"]),
    notes: json["notes"],
    employee: json["employee"] == null ? null : Employee.fromJson(json["employee"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "clockIn": clockIn?.toIso8601String(),
    "clockOut": clockOut?.toIso8601String(),
    "notes": notes,
    "employee": employee?.toJson(),
  };
}

class Employee {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;
  final String? image;
  final String? role;

  Employee({
    this.id,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.image,
    this.role,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json["id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    fullName: json["fullName"],
    email: json["email"],
    image: json["image"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "fullName": fullName,
    "email": email,
    "image": image,
    "role": role,
  };
}