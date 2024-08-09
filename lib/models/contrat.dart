class Contrat {
  final String idContratApp;
  final String appariteurId;
  final String typeContrat;
  final String dateEmbauche;
  final String dateFinContrat;
  final String dateEdition;
  final String disponibilite;
  final String nbrHeure;
  final String montantHeure;
  final String nameFichier;

  Contrat({
    required this.idContratApp,
    required this.appariteurId,
    required this.typeContrat,
    required this.dateEmbauche,
    required this.dateFinContrat,
    required this.dateEdition,
    required this.disponibilite,
    required this.nbrHeure,
    required this.montantHeure,
    required this.nameFichier,
  });

  factory Contrat.fromJson(Map<String, dynamic> json) {
    return Contrat(
      idContratApp: json['Id_contrat_app'],
      appariteurId: json['appariteur_id'],
      typeContrat: json['TypeContrat'],
      dateEmbauche: json['DateEmbauche'],
      dateFinContrat: json['DateFinContrat'],
      dateEdition: json['DateEdition'],
      disponibilite: json['Disponibilite'],
      nbrHeure: json['nbr_heure'],
      montantHeure: json['montant_heure'],
      nameFichier: json['name_fichier'],
    );
  }
}
