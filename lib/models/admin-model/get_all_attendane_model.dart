import 'dart:convert';

AllAttendanceModel allAttendanceModelFromJson(String str) => AllAttendanceModel.fromJson(json.decode(str));

String allAttendanceModelToJson(AllAttendanceModel data) => json.encode(data.toJson());

class AllAttendanceModel {
  final AllAttendanceModelLocation? location;
  final Employee? employee;
  final DateTime? date;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final int? totalHours;
  final String? status;
  final String? notes;
  final DateTime? createdAt;
  final String? id;

  AllAttendanceModel({
    this.location,
    this.employee,
    this.date,
    this.clockIn,
    this.clockOut,
    this.totalHours,
    this.status,
    this.notes,
    this.createdAt,
    this.id,
  });

  factory AllAttendanceModel.fromJson(Map<String, dynamic> json) => AllAttendanceModel(
    location: json["location"] == null ? null : AllAttendanceModelLocation.fromJson(json["location"]),
    employee: json["employee"] == null ? null : Employee.fromJson(json["employee"]),
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    clockIn: json["clockIn"] == null ? null : DateTime.parse(json["clockIn"]),
    clockOut: json["clockOut"] == null ? null : DateTime.parse(json["clockOut"]),
    totalHours: json["totalHours"],
    status: json["status"],
    notes: json["notes"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "location": location?.toJson(),
    "employee": employee?.toJson(),
    "date": date?.toIso8601String(),
    "clockIn": clockIn?.toIso8601String(),
    "clockOut": clockOut?.toIso8601String(),
    "totalHours": totalHours,
    "status": status,
    "notes": notes,
    "createdAt": createdAt?.toIso8601String(),
    "id": id,
  };
}

class Employee {
  final EmployeeLocation? location;
  final String? fullName;
  final String? email;
  final String? image;
  final String? role;
  final dynamic address;
  final String? id;

  Employee({
    this.location,
    this.fullName,
    this.email,
    this.image,
    this.role,
    this.address,
    this.id,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    location: json["location"] == null ? null : EmployeeLocation.fromJson(json["location"]),
    fullName: json["fullName"],
    email: json["email"],
    image: json["image"],
    role: json["role"],
    address: json["address"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "location": location?.toJson(),
    "fullName": fullName,
    "email": email,
    "image": image,
    "role": role,
    "address": address,
    "id": id,
  };
}

class EmployeeLocation {
  final String? type;
  final List<double>? coordinates;
  final String? locationName;

  EmployeeLocation({
    this.type,
    this.coordinates,
    this.locationName,
  });

  factory EmployeeLocation.fromJson(Map<String, dynamic> json) => EmployeeLocation(
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

class AllAttendanceModelLocation {
  final String? name;
  final String? type;
  final List<double>? coordinates;

  AllAttendanceModelLocation({
    this.name,
    this.type,
    this.coordinates,
  });

  factory AllAttendanceModelLocation.fromJson(Map<String, dynamic> json) => AllAttendanceModelLocation(
    name: json["name"],
    type: json["type"],
    coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "type": type,
    "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
  };
}
