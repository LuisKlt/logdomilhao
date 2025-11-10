import 'package:flutter/material.dart';
import 'package:logdomilhao/data/database_helper.dart';
import 'package:logdomilhao/data/models/exercise_model.dart';
import 'package:logdomilhao/data/models/score_model.dart';
import 'package:logdomilhao/providers/level_provider.dart';
import 'package:provider/provider.dart';

class ExerciseProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Exercise> _exercises = [];
  List<Score> _scores = [];
  
  List<Exercise> get exercises => _exercises;
  List<Score> get scores => _scores;

  ExerciseProvider() {
    _loadScores();
  }

  Future<List<Exercise>> getExercisesByLevel(int levelId) async {
    final db = await _dbHelper.database;
    final exercisesData = await db.query(
      'exercises',
      where: 'levelId = ?',
      whereArgs: [levelId],
    );
    
    _exercises = exercisesData.map((exercise) => Exercise.fromMap(exercise)).toList();
    notifyListeners();
    return _exercises;
  }

  Future<void> _loadScores() async {
    final db = await _dbHelper.database;
    final scoresData = await db.query('scores', orderBy: 'completedAt DESC');
    _scores = scoresData.map((score) => Score.fromMap(score)).toList();
    notifyListeners();
  }

  Future<void> saveScore(BuildContext context, int exerciseId, int points, bool isCorrect) async {
    final db = await _dbHelper.database;
    
    // Obter o exercício atual
    final exercise = _exercises.firstWhere((e) => e.id == exerciseId);
    
    // Salvar a pontuação
    final score = Score(
      userId: 1, // Usuário padrão
      exerciseId: exerciseId,
      points: isCorrect ? points : 0,
      isCorrect: isCorrect,
      completedAt: DateTime.now() //.toIso8601String(),
    );
    
    await db.insert('scores', score.toMap());
    
    // Atualizar o progresso do usuário se a resposta estiver correta
    if (isCorrect) {
      final levelProvider = Provider.of<LevelProvider>(context, listen: false);
      await levelProvider.updateUserProgress(points, exercise.levelId);
    }
    
    await _loadScores();
  }

  // Fornece feedback imediato sobre a resposta
  String getFeedback(bool isCorrect, String exerciseType) {
    if (isCorrect) {
      return 'Parabéns! Você acertou!';
    } else {
      switch (exerciseType) {
        case 'multiple_choice':
          return 'Ops! Resposta incorreta. Tente novamente!';
        case 'fill_blank':
          return 'Ops! Sua resposta não está correta. Verifique a sintaxe!';
        case 'code_completion':
          return 'Seu código não está funcionando corretamente. Revise a lógica!';
        default:
          return 'Resposta incorreta. Continue tentando!';
      }
    }
  }

  // Verifica se a resposta está correta
  bool checkAnswer(Exercise exercise, String userAnswer) {
    switch (exercise.type) {
      case 'multiple_choice':
        return userAnswer == exercise.correctAnswer;
      case 'fill_blank':
      case 'code_completion':
        // Poderia implementar uma lógica mais complexa para verificar código
        return userAnswer.trim() == exercise.correctAnswer.trim();
      default:
        return false;
    }
  }
}