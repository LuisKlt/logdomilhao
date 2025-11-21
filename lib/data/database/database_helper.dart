import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logdomilhao/data/models/score_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

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
    // 1. Inserir Usuário Padrão
    await db.insert('users', {
      'username': 'Estudante',
      'totalPoints': 0,
      'currentLevel': 1,
      'language': 'pt'
    });

    // 2. Inserir Níveis (Level 1 desbloqueado, outros bloqueados)
    // Nível 1
    await db.insert('levels', {
      'title': 'Variáveis e Tipos',
      'description': 'Aprenda sobre variáveis e tipos de dados.',
      'category': 'variables',
      'order_num': 1,
      'isLocked': 0, // ABERTO
      'requiredPoints': 0
    });

    // Nível 2
    await db.insert('levels', {
      'title': 'Entrada e Saída',
      'description': 'Como receber dados do usuário e exibir na tela.',
      'category': 'input_output',
      'order_num': 2,
      'isLocked': 1, // TRAVADO
      'requiredPoints': 0 // A lógica de desbloqueio agora é por conclusão do anterior
    });

    // Nível 3
    await db.insert('levels', {
      'title': 'Condicionais',
      'description': 'Tomada de decisões com If/Else.',
      'category': 'conditionals',
      'order_num': 3,
      'isLocked': 1, // TRAVADO
      'requiredPoints': 0
    });

    // Nível 4
    await db.insert('levels', {
      'title': 'Laços de Repetição',
      'description': 'Repetindo tarefas com For e While.',
      'category': 'loops',
      'order_num': 4,
      'isLocked': 1, // TRAVADO
      'requiredPoints': 0
    });

    // Nível 5
    await db.insert('levels', {
      'title': 'Funções',
      'description': 'Organizando e reutilizando código.',
      'category': 'functions',
      'order_num': 5,
      'isLocked': 1, // TRAVADO
      'requiredPoints': 0
    });

    // ---------------------------------------------------------
    // 3. Inserir Exercícios
    // ---------------------------------------------------------

    // === EXERCÍCIOS DO NÍVEL 1 (Variáveis) ===
    
    // Ex 1: Declaração (Multiple Choice)
    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Declarando Inteiros',
      'description': 'Qual a sintaxe correta para um número inteiro?',
      'type': 'multiple_choice',
      'content': 'Como declarar uma variável inteira chamada "idade" com valor 25 em Dart/Java/C?',
      'correctAnswer': 'int idade = 25;',
      'options': 'int idade = 25;|var idade = 25|idade = 25|String idade = "25";',
      'points': 10
    });

    // Ex 2: Tipos de Dados (Multiple Choice)
    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Identificando Tipos',
      'description': 'Identifique o tipo de dado decimal.',
      'type': 'multiple_choice',
      'content': 'Qual é o tipo de dado mais adequado para armazenar o valor 3.14?',
      'correctAnswer': 'double',
      'options': 'int|double|String|boolean',
      'points': 10
    });

    // Ex 3: String (Fill Blank)
    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Variável de Texto',
      'description': 'Complete o código para criar um texto.',
      'type': 'fill_blank',
      'content': 'Complete para criar uma variável nome com valor "Ana":\n___ nome = "Ana";',
      'correctAnswer': 'String',
      'options': '', // Não usado em fill_blank
      'points': 10
    });
    
    // Ex 4: Ordenação (Code Ordering)
    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Estrutura Básica',
      'description': 'Monte a estrutura de uma declaração.',
      'type': 'code_ordering',
      'content': 'Ordene para declarar um booleano verdadeiro:',
      'correctAnswer': 'bool isAtivo = true;',
      'options': 'bool|isAtivo|=|true;',
      'points': 10
    });

    // === EXERCÍCIOS DO NÍVEL 2 (Entrada e Saída) ===

    // Ex 1: Print (Multiple Choice)
    await db.insert('exercises', {
      'levelId': 2,
      'title': 'Exibindo Mensagens',
      'description': 'Qual comando exibe texto no console em Dart?',
      'type': 'multiple_choice',
      'content': 'Qual função é usada para imprimir no console?',
      'correctAnswer': 'print()',
      'options': 'echo()|console.log()|print()|System.out.println()',
      'points': 15
    });

    // Ex 2: Concatenação (Fill Blank)
    await db.insert('exercises', {
      'levelId': 2,
      'title': 'Juntando Textos',
      'description': 'Complete a concatenação.',
      'type': 'fill_blank',
      'content': 'Complete o print: print("Olá " _ nome);',
      'correctAnswer': '+',
      'options': '',
      'points': 15
    });

    // === EXERCÍCIOS DO NÍVEL 3 (Condicionais) ===
    
    await db.insert('exercises', {
      'levelId': 3,
      'title': 'Lógica do IF',
      'description': 'Como funciona o SE.',
      'type': 'multiple_choice',
      'content': 'O código dentro do "if" só é executado quando a condição for:',
      'correctAnswer': 'Verdadeira',
      'options': 'Falsa|Verdadeira|Nula|Indefinida',
      'points': 20
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

  // Métodos específicos para pontuações
  Future<int> insertScore(Score score) async {
    final db = await database;
    return await db.insert('scores', score.toMap());
  }

  Future<List<Score>> getScores() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('scores', orderBy: 'completedAt DESC');
    
    // Se não houver pontuações, retornar lista vazia
    if (maps.isEmpty) {
      return [];
    }
    
    return List.generate(maps.length, (i) {
      return Score.fromMap(maps[i]);
    });
  }

  Future<void> closeConnection() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null; // Isso é crucial! Força o _initDB a rodar de novo na próxima vez
    }
  }
}