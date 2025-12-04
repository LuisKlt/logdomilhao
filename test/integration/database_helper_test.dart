import 'package:flutter_test/flutter_test.dart';
import 'package:logdomilhao/data/database/database_helper.dart';
import 'package:logdomilhao/data/models/score_model.dart';

void main() {
  group('DatabaseHelper Integration Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      // Usar uma instância em memória para testes
      dbHelper = DatabaseHelper();
    });

    tearDown(() async {
      // Fechar a conexão com o banco
    });

    test('Should insert and retrieve score', () async {
      final score = Score(
        userId: 1,
        exerciseId: 1,
        points: 10,
        isCorrect: true,
        completedAt: DateTime.now(),
      );

      // Inserir pontuação
      await dbHelper.insertScore(score);

      // Recuperar pontuações
      final scores = await dbHelper.getScores();

      expect(scores, isNotEmpty);
      expect(scores.first.points, 10);
      expect(scores.first.isCorrect, true);
    });

    test('Should insert and query data', () async {
      final testData = {
        'username': 'TestUser',
        'totalPoints': 100,
        'currentLevel': 2,
        'language': 'pt',
      };

      // Inserir dados
      await dbHelper.insert('users', testData);

      // Consultar dados
      final users = await dbHelper.query('users');

      expect(users, isNotEmpty);
      expect(users.first['username'], 'TestUser');
      expect(users.first['totalPoints'], 100);
    });
  });
}