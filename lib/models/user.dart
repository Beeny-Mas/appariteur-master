  class UserData {
    final String? userId;
    final String? appariteurId;
    final String? name;
    final String? email;
    final String? tel;
    final String? sexe;
    final String? image;
    final String? adresse;
    final String? lieunais;
    final String? rue;
    final String? datenais;
    final String? codepostal;
    final String? ville;
    final String? pays;
    final String? niveau;
    final String? user;
    final String? password;
    final String? token;

    UserData({
      this.userId,
      this.appariteurId,
      this.name,
      this.email,
      this.tel,
      this.sexe,
      this.image,
      this.adresse,
      this.datenais,
      this.lieunais,
      this.rue,
      this.codepostal,
      this.ville,
      this.pays,
      this.niveau,
      this.user,
      this.password,
      this.token,
    });

    factory UserData.fromJson(Map<String, dynamic> json) =>
        UserData(
          userId: json['userId'] as String?,
          appariteurId: json['appariteurId'] as String?,
          name: json['name'] as String?,
          email: json['email'] as String?,
          tel: json['tel'] as String?,
          sexe: json['sexe'] as String?,
          image: json['image'] as String?,
          adresse: json['adresse'] as String?,
          datenais: json['datenais'] as String?,
          lieunais: json['lieunais'] as String?,
          rue: json['rue'] as String?,
          codepostal: json['codepostal'] as String,
          ville: json['ville'] as String?,
          pays: json['pays'] as String?,
          niveau: json['niveau'] as String?,
          user: json['user'] as String?,
          token: json['token'] as String?,
        );

    Map<String, dynamic> toJson() =>
        {
          'userId': userId,
          'appariteurId': appariteurId,
          'name': name,
          'email': email,
          'tel': tel,
          'sexe': sexe,
          'image': image,
          'adresse': adresse,
          'datenais': datenais,
          'lieunais': lieunais,
          'rue': rue,
          'codepostal': codepostal,
          'ville': ville,
          'pays': pays,
          'niveau': niveau,
          'user': user,
          'password': password,
          'token': token,
        };

    Map<String, dynamic> toApiJson() {
      return {
        'nameUser': name,
        'emailUser': email,
        'telUser': {'internationalNumber': tel},
        'sexeUser': sexe,
        'passwordUser': password,
        'datenaisUser': datenais,
        'lieunaisUser': lieunais,
        'rueAp': rue,
        'paysAp': pays,
      };
    }


  }