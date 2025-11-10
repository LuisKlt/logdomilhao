import 'package:flutter/foundation.dart';
import 'package:logdomilhao/data/database_helper.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  bool isUnlocked;
  final int requiredPoints;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    required this.requiredPoints,
  });
}

class GamificationProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  int _points = 0;
  int _correctAnswers = 0;
  int _totalExercises = 0;
  int _currentLevel = 1;
  List<Achievement> _achievements = [];
  List<Map<String, dynamic>> _recentScores = [];

  int get points => _points;
  int get correctAnswers => _correctAnswers;
  int get totalExercises => _totalExercises;
  int get currentLevel => _currentLevel;
  List<Achievement> get achievements => _achievements;
  List<Map<String, dynamic>> get recentScores => _recentScores;
  
  double get accuracy => _totalExercises > 0 ? _correctAnswers / _totalExercises * 100 : 0;

  GamificationProvider() {
    _initAchievements();
    _loadUserStats();
  }

  void _initAchievements() {
    _achievements = [
      Achievement(
        id: 'first_correct',
        title: 'Primeira Resposta Correta',
        description: 'Respondeu corretamente pela primeira vez',
        icon: 'assets/icons/achievement_first.png',
        requiredPoints: 10,
      ),
      Achievement(
        id: 'streak_3',
        title: 'Sequência de 3',
        description: 'Respondeu 3 perguntas corretamente em sequência',
        icon: 'assets/icons/achievement_streak.png',
        requiredPoints: 30,
      ),
      Achievement(
        id: 'level_2',
        title: 'Nível 2 Desbloqueado',
        description: 'Desbloqueou o nível 2',
        icon: 'assets/icons/achievement_level.png',
        requiredPoints: 50,
      ),
      Achievement(
        id: 'points_100',
        title: 'Centenário',
        description: 'Acumulou 100 pontos',
        icon: 'assets/icons/achievement_points.png',
        requiredPoints: 100,
      ),
      Achievement(
        id: 'level_3',
        title: 'Nível 3 Desbloqueado',
        description: 'Desbloqueou o nível 3',
        icon: 'assets/icons/achievement_level.png',
        requiredPoints: 100,
      ),
      Achievement(
        id: 'exercises_20',
        title: 'Persistente',
        description: 'Completou 20 exercícios',
        icon: 'assets/icons/achievement_exercises.png',
        requiredPoints: 0, // Baseado no número de exercícios, não em pontos
      ),
    ];
  }

  Future<void> _loadUserStats() async {
    try {
      // Carregar dados do usuário
      final userList = await _dbHelper.queryWhere('users', 'id = ?', [1]);
      if (userList.isNotEmpty) {
        final user = userList.first;
        _points = user['totalPoints'] ?? 0;
        _currentLevel = user['currentLevel'] ?? 1;
      }

      // Carregar pontuações para calcular estatísticas
      final scores = await _dbHelper.getScores();
      _totalExercises = scores.length;
      _correctAnswers = scores.where((score) => score.isCorrect).length;

      // Carregar pontuações recentes
      final recentScoresMaps = await _dbHelper.query('scores');
      if (recentScoresMaps.isNotEmpty) {
        _recentScores = recentScoresMaps.take(10).toList();
      }

      // Verificar conquistas com base nos dados carregados
      _checkAchievements();
      
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar estatísticas do usuário: $e');
    }
  }

  Future<void> addScore(int exerciseId, bool isCorrect, int points) async {
    try {
      final score = {
        'userId': 1,
        'exerciseId': exerciseId,
        'points': points,
        'isCorrect': isCorrect ? 1 : 0,
        'completedAt': DateTime.now().toIso8601String(),
      };

      await _dbHelper.insert('scores', score);
      
      if (isCorrect) {
        _points += points;
        _correctAnswers++;
        
        // Atualizar pontos do usuário no banco de dados
        await _dbHelper.update(
          'users', 
          {'totalPoints': _points}, 
          'id = ?', 
          [1]
        );
        
        // Verificar se o usuário subiu de nível
        _checkLevelUp();
      }
      
      _totalExercises++;
      
      // Recarregar pontuações recentes
      final recentScoresMaps = await _dbHelper.query('scores');
      if (recentScoresMaps.isNotEmpty) {
        _recentScores = recentScoresMaps.take(10).toList();
      }
      
      // Verificar conquistas
      _checkAchievements();
      
      notifyListeners();
    } catch (e) {
      print('Erro ao adicionar pontuação: $e');
    }
  }

  void _checkLevelUp() async {
    try {
      // Verificar se o usuário tem pontos suficientes para subir de nível
      final levels = await _dbHelper.query('levels');
      
      for (var level in levels) {
        if (level['id'] > _currentLevel && 
            _points >= (level['requiredPoints'] ?? 0)) {
          _currentLevel = level['id'];
          
          // Desbloquear o nível no banco de dados
          await _dbHelper.update(
            'levels', 
            {'isLocked': 0}, 
            'id = ?', 
            [_currentLevel]
          );
          
          // Atualizar nível do usuário
          await _dbHelper.update(
            'users', 
            {'currentLevel': _currentLevel}, 
            'id = ?', 
            [1]
          );
          
          break;
        }
      }
    } catch (e) {
      print('Erro ao verificar subida de nível: $e');
    }
  }

  void _checkAchievements() {
    // Verificar conquistas baseadas em pontos
    for (var achievement in _achievements) {
      if (!achievement.isUnlocked) {
        if (achievement.id == 'first_correct' && _correctAnswers > 0) {
          achievement.isUnlocked = true;
        } else if (achievement.id == 'level_2' && _currentLevel >= 2) {
          achievement.isUnlocked = true;
        } else if (achievement.id == 'level_3' && _currentLevel >= 3) {
          achievement.isUnlocked = true;
        } else if (achievement.id == 'points_100' && _points >= 100) {
          achievement.isUnlocked = true;
        } else if (achievement.id == 'exercises_20' && _totalExercises >= 20) {
          achievement.isUnlocked = true;
        }
        // A conquista streak_3 seria verificada em uma lógica mais complexa
      }
    }
  }
}