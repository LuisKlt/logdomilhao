import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('logdomilhao.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabela de usuários
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        totalPoints INTEGER NOT NULL DEFAULT 0,
        currentLevel INTEGER NOT NULL DEFAULT 1,
        language TEXT NOT NULL DEFAULT 'pt'
      )
    ''');

    // Tabela de níveis
    await db.execute('''
      CREATE TABLE levels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        order_num INTEGER NOT NULL,
        isLocked INTEGER NOT NULL DEFAULT 1,
        requiredPoints INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de exercícios
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        levelId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        content TEXT NOT NULL,
        correctAnswer TEXT NOT NULL,
        options TEXT NOT NULL,
        points INTEGER NOT NULL DEFAULT 10,
        FOREIGN KEY (levelId) REFERENCES levels (id) ON DELETE CASCADE
      )
    ''');

    // Tabela de pontuações
    await db.execute('''
      CREATE TABLE scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        exerciseId INTEGER NOT NULL,
        points INTEGER NOT NULL,
        isCorrect INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    // Inserir dados iniciais
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // Inserir níveis iniciais
    await db.insert('levels', {
      'title': 'Variáveis e Tipos',
      'description': 'Aprenda sobre variáveis e tipos de dados em programação',
      'category': 'variables',
      'order_num': 1,
      'isLocked': 0,
      'requiredPoints': 0
    });

    await db.insert('levels', {
      'title': 'Entrada e Saída',
      'description': 'Aprenda como receber e exibir dados em programação',
      'category': 'input_output',
      'order_num': 2,
      'isLocked': 1,
      'requiredPoints': 50
    });

    await db.insert('levels', {
      'title': 'Condicionais',
      'description': 'Aprenda sobre estruturas condicionais em programação',
      'category': 'conditionals',
      'order_num': 3,
      'isLocked': 1,
      'requiredPoints': 100
    });

    await db.insert('levels', {
      'title': 'Laços de Repetição',
      'description': 'Aprenda sobre estruturas de repetição em programação',
      'category': 'loops',
      'order_num': 4,
      'isLocked': 1,
      'requiredPoints': 150
    });

    await db.insert('levels', {
      'title': 'Funções',
      'description': 'Aprenda sobre funções e modularização em programação',
      'category': 'functions',
      'order_num': 5,
      'isLocked': 1,
      'requiredPoints': 200
    });

    // Inserir exercícios iniciais para o nível 1
    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Declaração de Variáveis',
      'description': 'Escolha a forma correta de declarar uma variável inteira em Python',
      'type': 'multiple_choice',
      'content': 'Como declarar uma variável inteira chamada "idade" com valor 25?',
      'correctAnswer': 'idade = 25',
      'options': 'int idade = 25|idade = 25|var idade = 25|idade: int = 25',
      'points': 10
    });

    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Tipos de Dados',
      'description': 'Identifique o tipo de dado correto',
      'type': 'multiple_choice',
      'content': 'Qual é o tipo de dado da variável x na expressão: x = 3.14?',
      'correctAnswer': 'float',
      'options': 'int|float|string|boolean',
      'points': 10
    });
  }

  // Métodos para operações CRUD
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(String table, String whereClause, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.query(table, where: whereClause, whereArgs: whereArgs);
  }

  Future<int> update(String table, Map<String, dynamic> data, String whereClause, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.update(table, data, where: whereClause, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String whereClause, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.delete(table, where: whereClause, whereArgs: whereArgs);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}