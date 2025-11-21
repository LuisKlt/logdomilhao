import 'package:flutter/material.dart';
import 'package:logdomilhao/data/database/database_helper.dart';
import 'package:logdomilhao/data/models/exercise_model.dart';
import 'package:logdomilhao/providers/gamification_provider.dart';
import 'package:provider/provider.dart';

class ExerciseProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Exercise> _exercises = [];
  bool _isLoading = false;

  List<Exercise> get exercises => _exercises;
  bool get isLoading => _isLoading;

  // Carrega exercícios do banco baseado no ID do nível
  Future<void> loadExercisesByLevel(int levelId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await _dbHelper.database;
      final exercisesData = await db.query(
        'exercises',
        where: 'levelId = ?',
        whereArgs: [levelId],
      );

      _exercises = exercisesData.map((e) => Exercise.fromMap(e)).toList();
    } catch (e) {
      print("Erro ao carregar exercícios: $e");
      _exercises = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lógica para salvar pontuação e verificar desbloqueio
  Future<bool> submitLevelResult(BuildContext context, int levelId, int totalScore, int maxPossibleScore) async {
    // Critério: Para desbloquear o próximo, precisa de 50% dos pontos do nível
    final double percentage = maxPossibleScore > 0 ? totalScore / maxPossibleScore : 0;
    final bool passedLevel = percentage >= 0.5; // 50% para passar

    if (passedLevel) {
      final db = await _dbHelper.database;
      
      // 1. Desbloquear o próximo nível (levelId + 1)
      final nextLevelId = levelId + 1;
      
      // Verifica se existe o próximo nível
      final nextLevelExists = await db.query(
        'levels', 
        where: 'id = ?', 
        whereArgs: [nextLevelId]
      );

      if (nextLevelExists.isNotEmpty) {
        await db.update(
          'levels',
          {'isLocked': 0}, // 0 = Desbloqueado
          where: 'id = ?',
          whereArgs: [nextLevelId],
        );
        
        // Atualiza o GamificationProvider para refletir a mudança na UI
        if (context.mounted) {
           await Provider.of<GamificationProvider>(context, listen: false).loadUserStats();
        }
        return true; // Retorna true se desbloqueou algo novo
      }
    }
    return false;
  }
}