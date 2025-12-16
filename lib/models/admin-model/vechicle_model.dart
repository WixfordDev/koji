class AllVehicleModel {
  Attributes? attributes;

  AllVehicleModel({this.attributes});

  AllVehicleModel.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    return data;
  }
}

class Attributes {
  List<VehicleResult>? results;
  int? page;
  int? limit;
  int? totalPages;
  int? totalResults;

  Attributes({
    this.results,
    this.page,
    this.limit,
    this.totalPages,
    this.totalResults,
  });

  Attributes.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <VehicleResult>[];
      json['results'].forEach((v) {
        results!.add(VehicleResult.fromJson(v));
      });
    }
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
    totalResults = json['totalResults'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    data['totalResults'] = totalResults;
    return data;
  }
}

class VehicleResult {
  String? createdBy;
  String? name;
  String? description;
  String? createdAt;
  String? id;

  VehicleResult({
    this.createdBy,
    this.name,
    this.description,
    this.createdAt,
    this.id,
  });

  VehicleResult.fromJson(Map<String, dynamic> json) {
    createdBy = json['createdBy'];
    name = json['name'];
    description = json['description'];
    createdAt = json['createdAt'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdBy'] = createdBy;
    data['name'] = name;
    data['description'] = description;
    data['createdAt'] = createdAt;
    data['id'] = id;
    return data;
  }
}