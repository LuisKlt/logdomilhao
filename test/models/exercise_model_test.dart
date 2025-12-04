import 'package:flutter_test/flutter_test.dart';
import 'package:logdomilhao/data/models/exercise_model.dart';

void main() {
  group('Exercise Model Tests', () {
    test('Should create Exercise from map', () {
      final map = {
        'id': 1,
        'levelId': 1,
        'title': 'Test Exercise',
        'description': 'Test Description',
        'type': 'multiple_choice',
        'content': 'Test Content',
        'correctAnswer': 'Correct',
        'options': 'Option1|Option2|Option3',
        'points': 10,
      };

      final exercise = Exercise.fromMap(map);

      expect(exercise.id, 1);
      expect(exercise.levelId, 1);
      expect(exercise.title, 'Test Exercise');
      expect(exercise.type, 'multiple_choice');
      expect(exercise.options, ['Option1', 'Option2', 'Option3']);
      expect(exercise.points, 10);
    });

    test('Should convert Exercise to map', () {
      final exercise = Exercise(
        id: 1,
        levelId: 1,
        title: 'Test Exercise',
        description: 'Test Description',
        type: 'multiple_choice',
        content: 'Test Content',
        correctAnswer: 'Correct',
        options: ['Option1', 'Option2'],
        points: 10,
      );

      final map = exercise.toMap();

      expect(map['id'], 1);
      expect(map['title'], 'Test Exercise');
      expect(map['options'], 'Option1|Option2');
    });
  });
}