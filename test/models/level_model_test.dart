import 'package:flutter_test/flutter_test.dart';
import 'package:logdomilhao/data/models/level_model.dart';

void main() {
  group('Level Model Tests', () {
    test('Should create Level from map', () {
      final map = {
        'id': 1,
        'title': 'Test Level',
        'description': 'Test Description',
        'category': 'variables',
        'order': 1,
        'isLocked': 0,
        'requiredPoints': 0,
      };

      final level = Level.fromMap(map);

      expect(level.id, 1);
      expect(level.title, 'Test Level');
      expect(level.isLocked, false);
      expect(level.requiredPoints, 0);
    });

    test('Should convert Level to map', () {
      final level = Level(
        id: 1,
        title: 'Test Level',
        description: 'Test Description',
        category: 'variables',
        order: 1,
        isLocked: false,
        requiredPoints: 50,
      );

      final map = level.toMap();

      expect(map['id'], 1);
      expect(map['isLocked'], 0);
      expect(map['requiredPoints'], 50);
    });
  });
}