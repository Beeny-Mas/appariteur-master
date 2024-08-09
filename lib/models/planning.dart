class Planning {
  final String ligneCmdId;
  final String lieu;
  final String salle;
  final String heureDebut;
  final String heureFin;
  final String duree;
  final String nbreAppariteur;
  final String description;
  final String cmdId;
  final String statut;
  final String deletedAt;
  final String createdAt;
  final String updatedAt;
  final String datePres;
  final String matinSoir;
  final String nameEtabli;
  final String prestationId;
  final String eventColor;
  final bool btnCancel;

  Planning({
    required this.ligneCmdId,
    required this.lieu,
    required this.salle,
    required this.heureDebut,
    required this.heureFin,
    required this.duree,
    required this.nbreAppariteur,
    required this.description,
    required this.cmdId,
    required this.statut,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.datePres,
    required this.matinSoir,
    required this.nameEtabli,
    required this.prestationId,
    required this.eventColor,
    required this.btnCancel,
  });

  factory Planning.fromJson(Map<String, dynamic> json) {
    return Planning(
      ligneCmdId: json['ligne_cmd_id'] ?? '',
      lieu: json['lieu'] ?? '',
      salle: json['salle'] ?? '',
      heureDebut: json['heure_debut'] ?? '',
      heureFin: json['heure_fin'] ?? '',
      duree: json['duree'] ?? '',
      nbreAppariteur: json['nbre_appariteur'] ?? '',
      description: json['description'] ?? '',
      cmdId: json['cmd_id'] ?? '',
      statut: json['Statut'] ?? '',
      deletedAt: json['deleted_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      datePres: json['date_pres'] ?? '',
      matinSoir: json['matin_soir'] ?? '',
      nameEtabli: json['name_etabli'] ?? '',
      prestationId: json['prestation_id'] ?? '',
      eventColor: json['eventColor'] ?? '',
      btnCancel: json['btnCancel'] ?? false,
    );
  }
}
