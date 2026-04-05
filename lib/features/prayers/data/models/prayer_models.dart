class PrayerDefinitionModel {
  final String id;
  final String name;
  final String? description;
  final String scheduledTime;
  final int order;
  final bool isActive;

  PrayerDefinitionModel({
    required this.id,
    required this.name,
    this.description,
    required this.scheduledTime,
    required this.order,
    this.isActive = true,
  });

  factory PrayerDefinitionModel.fromJson(Map<String, dynamic> json) {
    return PrayerDefinitionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      scheduledTime: json['scheduled_time'] ?? '00:00',
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }
}

class PrayerLogModel {
  final String id;
  final String memberId;
  final String memberName;
  final String prayerId;
  final String prayerName;
  final String date;
  final String status;
  final String? alertShownAt;
  final String? finalResponseAt;

  PrayerLogModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.prayerId,
    required this.prayerName,
    required this.date,
    required this.status,
    this.alertShownAt,
    this.finalResponseAt,
  });

  factory PrayerLogModel.fromJson(Map<String, dynamic> json) {
    return PrayerLogModel(
      id: json['id'] ?? '',
      memberId: json['member'] ?? '',
      memberName: json['member_name'] ?? '',
      prayerId: json['prayer'] ?? '',
      prayerName: json['prayer_name'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? 'pending',
      alertShownAt: json['alert_shown_at'],
      finalResponseAt: json['final_response_at'],
    );
  }
}
