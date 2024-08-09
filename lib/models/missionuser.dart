class MissionEffUser {
  DateTime today;
  Result result;

  MissionEffUser({required this.today, required this.result});

  factory MissionEffUser.fromJson(Map<String, dynamic> json) {
    return MissionEffUser(
      today: DateTime.parse(json['today']['date']),
      result: Result.fromJson(json['result']),
    );
  }
}

class Result {
  bool success;
  List<Mission> data;
  String? totalHeure;

  Result({required this.success, required this.data, this.totalHeure});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      success: json['success'],
      data: List<Mission>.from(json['data'].map((x) => Mission.fromJson(x))),
      totalHeure: json['total_heure'] ?? '00:00',
    );
  }
}

class MissionEffUserResult {
  List<Mission>? missions;
  String? totalHours;

  MissionEffUserResult({this.missions, this.totalHours});
}
class Mission {
  DateTime date;
  String etabli;
  String duree;
  String moment;

  Mission({required this.date, required this.etabli, required this.duree,required this.moment});

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      date: DateTime.parse(json['date']),
      etabli: json['etabli'],
      duree: json['duree'],
      moment: json['moment']
    );
  }
}
