class AllMonthModel {
  final int? code;
  final String? message;
  final AllMonthData? data;

  AllMonthModel({
    this.code,
    this.message,
    this.data,
  });

  factory AllMonthModel.fromJson(Map<String, dynamic> json) => AllMonthModel(
        code: json["code"],
        message: json["message"],
        data: json["data"] == null ? null : AllMonthData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "data": data?.toJson(),
      };
}

class AllMonthData {
  final AllMonthAttributes? attributes;

  AllMonthData({
    this.attributes,
  });

  factory AllMonthData.fromJson(Map<String, dynamic> json) => AllMonthData(
        attributes: json["attributes"] == null
            ? null
            : AllMonthAttributes.fromJson(json["attributes"]),
      );

  Map<String, dynamic> toJson() => {
        "attributes": attributes?.toJson(),
      };
}

class AllMonthAttributes {
  final List<MonthCalendarData>? monthCalendarData;
  final MonthSummary? summery;

  AllMonthAttributes({
    this.monthCalendarData,
    this.summery,
  });

  factory AllMonthAttributes.fromJson(Map<String, dynamic> json) =>
      AllMonthAttributes(
        monthCalendarData: json["monthCalendarData"] == null
            ? []
            : List<MonthCalendarData>.from(
                json["monthCalendarData"].map((x) => MonthCalendarData.fromJson(x))),
        summery: json["summery"] == null
            ? null
            : MonthSummary.fromJson(json["summery"]),
      );

  Map<String, dynamic> toJson() => {
        "monthCalendarData": monthCalendarData == null
            ? []
            : List<dynamic>.from(monthCalendarData!.map((x) => x.toJson())),
        "summery": summery?.toJson(),
      };
}

class MonthCalendarData {
  final String? date;
  final int? pandingtaskCount;
  final int? complitTaskCount;
  final int? totalProgressCount;

  MonthCalendarData({
    this.date,
    this.pandingtaskCount,
    this.complitTaskCount,
    this.totalProgressCount,
  });

  factory MonthCalendarData.fromJson(Map<String, dynamic> json) =>
      MonthCalendarData(
        date: json["date"],
        pandingtaskCount: json["pandingtaskCount"],
        complitTaskCount: json["complitTaskCount"],
        totalProgressCount: json["totalProgressCount"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "pandingtaskCount": pandingtaskCount,
        "complitTaskCount": complitTaskCount,
        "totalProgressCount": totalProgressCount,
      };
}

class MonthSummary {
  final int? fullMonthTotalPendingCount;
  final int? fullMonthTotalProgressCount;
  final int? fullMonthTotalCompliteCount;

  MonthSummary({
    this.fullMonthTotalPendingCount,
    this.fullMonthTotalProgressCount,
    this.fullMonthTotalCompliteCount,
  });

  factory MonthSummary.fromJson(Map<String, dynamic> json) => MonthSummary(
        fullMonthTotalPendingCount: json["fullMonthTotalPendingCount"],
        fullMonthTotalProgressCount: json["fullMonthTotalProgressCount"],
        fullMonthTotalCompliteCount: json["fullMonthTotalCompliteCount"],
      );

  Map<String, dynamic> toJson() => {
        "fullMonthTotalPendingCount": fullMonthTotalPendingCount,
        "fullMonthTotalProgressCount": fullMonthTotalProgressCount,
        "fullMonthTotalCompliteCount": fullMonthTotalCompliteCount,
      };
}