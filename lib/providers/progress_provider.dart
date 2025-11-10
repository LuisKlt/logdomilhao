import 'package:flutter/material.dart';
import 'package:logdomilhao/data/database_helper.dart';
import 'package:logdomilhao/data/models/score_model.dart';

class ProgressProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Score> _scoreHistory = [];
  Map<String, int> _statisticsByLevel = {};
  int _totalCorrectAnswers = 0;
  int _totalWrongAnswers = 0;
  int _totalPoints = 0;
  double _averageScore = 0.0;

  List<Score> get scoreHistory => _scoreHistory;
  Map<String, int> get statisticsByLevel => _statisticsByLevel;
  int get totalCorrectAnswers => _totalCorrectAnswers;
  int get totalWrongAnswers => _totalWrongAnswers;
  int get totalPoints => _totalPoints;
  double get averageScore => _averageScore;

  ProgressProvider() {
    loadUserProgress();
  }

  Future<void> loadUserProgress() async {
    await _loadScoreHistory();
    await _calculateStatistics();
    notifyListeners();
  }

  Future<void> _loadScoreHistory() async {
    final db = await _dbHelper.database;
    
    // Obter histórico de pontuações
    final scoresData = await db.rawQuery('''
      SELECT s.*, e.title as exerciseTitle, e.levelId 
      FROM scores s
      JOIN exercises e ON s.exerciseId = e.id
      WHERE s.userId = 1
      ORDER BY s.completedAt DESC
    ''');
    
    _scoreHistory = scoresData.map((score) => Score.fromMap(score)).toList();
  }

  Future<void> _calculateStatistics() async {
    final db = await _dbHelper.database;
    
    // Calcular estatísticas por nível
    final levelStats = await db.rawQuery('''
      SELECT l.title, COUNT(s.id) as count
      FROM scores s
      JOIN exercises e ON s.exerciseId = e.id
      JOIN levels l ON e.levelId = l.id
      WHERE s.userId = 1
      GROUP BY l.id
    ''');
    
    _statisticsByLevel = {};
    for (var stat in levelStats) {
      _statisticsByLevel[stat['title'] as String] = stat['count'] as int;
    }
    
    // Calcular estatísticas gerais
    final generalStats = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN isCorrect = 1 THEN 1 ELSE 0 END) as correctAnswers,
        SUM(CASE WHEN isCorrect = 0 THEN 1 ELSE 0 END) as wrongAnswers,
        SUM(points) as totalPoints
      FROM scores
      WHERE userId = 1
    ''');
    
    if (generalStats.isNotEmpty) {
      _totalCorrectAnswers = generalStats.first['correctAnswers'] as int? ?? 0;
      _totalWrongAnswers = generalStats.first['wrongAnswers'] as int? ?? 0;
      _totalPoints = generalStats.first['totalPoints'] as int? ?? 0;
      
      final totalAttempts = _totalCorrectAnswers + _totalWrongAnswers;
      _averageScore = totalAttempts > 0 ? _totalCorrectAnswers / totalAttempts * 100 : 0.0;
    }
  }

  Future<List<Score>> getRecentScores({int limit = 10}) async {
    return _scoreHistory.take(limit).toList();
  }

  Future<Map<String, dynamic>> getUserProgressSummary() async {
    return {
      'totalPoints': _totalPoints,
      'correctAnswers': _totalCorrectAnswers,
      'wrongAnswers': _totalWrongAnswers,
      'averageScore': _averageScore,
      'completedExercises': _totalCorrectAnswers + _totalWrongAnswers,
    };
  }
}