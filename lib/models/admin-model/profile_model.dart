import 'dart:convert';

ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  final User? user;
  final SecuritySettings? securitySettings;

  ProfileModel({
    this.user,
    this.securitySettings,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    securitySettings: json["securitySettings"] == null ? null : SecuritySettings.fromJson(json["securitySettings"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "securitySettings": securitySettings?.toJson(),
  };
}

class SecuritySettings {
  final dynamic recoveryEmail;
  final dynamic recoveryPhone;
  final dynamic securityQuestion;

  SecuritySettings({
    this.recoveryEmail,
    this.recoveryPhone,
    this.securityQuestion,
  });

  factory SecuritySettings.fromJson(Map<String, dynamic> json) => SecuritySettings(
    recoveryEmail: json["recoveryEmail"],
    recoveryPhone: json["recoveryPhone"],
    securityQuestion: json["securityQuestion"],
  );

  Map<String, dynamic> toJson() => {
    "recoveryEmail": recoveryEmail,
    "recoveryPhone": recoveryPhone,
    "securityQuestion": securityQuestion,
  };
}

class User {
  final Location? location;
  final dynamic officeStartTime;
  final dynamic officeEndTime;
  final String? firstName;
  final dynamic lastName;
  final String? fullName;
  final String? email;
  final String? image;
  final String? role;
  final String? callingCode;
  final String? phoneNumber;
  final dynamic dateOfBirth;
  final dynamic address;
  final bool? isProfileCompleted;
  final bool? isAdminApproved;
  final bool? isAcceptPolicyTerms;
  final DateTime? createdAt;
  final String? id;

  User({
    this.location,
    this.officeStartTime,
    this.officeEndTime,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.image,
    this.role,
    this.callingCode,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
    this.isProfileCompleted,
    this.isAdminApproved,
    this.isAcceptPolicyTerms,
    this.createdAt,
    this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    location: json["location"] == null ? null : Location.fromJson(json["location"]),
    officeStartTime: json["officeStartTime"],
    officeEndTime: json["officeEndTime"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    fullName: json["fullName"],
    email: json["email"],
    image: json["image"],
    role: json["role"],
    callingCode: json["callingCode"],
    phoneNumber: json["phoneNumber"],
    dateOfBirth: json["dateOfBirth"],
    address: json["address"],
    isProfileCompleted: json["isProfileCompleted"],
    isAdminApproved: json["isAdminApproved"],
    isAcceptPolicyTerms: json["isAcceptPolicyTerms"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "location": location?.toJson(),
    "officeStartTime": officeStartTime,
    "officeEndTime": officeEndTime,
    "firstName": firstName,
    "lastName": lastName,
    "fullName": fullName,
    "email": email,
    "image": image,
    "role": role,
    "callingCode": callingCode,
    "phoneNumber": phoneNumber,
    "dateOfBirth": dateOfBirth,
    "address": address,
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
    coordinates: _parseCoordinates(json["coordinates"]),
    locationName: json["locationName"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
    "locationName": locationName,
  };
}

// Helper function to parse coordinates which might contain int or double values
List<double>? _parseCoordinates(dynamic coordinatesData) {
  if (coordinatesData == null) {
    return null;
  } else if (coordinatesData is List) {
    List<double> result = [];
    for (var item in coordinatesData) {
      if (item is int) {
        result.add(item.toDouble());
      } else if (item is double) {
        result.add(item);
      } else {
        result.add(0.0); // fallback for unexpected types
      }
    }
    return result;
  } else {
    return null;
  }
}
