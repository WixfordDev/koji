import 'dart:convert';

AllTaskSummaryModel allTaskSummaryModelFromJson(String str) => AllTaskSummaryModel.fromJson(json.decode(str));

String allTaskSummaryModelToJson(AllTaskSummaryModel data) => json.encode(data.toJson());

class AllTaskSummaryModel {
  final int? totalTask;
  final int? completeTask;
  final int? pendingTask;
  final int? inProgressTask;
  final int? todayTask;

  AllTaskSummaryModel({
    this.totalTask,
    this.completeTask,
    this.pendingTask,
    this.inProgressTask,
    this.todayTask,
  });

  factory AllTaskSummaryModel.fromJson(Map<String, dynamic> json) => AllTaskSummaryModel(
    totalTask: json["totalTask"],
    completeTask: json["completeTask"],
    pendingTask: json["pendingTask"],
    inProgressTask: json["inProgressTask"],
    todayTask: json["todayTask"],
  );

  Map<String, dynamic> toJson() => {
    "totalTask": totalTask,
    "completeTask": completeTask,
    "pendingTask": pendingTask,
    "inProgressTask": inProgressTask,
    "todayTask": todayTask,
  };
}
