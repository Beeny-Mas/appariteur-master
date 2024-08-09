class UserInfo {
  final String? heureWeek;
  final String? heureMonth;
  final String? heureYear;
  final String? effeMis;

  UserInfo({
    this.heureWeek,
    this.heureMonth,
    this.heureYear,
    this.effeMis,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      heureWeek: json['heure_week'],
      heureMonth: json['heure_month'],
      heureYear: json['heure_year'],
      effeMis: json['effe_mis'],
    );
  }
}
