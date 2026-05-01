import 'dart:convert';
import 'package:koji/global/utils/date_utils.dart';

NotificationsModel notificationsModelFromJson(String str) => NotificationsModel.fromJson(json.decode(str));

String notificationsModelToJson(NotificationsModel data) => json.encode(data.toJson());

class NotificationsModel {
  final List<Notification>? notifications;
  final int? totalUnread;
  final int? totalRead;

  NotificationsModel({
    this.notifications,
    this.totalUnread,
    this.totalRead,
  });

  factory NotificationsModel.fromJson(Map<String, dynamic> json) => NotificationsModel(
    notifications: json["notifications"] == null ? [] : List<Notification>.from(json["notifications"]!.map((x) => Notification.fromJson(x))),
    totalUnread: json["totalUnread"],
    totalRead: json["totalRead"],
  );

  Map<String, dynamic> toJson() => {
    "notifications": notifications == null ? [] : List<dynamic>.from(notifications!.map((x) => x.toJson())),
    "totalUnread": totalUnread,
    "totalRead": totalRead,
  };
}

class NotificationTask {
  final String? id;
  final String? customerName;
  final String? customerNumber;
  final String? customerEmail;
  final String? customerAddress;
  final String? postCode;
  final DateTime? assignDate;
  final DateTime? deadline;
  final double? totalAmount;
  final String? status;
  final List<String>? assignTo;

  NotificationTask({
    this.id,
    this.customerName,
    this.customerNumber,
    this.customerEmail,
    this.customerAddress,
    this.postCode,
    this.assignDate,
    this.deadline,
    this.totalAmount,
    this.status,
    this.assignTo,
  });

  factory NotificationTask.fromJson(Map<String, dynamic> json) => NotificationTask(
    id: json["id"] ?? json["_id"],
    customerName: json["customerName"]?.toString(),
    customerNumber: json["customerNumber"]?.toString(),
    customerEmail: json["customerEmail"]?.toString(),
    customerAddress: json["customerAddress"]?.toString(),
    postCode: json["postCode"]?.toString(),
    assignDate: json["assignDate"] == null ? null : toSgt(DateTime.parse(json["assignDate"])),
    deadline: json["deadline"] == null ? null : toSgt(DateTime.parse(json["deadline"])),
    totalAmount: json["totalAmount"] == null ? null : (json["totalAmount"] as num).toDouble(),
    status: json["status"]?.toString(),
    assignTo: json["assignTo"] == null
        ? null
        : List<String>.from(
            (json["assignTo"] as List).map((e) => (e is Map ? e["fullName"] : e)?.toString() ?? '').where((n) => n.isNotEmpty),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "customerName": customerName,
    "customerNumber": customerNumber,
    "customerEmail": customerEmail,
    "customerAddress": customerAddress,
    "postCode": postCode,
    "assignDate": assignDate?.toIso8601String(),
    "deadline": deadline?.toIso8601String(),
    "totalAmount": totalAmount,
    "status": status,
    "assignTo": assignTo,
  };
}

class Notification {
  final String? id;
  final String? userId;
  final String? sendBy;
  final dynamic transactionId;
  final String? role;
  final String? title;
  final String? content;
  final String? icon;
  final String? devStatus;
  final NotificationTask? task;
  final String? taskIdRaw;
  final String? image;
  final String? status;
  final String? type;
  final String? priority;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Notification({
    this.id,
    this.userId,
    this.sendBy,
    this.transactionId,
    this.role,
    this.title,
    this.content,
    this.icon,
    this.devStatus,
    this.task,
    this.taskIdRaw,
    this.image,
    this.status,
    this.type,
    this.priority,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  // Convenience getters — pull from nested task if available
  String? get customerNumber => task?.customerNumber;
  DateTime? get assignDate => task?.assignDate;
  DateTime? get deadline => task?.deadline;
  String? get taskId => task?.id ?? taskIdRaw;
  List<String>? get assignTo => task?.assignTo;

  factory Notification.fromJson(Map<String, dynamic> json) {
    final taskIdRaw = json["taskId"];
    NotificationTask? task;
    String? rawId;

    if (taskIdRaw is Map<String, dynamic>) {
      task = NotificationTask.fromJson(taskIdRaw);
    } else if (taskIdRaw != null) {
      rawId = taskIdRaw.toString();
    }

    return Notification(
      id: json["_id"],
      userId: json["userId"],
      sendBy: json["sendBy"],
      transactionId: json["transactionId"],
      role: json["role"],
      title: json["title"],
      content: json["content"],
      icon: json["icon"],
      devStatus: json["devStatus"],
      task: task,
      taskIdRaw: rawId,
      image: json["image"],
      status: json["status"],
      type: json["type"],
      priority: json["priority"],
      createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
      updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "sendBy": sendBy,
    "transactionId": transactionId,
    "role": role,
    "title": title,
    "content": content,
    "icon": icon,
    "devStatus": devStatus,
    "taskId": task?.toJson() ?? taskIdRaw,
    "image": image,
    "status": status,
    "type": type,
    "priority": priority,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}
