
import 'dart:convert';

// Single Category Model
class Category {
  final String? createdBy;
  final String? type;
  final String? name;
  final String? description;
  final DateTime? createdAt;
  final String? id;

  Category({
    this.createdBy,
    this.type,
    this.name,
    this.description,
    this.createdAt,
    this.id,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    createdBy: json["createdBy"],
    type: json["type"],
    name: json["name"],
    description: json["description"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "createdBy": createdBy,
    "type": type,
    "name": name,
    "description": description,
    "createdAt": createdAt?.toIso8601String(),
    "id": id,
  };
}

// Response Model with List
class AllCategoriesModel {
  final List<Category>? results;
  final int? page;
  final int? limit;
  final int? totalPages;
  final int? totalResults;

  AllCategoriesModel({
    this.results,
    this.page,
    this.limit,
    this.totalPages,
    this.totalResults,
  });

  factory AllCategoriesModel.fromJson(Map<String, dynamic> json) => AllCategoriesModel(
    results: json["results"] == null
        ? []
        : List<Category>.from(json["results"].map((x) => Category.fromJson(x))),
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
