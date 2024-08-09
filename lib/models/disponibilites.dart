class Disponibilite {
  final String date;
  final String heureDebutMatin;
  final String heureFinMatin;
  final String heureDebutSoir;
  final String heureFinSoir;

  Disponibilite({
    required this.date,
    required this.heureDebutMatin,
    required this.heureFinMatin,
    required this.heureDebutSoir,
    required this.heureFinSoir,
  });

  factory Disponibilite.fromJson(Map<String, dynamic> json) {
    return Disponibilite(
      date: json['date'],
      heureDebutMatin: json['heure_debutMatin'],
      heureFinMatin: json['heure_finMatin'],
      heureDebutSoir: json['heure_debutSoir'],
      heureFinSoir: json['Heure_finSoir'],
    );
  }
}
