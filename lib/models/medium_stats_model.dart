class MediumStatsModel {
  final int totalAppointments;
  final int completedAppointments;
  final int monthlyAppointments;
  final int weeklyAppointments;
  final double totalEarnings;
  final double monthlyEarnings;
  final double weeklyEarnings;
  final double averageRating;
  final double responseTime;

  MediumStatsModel({
    required this.totalAppointments,
    required this.completedAppointments,
    required this.monthlyAppointments,
    required this.weeklyAppointments,
    required this.totalEarnings,
    required this.monthlyEarnings,
    required this.weeklyEarnings,
    required this.averageRating,
    required this.responseTime,
  });

  factory MediumStatsModel.fromMap(Map<String, dynamic> map) {
    return MediumStatsModel(
      totalAppointments: map['totalAppointments']?.toInt() ?? 0,
      completedAppointments: map['completedAppointments']?.toInt() ?? 0,
      monthlyAppointments: map['monthlyAppointments']?.toInt() ?? 0,
      weeklyAppointments: map['weeklyAppointments']?.toInt() ?? 0,
      totalEarnings: map['totalEarnings']?.toDouble() ?? 0.0,
      monthlyEarnings: map['monthlyEarnings']?.toDouble() ?? 0.0,
      weeklyEarnings: map['weeklyEarnings']?.toDouble() ?? 0.0,
      averageRating: map['averageRating']?.toDouble() ?? 0.0,
      responseTime: map['responseTime']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalAppointments': totalAppointments,
      'completedAppointments': completedAppointments,
      'monthlyAppointments': monthlyAppointments,
      'weeklyAppointments': weeklyAppointments,
      'totalEarnings': totalEarnings,
      'monthlyEarnings': monthlyEarnings,
      'weeklyEarnings': weeklyEarnings,
      'averageRating': averageRating,
      'responseTime': responseTime,
    };
  }

  double get completionRate {
    if (totalAppointments == 0) return 0.0;
    return (completedAppointments / totalAppointments) * 100;
  }

  String get formattedTotalEarnings {
    return 'R\$ ${totalEarnings.toStringAsFixed(2)}';
  }

  String get formattedMonthlyEarnings {
    return 'R\$ ${monthlyEarnings.toStringAsFixed(2)}';
  }

  String get formattedWeeklyEarnings {
    return 'R\$ ${weeklyEarnings.toStringAsFixed(2)}';
  }

  String get formattedAverageRating {
    return averageRating.toStringAsFixed(1);
  }

  String get formattedResponseTime {
    return '${responseTime.toStringAsFixed(1)} min';
  }

  MediumStatsModel copyWith({
    int? totalAppointments,
    int? completedAppointments,
    int? monthlyAppointments,
    int? weeklyAppointments,
    double? totalEarnings,
    double? monthlyEarnings,
    double? weeklyEarnings,
    double? averageRating,
    double? responseTime,
  }) {
    return MediumStatsModel(
      totalAppointments: totalAppointments ?? this.totalAppointments,
      completedAppointments: completedAppointments ?? this.completedAppointments,
      monthlyAppointments: monthlyAppointments ?? this.monthlyAppointments,
      weeklyAppointments: weeklyAppointments ?? this.weeklyAppointments,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      weeklyEarnings: weeklyEarnings ?? this.weeklyEarnings,
      averageRating: averageRating ?? this.averageRating,
      responseTime: responseTime ?? this.responseTime,
    );
  }
}
