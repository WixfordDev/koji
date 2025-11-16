import 'dart:convert';


class Department {
  final String? createdBy;
  final String? name;
  final String? description;
  final DateTime? createdAt;
  final String? id;

  Department({
    this.createdBy,
    this.name,
    this.description,
    this.createdAt,
    this.id,
  });

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    createdBy: json["createdBy"],
    name: json["name"],
    description: json["description"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "createdBy": createdBy,
    "name": name,
    "description": description,
    "createdAt": createdAt?.toIso8601String(),
    "id": id,
  };
}

// Response Model with List
class AllDepartmentModel {
  final List<Department>? results;
  final int? page;
  final int? limit;
  final int? totalPages;
  final int? totalResults;

  AllDepartmentModel({
    this.results,
    this.page,
    this.limit,
    this.totalPages,
    this.totalResults,
  });

  factory AllDepartmentModel.fromJson(Map<String, dynamic> json) => AllDepartmentModel(
    results: json["results"] == null
        ? []
        : List<Department>.from(json["results"].map((x) => Department.fromJson(x))),
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