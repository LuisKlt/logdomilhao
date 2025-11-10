import 'package:flutter/material.dart';
import 'package:logdomilhao/data/database_helper.dart';
import 'package:logdomilhao/data/models/score_model.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final String iconPath;
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.iconPath,
    this.isUnlocked = false,
  });
}

class GamificationProvider with ChangeNotifier {
  int _totalPoints = 0;
  int _correctAnswers = 0;
  int _totalExercises = 0;
  List<Score> _recentScores = [];
  List<Achievement> _achievements = [];
  
  int get totalPoints => _totalPoints;
  int get correctAnswers => _correctAnswers;
  int get totalExercises => _totalExercises;
  double get accuracy => _totalExercises > 0 ? _correctAnswers / _totalExercises * 100 : 0;
  List<Score> get recentScores => _recentScores;
  List<Achievement> get achievements => _achievements;

  GamificationProvider() {
    _initAchievements();
    loadUserStats();
  }

  void _initAchievements() {
    _achievements = [
      Achievement(
        id: 'first_step',
        title: 'Primeiro Passo',
        description: 'Complete seu primeiro exercício',
        pointsRequired: 1,
        iconPath: 'assets/images/achievements/first_step.png',
      ),
      Achievement(
        id: 'dedicated_student',
        title: 'Estudante Dedicado',
        description: 'Complete 10 exercícios',
        pointsRequired: 10,
        iconPath: 'assets/images/achievements/dedicated_student.png',
      ),
      Achievement(
        id: 'logic_master',
        title: 'Mestre da Lógica',
        description: 'Complete todos os níveis',
        pointsRequired: 50,
        iconPath: 'assets/images/achievements/logic_master.png',
      ),
      Achievement(
        id: 'perfect_score',
        title: 'Pontuação Perfeita',
        description: 'Acerte 5 exercícios seguidos',
        pointsRequired: 5,
        iconPath: 'assets/images/achievements/perfect_score.png',
      ),
      Achievement(
        id: 'fast_learner',
        title: 'Aprendiz Rápido',
        description: 'Complete um nível em menos de 2 minutos',
        pointsRequired: 20,
        iconPath: 'assets/images/achievements/fast_learner.png',
      ),
    ];
  }

  Future<void> loadUserStats() async {
    final dbHelper = DatabaseHelper();
    
    // Carregar pontuação total
    final scores = await dbHelper.getScores();
    _totalPoints = scores.fold(0, (sum, score) => sum + score.points);
    
    // Carregar estatísticas de acertos
    _correctAnswers = scores.where((score) => score.isCorrect).length;
    _totalExercises = scores.length;
    
    // Carregar pontuações recentes (últimas 10)
    _recentScores = scores.take(10).toList();
    
    // Verificar conquistas
    _checkAchievements();
    
    notifyListeners();
  }

  Future<void> addScore(Score score) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertScore(score);
    
    // Atualizar estatísticas
    _totalPoints += score.points;
    if (score.isCorrect) _correctAnswers++;
    _totalExercises++;
    
    // Adicionar à lista de pontuações recentes
    _recentScores.insert(0, score);
    if (_recentScores.length > 10) {
      _recentScores.removeLast();
    }
    
    // Verificar conquistas
    _checkAchievements();
    
    notifyListeners();
  }

  void _checkAchievements() {
    // Primeiro Passo
    if (_totalExercises >= 1) {
      _achievements.firstWhere((a) => a.id == 'first_step').isUnlocked = true;
    }
    
    // Estudante Dedicado
    if (_totalExercises >= 10) {
      _achievements.firstWhere((a) => a.id == 'dedicated_student').isUnlocked = true;
    }
    
    // Mestre da Lógica (verificação simplificada baseada em pontos)
    if (_totalPoints >= 50) {
      _achievements.firstWhere((a) => a.id == 'logic_master').isUnlocked = true;
    }
    
    // Pontuação Perfeita
    if (_recentScores.length >= 5 && 
        _recentScores.take(5).every((score) => score.isCorrect)) {
      _achievements.firstWhere((a) => a.id == 'perfect_score').isUnlocked = true;
    }
    
    // Fast Learner (simplificado, na implementação real precisaria verificar o tempo)
    if (_totalPoints >= 20) {
      _achievements.firstWhere((a) => a.id == 'fast_learner').isUnlocked = true;
    }
  }
  
  int getNextLevelPoints(int currentPoints) {
    // Lógica para determinar quantos pontos são necessários para o próximo nível
    // Exemplo: cada nível requer 10 pontos a mais que o anterior
    int basePoints = 10;
    int currentLevel = (currentPoints / basePoints).floor();
    int nextLevelPoints = (currentLevel + 1) * basePoints;
    return nextLevelPoints - currentPoints;
  }
  
  int getCurrentLevel() {
    // Cada 10 pontos avança um nível
    return (_totalPoints / 10).floor() + 1;
  }
}