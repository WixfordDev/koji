

import 'dart:convert';

AllServiceListModel allServiceListModelFromJson(String str) => AllServiceListModel.fromJson(json.decode(str));

String allServiceListModelToJson(AllServiceListModel data) => json.encode(data.toJson());

class AllServiceListModel {
  final List<ServiceItem>? results;
  final int? totalResults;

  AllServiceListModel({
    this.results,
    this.totalResults,
  });

  factory AllServiceListModel.fromJson(Map<String, dynamic> json) => AllServiceListModel(
    results: json["results"] == null
        ? []
        : List<ServiceItem>.from(json["results"].map((x) => ServiceItem.fromJson(x))),
    totalResults: json["totalResults"],
  );

  Map<String, dynamic> toJson() => {
    "results": results == null ? [] : List<dynamic>.from(results!.map((x) => x.toJson())),
    "totalResults": totalResults,
  };
}

class ServiceItem {
  final dynamic createdBy;
  final String? name;
  final int? quantity;
  final String? price;
  final DateTime? createdAt;
  final String? id;

  ServiceItem({
    this.createdBy,
    this.name,
    this.quantity,
    this.price,
    this.createdAt,
    this.id,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) => ServiceItem(
    createdBy: json["createdBy"],
    name: json["name"],
    quantity: json["quantity"],
    price: json["price"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "createdBy": createdBy,
    "name": name,
    "quantity": quantity,
    "price": price,
    "createdAt": createdAt?.toIso8601String(),
    "id": id,
  };
}
