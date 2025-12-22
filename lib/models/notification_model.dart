import 'dart:convert';

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
  final String? taskId;
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
    this.taskId,
    this.image,
    this.status,
    this.type,
    this.priority,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    id: json["_id"],
    userId: json["userId"],
    sendBy: json["sendBy"],
    transactionId: json["transactionId"],
    role: json["role"],
    title: json["title"],
    content: json["content"],
    icon: json["icon"],
    devStatus: json["devStatus"],
    taskId: json["taskId"],
    image: json["image"],
    status: json["status"],
    type: json["type"],
    priority: json["priority"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

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
    "taskId": taskId,
    "image": image,
    "status": status,
    "type": type,
    "priority": priority,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}
