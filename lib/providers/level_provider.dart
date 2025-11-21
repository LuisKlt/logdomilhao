import 'package:flutter/material.dart';
import 'package:logdomilhao/data/database/database_helper.dart';
import 'package:logdomilhao/data/models/level_model.dart';

class LevelProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Level> _levels = [];
  int _userPoints = 0;
  int _currentLevel = 1;

  List<Level> get levels => _levels;
  int get userPoints => _userPoints;
  int get currentLevel => _currentLevel;

  LevelProvider() {
    _loadLevels();
    _loadUserData();
  }

  Future<void> _loadLevels() async {
    final db = await _dbHelper.database;
    final levelsData = await db.query('levels', orderBy: 'order_num');
    _levels = levelsData.map((level) => Level.fromMap(level)).toList();
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    final db = await _dbHelper.database;
    final userData = await db.query('users', where: 'id = ?', whereArgs: [1]);
    
    if (userData.isNotEmpty) {
      _userPoints = userData.first['totalPoints'] as int;
      _currentLevel = userData.first['currentLevel'] as int;
      notifyListeners();
    }
  }

  Future<void> unlockLevel(int levelId) async {
    final db = await _dbHelper.database;
    await db.update(
      'levels',
      {'isLocked': 0},
      where: 'id = ?',
      whereArgs: [levelId],
    );
    
    await _loadLevels();
  }

  Future<bool> canUnlockLevel(int levelId) async {
    final level = _levels.firstWhere((level) => level.id == levelId);
    return _userPoints >= level.requiredPoints;
  }

  Future<void> updateUserProgress(int points, int levelId) async {
    final db = await _dbHelper.database;
    
    // Atualizar pontos do usuário
    _userPoints += points;
    await db.update(
      'users',
      {'totalPoints': _userPoints},
      where: 'id = ?',
      whereArgs: [1],
    );
    
    // Verificar se pode desbloquear o próximo nível
    final nextLevelId = levelId + 1;
    final nextLevel = _levels.firstWhere(
      (level) => level.id == nextLevelId,
      orElse: () => Level(
        id: -1,
        title: '',
        description: '',
        category: '',
        order: -1,
        requiredPoints: -1,
      ),
    );
    
    if (nextLevel.id != -1 && _userPoints >= nextLevel.requiredPoints) {
      await unlockLevel(nextLevelId);
      
      // Atualizar nível atual do usuário
      _currentLevel = nextLevelId;
      await db.update(
        'users',
        {'currentLevel': _currentLevel},
        where: 'id = ?',
        whereArgs: [1],
      );
    }
    
    notifyListeners();
  }
}