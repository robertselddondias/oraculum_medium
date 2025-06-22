class AvailabilitySettingsModel {
  final bool autoAcceptAppointments;
  final int bufferTime;
  final int maxDailyAppointments;
  final List<int> consultationDurations;
  final Map<String, dynamic> availability;
  final bool isAvailable;
  final Map<String, bool> notificationSettings;
  final double minimumSessionPrice;
  final bool acceptsCredits;
  final bool acceptsCards;
  final bool acceptsPix;
  final int minAdvanceBooking;
  final int maxAdvanceBooking;
  final bool allowSameDayBooking;
  final DateTime updatedAt;

  AvailabilitySettingsModel({
    required this.autoAcceptAppointments,
    required this.bufferTime,
    required this.maxDailyAppointments,
    required this.consultationDurations,
    required this.availability,
    required this.isAvailable,
    required this.notificationSettings,
    required this.minimumSessionPrice,
    required this.acceptsCredits,
    required this.acceptsCards,
    required this.acceptsPix,
    required this.minAdvanceBooking,
    required this.maxAdvanceBooking,
    required this.allowSameDayBooking,
    required this.updatedAt,
  });

  factory AvailabilitySettingsModel.fromMap(Map<String, dynamic> map) {
    return AvailabilitySettingsModel(
      autoAcceptAppointments: map['autoAcceptAppointments'] ?? false,
      bufferTime: map['bufferTime'] ?? 15,
      maxDailyAppointments: map['maxDailyAppointments'] ?? 10,
      consultationDurations: List<int>.from(map['consultationDurations'] ?? [15, 30, 45, 60]),
      availability: Map<String, dynamic>.from(map['availability'] ?? _getDefaultAvailability()),
      isAvailable: map['isAvailable'] ?? false,
      notificationSettings: Map<String, bool>.from(map['notificationSettings'] ?? _getDefaultNotifications()),
      minimumSessionPrice: (map['minimumSessionPrice'] ?? 10.0).toDouble(),
      acceptsCredits: map['acceptsCredits'] ?? true,
      acceptsCards: map['acceptsCards'] ?? true,
      acceptsPix: map['acceptsPix'] ?? true,
      minAdvanceBooking: map['minAdvanceBooking'] ?? 2,
      maxAdvanceBooking: map['maxAdvanceBooking'] ?? 30,
      allowSameDayBooking: map['allowSameDayBooking'] ?? true,
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'autoAcceptAppointments': autoAcceptAppointments,
      'bufferTime': bufferTime,
      'maxDailyAppointments': maxDailyAppointments,
      'consultationDurations': consultationDurations,
      'availability': availability,
      'isAvailable': isAvailable,
      'notificationSettings': notificationSettings,
      'minimumSessionPrice': minimumSessionPrice,
      'acceptsCredits': acceptsCredits,
      'acceptsCards': acceptsCards,
      'acceptsPix': acceptsPix,
      'minAdvanceBooking': minAdvanceBooking,
      'maxAdvanceBooking': maxAdvanceBooking,
      'allowSameDayBooking': allowSameDayBooking,
      'updatedAt': updatedAt,
    };
  }

  AvailabilitySettingsModel copyWith({
    bool? autoAcceptAppointments,
    int? bufferTime,
    int? maxDailyAppointments,
    List<int>? consultationDurations,
    Map<String, dynamic>? availability,
    bool? isAvailable,
    Map<String, bool>? notificationSettings,
    double? minimumSessionPrice,
    bool? acceptsCredits,
    bool? acceptsCards,
    bool? acceptsPix,
    int? minAdvanceBooking,
    int? maxAdvanceBooking,
    bool? allowSameDayBooking,
    DateTime? updatedAt,
  }) {
    return AvailabilitySettingsModel(
      autoAcceptAppointments: autoAcceptAppointments ?? this.autoAcceptAppointments,
      bufferTime: bufferTime ?? this.bufferTime,
      maxDailyAppointments: maxDailyAppointments ?? this.maxDailyAppointments,
      consultationDurations: consultationDurations ?? this.consultationDurations,
      availability: availability ?? this.availability,
      isAvailable: isAvailable ?? this.isAvailable,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      minimumSessionPrice: minimumSessionPrice ?? this.minimumSessionPrice,
      acceptsCredits: acceptsCredits ?? this.acceptsCredits,
      acceptsCards: acceptsCards ?? this.acceptsCards,
      acceptsPix: acceptsPix ?? this.acceptsPix,
      minAdvanceBooking: minAdvanceBooking ?? this.minAdvanceBooking,
      maxAdvanceBooking: maxAdvanceBooking ?? this.maxAdvanceBooking,
      allowSameDayBooking: allowSameDayBooking ?? this.allowSameDayBooking,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int getDefaultDuration() {
    return consultationDurations.isNotEmpty ? consultationDurations.first : 30;
  }

  bool getDayAvailability(String day) {
    final dayData = availability[day] as Map<String, dynamic>?;
    return dayData?['isAvailable'] ?? false;
  }

  String getDayStartTime(String day) {
    final dayData = availability[day] as Map<String, dynamic>?;
    return dayData?['startTime'] ?? '09:00';
  }

  String getDayEndTime(String day) {
    final dayData = availability[day] as Map<String, dynamic>?;
    return dayData?['endTime'] ?? '18:00';
  }

  List<DateTime> getBlockedDates() {
    final dates = availability['blockedDates'] as List?;
    return dates?.cast<DateTime>() ?? [];
  }

  bool validate() {
    if (consultationDurations.isEmpty) {
      return false;
    }

    if (bufferTime < 5 || bufferTime > 60) {
      return false;
    }

    if (maxDailyAppointments < 1 || maxDailyAppointments > 20) {
      return false;
    }

    return true;
  }

  static Map<String, dynamic> _getDefaultAvailability() {
    return {
      'monday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '18:00', 'breaks': []},
      'tuesday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '18:00', 'breaks': []},
      'wednesday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '18:00', 'breaks': []},
      'thursday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '18:00', 'breaks': []},
      'friday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '18:00', 'breaks': []},
      'saturday': {'isAvailable': false, 'startTime': '09:00', 'endTime': '17:00', 'breaks': []},
      'sunday': {'isAvailable': false, 'startTime': '10:00', 'endTime': '16:00', 'breaks': []},
      'blockedDates': <DateTime>[],
    };
  }

  static Map<String, bool> _getDefaultNotifications() {
    return {
      'newAppointments': true,
      'appointmentReminders': true,
      'paymentNotifications': true,
      'reviewNotifications': true,
      'promotionalEmails': false,
      'systemUpdates': true,
      'maintenanceAlerts': true,
    };
  }
}
