import 'package:flutter/material.dart';
import 'package:logdomilhao/data/database_helper.dart';

class Achievement {
  final int id;
  final String title;
  final String description;
  final String icon;
  final int requiredPoints;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredPoints,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'requiredPoints': requiredPoints,
      'isUnlocked': isUnlocked ? 1 : 0,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      icon: map['icon'],
      requiredPoints: map['requiredPoints'],
      isUnlocked: map['isUnlocked'] == 1,
    );
  }
}

class AchievementProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Achievement> _achievements = [];

  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements => _achievements.where((a) => a.isUnlocked).toList();

  AchievementProvider() {
    _initAchievements();
    _loadAchievements();
  }

  Future<void> _initAchievements() async {
    final db = await _dbHelper.database;
    
    // Verificar se a tabela de conquistas existe
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='achievements'"
    );
    
    if (tables.isEmpty) {
      // Criar tabela de conquistas
      await db.execute('''
        CREATE TABLE achievements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          icon TEXT NOT NULL,
          requiredPoints INTEGER NOT NULL,
          isUnlocked INTEGER NOT NULL DEFAULT 0
        )
      ''');
      
      // Inserir conquistas iniciais
      await db.insert('achievements', {
        'title': 'Primeiro Passo',
        'description': 'Complete seu primeiro exercício',
        'icon': 'emoji_events',
        'requiredPoints': 10,
        'isUnlocked': 0
      });
      
      await db.insert('achievements', {
        'title': 'Aprendiz',
        'description': 'Complete 5 exercícios',
        'icon': 'school',
        'requiredPoints': 50,
        'isUnlocked': 0
      });
      
      await db.insert('achievements', {
        'title': 'Programador Iniciante',
        'description': 'Complete o primeiro nível',
        'icon': 'code',
        'requiredPoints': 100,
        'isUnlocked': 0
      });
      
      await db.insert('achievements', {
        'title': 'Mestre da Lógica',
        'description': 'Complete todos os níveis',
        'icon': 'psychology',
        'requiredPoints': 500,
        'isUnlocked': 0
      });
    }
  }

  Future<void> _loadAchievements() async {
    final db = await _dbHelper.database;
    final achievementsData = await db.query('achievements');
    _achievements = achievementsData.map((a) => Achievement.fromMap(a)).toList();
    notifyListeners();
  }

  Future<void> checkAndUnlockAchievements(int userPoints) async {
    final db = await _dbHelper.database;
    bool hasChanges = false;
    
    for (var achievement in _achievements) {
      if (!achievement.isUnlocked && userPoints >= achievement.requiredPoints) {
        await db.update(
          'achievements',
          {'isUnlocked': 1},
          where: 'id = ?',
          whereArgs: [achievement.id],
        );
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      await _loadAchievements();
    }
  }

  Future<Achievement?> getLatestUnlockedAchievement() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'achievements',
      where: 'isUnlocked = 1',
      orderBy: 'id DESC',
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return Achievement.fromMap(result.first);
    }
    return null;
  }
}