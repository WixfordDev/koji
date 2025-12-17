class Conversation {
  final String? id;
  final User? sender;
  final User? receiver;
  final int? unseenMsg;
  final String? blockStatus;
  final String? blockedBy;
  final Message? lastMsg;

  Conversation({
    this.id,
    this.sender,
    this.receiver,
    this.unseenMsg,
    this.blockStatus,
    this.blockedBy,
    this.lastMsg,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id']?.toString(),
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? User.fromJson(json['receiver']) : null,
      unseenMsg: json['unseenMsg'],
      blockStatus: json['blockStatus']?.toString(),
      blockedBy: json['blockedBy']?.toString(),
      lastMsg: json['lastMsg'] != null ? Message.fromJson(json['lastMsg']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'sender': sender?.toJson(),
    'receiver': receiver?.toJson(),
    'unseenMsg': unseenMsg,
    'blockStatus': blockStatus,
    'blockedBy': blockedBy,
    'lastMsg': lastMsg?.toJson(),
  };
}

class User {
  final Location? location;
  final String? officeStartTime;
  final String? officeEndTime;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;
  final String? image;
  final String? role;
  final String? callingCode;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? address;
  final bool? isProfileCompleted;
  final bool? isAdminApproved;
  final bool? isAcceptPolicyTerms;
  final String? createdAt;
  final String? id;

  User({
    this.location,
    this.officeStartTime,
    this.officeEndTime,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.image,
    this.role,
    this.callingCode,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
    this.isProfileCompleted,
    this.isAdminApproved,
    this.isAcceptPolicyTerms,
    this.createdAt,
    this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      officeStartTime: json['officeStartTime'],
      officeEndTime: json['officeEndTime'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      fullName: json['fullName'],
      email: json['email'],
      image: json['image'],
      role: json['role'],
      callingCode: json['callingCode'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'],
      address: json['address'],
      isProfileCompleted: json['isProfileCompleted'],
      isAdminApproved: json['isAdminApproved'],
      isAcceptPolicyTerms: json['isAcceptPolicyTerms'],
      createdAt: json['createdAt'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'location': location?.toJson(),
    'officeStartTime': officeStartTime,
    'officeEndTime': officeEndTime,
    'firstName': firstName,
    'lastName': lastName,
    'fullName': fullName,
    'email': email,
    'image': image,
    'role': role,
    'callingCode': callingCode,
    'phoneNumber': phoneNumber,
    'dateOfBirth': dateOfBirth,
    'address': address,
    'isProfileCompleted': isProfileCompleted,
    'isAdminApproved': isAdminApproved,
    'isAcceptPolicyTerms': isAcceptPolicyTerms,
    'createdAt': createdAt,
    'id': id,
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

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'],
      coordinates: _parseCoordinates(json['coordinates']),
      locationName: json['locationName'],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'coordinates': coordinates,
    'locationName': locationName,
  };
}

// Helper function to parse coordinates which might contain int or double values
List<double>? _parseCoordinates(dynamic coordinatesData) {
  if (coordinatesData == null) {
    return null;
  } else if (coordinatesData is List) {
    List<double> result = [];
    for (var item in coordinatesData) {
      if (item is int) {
        result.add(item.toDouble());
      } else if (item is double) {
        result.add(item);
      } else {
        result.add(0.0); // fallback for unexpected types
      }
    }
    return result;
  } else {
    return null;
  }
}

class Message {
  final String? conversationId;
  final String? text;
  final String? imageUrl;
  final String? videoUrl;
  final String? fileUrl;
  final String? linkUrl;
  final String? type;
  final bool? seen;
  final String? msgByUserId;
  final String? createdAt;
  final String? id;

  Message({
    this.conversationId,
    this.text,
    this.imageUrl,
    this.videoUrl,
    this.fileUrl,
    this.linkUrl,
    this.type,
    this.seen,
    this.msgByUserId,
    this.createdAt,
    this.id,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      conversationId: json['conversationId']?.toString(),
      text: json['text']?.toString(),
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      fileUrl: json['fileUrl'],
      linkUrl: json['linkUrl'],
      type: json['type']?.toString(),
      seen: json['seen'],
      msgByUserId: json['msgByUserId']?.toString(),
      createdAt: json['createdAt']?.toString(),
      id: json['id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'conversationId': conversationId,
    'text': text,
    'imageUrl': imageUrl,
    'videoUrl': videoUrl,
    'fileUrl': fileUrl,
    'linkUrl': linkUrl,
    'type': type,
    'seen': seen,
    'msgByUserId': msgByUserId,
    'createdAt': createdAt,
    'id': id,
  };
}