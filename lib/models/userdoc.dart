class UserDoc {
  final String docId;
  final String typeDoc;
  final String docName;

  UserDoc({
    required this.docId,
    required this.typeDoc,
    required this.docName,
  });

  factory UserDoc.fromJson(Map<String, dynamic> json) {
    return UserDoc(
      docId: json['doc_id'],
      typeDoc: json['type_doc'],
      docName: json['doc_name'],
    );
  }
}
