import 'dart:convert';

AllAttendanceSummaryModel allAttendanceSummaryModelFromJson(String str) => AllAttendanceSummaryModel.fromJson(json.decode(str));

String allAttendanceSummaryModelToJson(AllAttendanceSummaryModel data) => json.encode(data.toJson());

class AllAttendanceSummaryModel {
  final DateTime? date;
  final int? totalEmployees;
  final int? presentEmployees;
  final int? employeesArrivedOnTime;
  final int? lateComersToday;
  final int? absentEmployeesToday;
  final int? workingEmployeesToday;
  final String? presentPercentage;
  final String? absentPercentage;

  AllAttendanceSummaryModel({
    this.date,
    this.totalEmployees,
    this.presentEmployees,
    this.employeesArrivedOnTime,
    this.lateComersToday,
    this.absentEmployeesToday,
    this.workingEmployeesToday,
    this.presentPercentage,
    this.absentPercentage,
  });

  factory AllAttendanceSummaryModel.fromJson(Map<String, dynamic> json) => AllAttendanceSummaryModel(
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    totalEmployees: json["totalEmployees"],
    presentEmployees: json["PresentEmployees"],
    employeesArrivedOnTime: json["EmployeesArrivedOnTime"],
    lateComersToday: json["LateComersToday"],
    absentEmployeesToday: json["AbsentEmployeesToday"],
    workingEmployeesToday: json["WorkingEmployeesToday"],
    presentPercentage: json["presentPercentage"],
    absentPercentage: json["absentPercentage"],
  );

  Map<String, dynamic> toJson() => {
    "date": date?.toIso8601String(),
    "totalEmployees": totalEmployees,
    "PresentEmployees": presentEmployees,
    "EmployeesArrivedOnTime": employeesArrivedOnTime,
    "LateComersToday": lateComersToday,
    "AbsentEmployeesToday": absentEmployeesToday,
    "WorkingEmployeesToday": workingEmployeesToday,
    "presentPercentage": presentPercentage,
    "absentPercentage": absentPercentage,
  };
}
