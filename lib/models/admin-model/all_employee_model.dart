
import 'dart:convert';

AllEmployeeModel allEmployeeModelFromJson(String str) => AllEmployeeModel.fromJson(json.decode(str));

String allEmployeeModelToJson(AllEmployeeModel data) => json.encode(data.toJson());

class AllEmployeeModel {
  final List<Employee>? results;
  final int? totalResults;

  AllEmployeeModel({
    this.results,
    this.totalResults,
  });

  factory AllEmployeeModel.fromJson(Map<String, dynamic> json) => AllEmployeeModel(
    results: json["results"] == null
        ? []
        : List<Employee>.from(json["results"].map((x) => Employee.fromJson(x))),
    totalResults: json["totalResults"],
  );

  Map<String, dynamic> toJson() => {
    "results": results == null ? [] : List<dynamic>.from(results!.map((x) => x.toJson())),
    "totalResults": totalResults,
  };
}

class Employee {
  final Location? location;
  final dynamic firstName;
  final dynamic lastName;
  final String? fullName;
  final String? email;
  final String? image;
  final String? role;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final dynamic address;
  final String? gender;
  final String? shift;
  final String? officeStartTime;
  final String? officeEndTime;
  final bool? isProfileCompleted;
  final bool? isAdminApproved;
  final bool? isAcceptPolicyTerms;
  final DateTime? createdAt;
  final String? id;

  Employee({
    this.location,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.image,
    this.role,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
    this.gender,
    this.shift,
    this.officeStartTime,
    this.officeEndTime,
    this.isProfileCompleted,
    this.isAdminApproved,
    this.isAcceptPolicyTerms,
    this.createdAt,
    this.id,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    location: json["location"] == null ? null : Location.fromJson(json["location"]),
    firstName: json["firstName"],
    lastName: json["lastName"],
    fullName: json["fullName"],
    email: json["email"],
    image: json["image"],
    role: json["role"],
    phoneNumber: json["phoneNumber"],
    dateOfBirth: json["dateOfBirth"] == null ? null : DateTime.parse(json["dateOfBirth"]),
    address: json["address"],
    gender: json["gender"],
    shift: json["shift"],
    officeStartTime: json["officeStartTime"],
    officeEndTime: json["officeEndTime"],
    isProfileCompleted: json["isProfileCompleted"],
    isAdminApproved: json["isAdminApproved"],
    isAcceptPolicyTerms: json["isAcceptPolicyTerms"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "location": location?.toJson(),
    "firstName": firstName,
    "lastName": lastName,
    "fullName": fullName,
    "email": email,
    "image": image,
    "role": role,
    "phoneNumber": phoneNumber,
    "dateOfBirth": dateOfBirth?.toIso8601String(),
    "address": address,
    "gender": gender,
    "shift": shift,
    "officeStartTime": officeStartTime,
    "officeEndTime": officeEndTime,
    "isProfileCompleted": isProfileCompleted,
    "isAdminApproved": isAdminApproved,
    "isAcceptPolicyTerms": isAcceptPolicyTerms,
    "createdAt": createdAt?.toIso8601String(),
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
