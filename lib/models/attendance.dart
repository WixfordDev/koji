class Attendance {
  final String id;
  final DateTime? date;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final num? totalHours;
  final String? status;
  final String? notes;
  final Map<String, dynamic>? location;
  final String? employee;

  Attendance({
    required this.id,
    this.date,
    this.clockIn,
    this.clockOut,
    this.totalHours,
    this.status,
    this.notes,
    this.location,
    this.employee,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return Attendance(
      id: json['id']?.toString() ?? '',
      date: parseDate(json['date']),
      clockIn: parseDate(json['clockIn']),
      clockOut: parseDate(json['clockOut']),
      totalHours: json['totalHours'],
      status: json['status']?.toString(),
      notes: json['notes']?.toString(),
      location: json['location'] is Map
          ? Map<String, dynamic>.from(json['location'])
          : null,
      employee: json['employee']?.toString(),
    );
  }
}
