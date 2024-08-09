import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  final String tableName = 'user';
  final String columnId = 'id';
  final String columnName = 'name';
  final String columnEmail = 'email';
  final String columnUserId = 'user_id';
  final String columnAppariteurId = 'appariteur_id';
  final String columnTel = 'tel';
  final String columnSexe = 'sexe';
  final String columnImage = 'image';
  final String columnAdresse = 'adresse';
  final String columnDatenais = 'datenais';
  final String columnLieunais = 'lieunais';
  final String columnRue = 'rue';
  final String columnCodepostal = 'codepostal';
  final String columnVille = 'ville';
  final String columnPays = 'pays';
  final String columnNiveau = 'niveau';
  final String columnUser = 'user';
  final String columnToken = 'token';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'your_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $tableName (
            $columnId INTEGER PRIMARY KEY,
            $columnUserId TEXT,
            $columnAppariteurId TEXT,
            $columnName TEXT,
            $columnEmail TEXT,
            $columnTel TEXT,
            $columnSexe TEXT,
            $columnImage TEXT,
            $columnAdresse TEXT,
            $columnDatenais TEXT,
            $columnLieunais TEXT,
            $columnRue TEXT,
            $columnCodepostal TEXT,
            $columnVille TEXT,
            $columnPays TEXT,
            $columnNiveau TEXT,
            $columnUser TEXT,
            $columnToken TEXT 
          )
        ''');
      },
    );
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    Database? db = await instance.database;
    return await db!.query(tableName);
  }

  getUserById(String userId) {
    // Ajoutez la logique pour récupérer un utilisateur par son ID ici
  }
}
