class AllEmployeeTaskModel {
  final int? code;
  final String? message;
  final AllEmployeeTaskData? data;

  AllEmployeeTaskModel({
    this.code,
    this.message,
    this.data,
  });

  factory AllEmployeeTaskModel.fromJson(Map<String, dynamic> json) => AllEmployeeTaskModel(
        code: json["code"],
        message: json["message"],
        data: json["data"] == null ? null : AllEmployeeTaskData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "data": data?.toJson(),
      };
}

class AllEmployeeTaskData {
  final AllEmployeeTaskAttributes? attributes;

  AllEmployeeTaskData({
    this.attributes,
  });

  factory AllEmployeeTaskData.fromJson(Map<String, dynamic> json) => AllEmployeeTaskData(
        attributes: json["attributes"] == null
            ? null
            : AllEmployeeTaskAttributes.fromJson(json["attributes"]),
      );

  Map<String, dynamic> toJson() => {
        "attributes": attributes?.toJson(),
      };
}

class AllEmployeeTaskAttributes {
  final List<EmployeeTaskData>? results;
  final int? page;
  final int? limit;
  final int? totalPages;
  final int? totalResults;

  AllEmployeeTaskAttributes({
    this.results,
    this.page,
    this.limit,
    this.totalPages,
    this.totalResults,
  });

  factory AllEmployeeTaskAttributes.fromJson(Map<String, dynamic> json) =>
      AllEmployeeTaskAttributes(
        results: json["results"] == null
            ? []
            : List<EmployeeTaskData>.from(
                json["results"].map((x) => EmployeeTaskData.fromJson(x))),
        page: json["page"],
        limit: json["limit"],
        totalPages: json["totalPages"],
        totalResults: json["totalResults"],
      );

  Map<String, dynamic> toJson() => {
        "results": results == null
            ? []
            : List<dynamic>.from(results!.map((x) => x.toJson())),
        "page": page,
        "limit": limit,
        "totalPages": totalPages,
        "totalResults": totalResults,
      };
}

class EmployeeTaskData {
  final String? assignTo;
  final String? fullName;
  final String? image;
  final String? email;
  final Location? location;
  final int? totalPendingTask;
  final int? totalProgressTask;
  final int? totalCompliteTask;
  final List<String>? touches;
  final int? touchesCount;

  EmployeeTaskData({
    this.assignTo,
    this.fullName,
    this.image,
    this.email,
    this.location,
    this.totalPendingTask,
    this.totalProgressTask,
    this.totalCompliteTask,
    this.touches,
    this.touchesCount,
  });

  factory EmployeeTaskData.fromJson(Map<String, dynamic> json) =>
      EmployeeTaskData(
        assignTo: json["assignTo"],
        fullName: json["fullName"],
        image: json["image"],
        email: json["email"],
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        totalPendingTask: json["totalPendingTask"],
        totalProgressTask: json["totalProgressTask"],
        totalCompliteTask: json["totalCompliteTask"],
        touches: json["touches"] == null
            ? []
            : List<String>.from(json["touches"]),
        touchesCount: json["touchesCount"],
      );

  Map<String, dynamic> toJson() => {
        "assignTo": assignTo,
        "fullName": fullName,
        "image": image,
        "email": email,
        "location": location?.toJson(),
        "totalPendingTask": totalPendingTask,
        "totalProgressTask": totalProgressTask,
        "totalCompliteTask": totalCompliteTask,
        "touches": touches == null
            ? []
            : List<dynamic>.from(touches!),
        "touchesCount": touchesCount,
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
        coordinates: json["coordinates"] == null
            ? []
            : List<double>.from(json["coordinates"]),
        locationName: json["locationName"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates == null
            ? []
            : List<dynamic>.from(coordinates!),
        "locationName": locationName,
      };
}