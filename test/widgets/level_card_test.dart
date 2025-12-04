import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logdomilhao/data/models/level_model.dart';
import 'package:logdomilhao/presentation/widgets/level_card.dart';

void main() {
  group('LevelCard Widget Tests', () {
    final unlockedLevel = Level(
      id: 1,
      title: 'Test Level',
      description: 'Test Description',
      category: 'variables',
      order: 1,
      isLocked: false,
      requiredPoints: 0,
    );

    final lockedLevel = Level(
      id: 2,
      title: 'Locked Level',
      description: 'Locked Description',
      category: 'input_output',
      order: 2,
      isLocked: true,
      requiredPoints: 50,
    );

    testWidgets('Should show unlocked level correctly', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelCard(
              level: unlockedLevel,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Verificar se o título está visível
      expect(find.text('Test Level'), findsOneWidget);
      
      // Verificar se o ícone de cadeado não está presente
      expect(find.byIcon(Icons.lock), findsNothing);
      
      // Tocar no card
      await tester.tap(find.byType(LevelCard));
      await tester.pump();
      
      expect(tapped, true);
    });

    testWidgets('Should show locked level correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelCard(
              level: lockedLevel,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verificar se o título está visível
      expect(find.text('Locked Level'), findsOneWidget);
      
      // Verificar se o ícone de cadeado está presente
      expect(find.byIcon(Icons.lock), findsOneWidget);
      
      // Verificar se os pontos necessários são mostrados
      expect(find.text('50 pontos necessários'), findsOneWidget);
    });

    testWidgets('Should show correct icon for each category', (WidgetTester tester) async {
      final testLevel = Level(
        id: 1,
        title: 'Test',
        description: 'Test',
        category: 'functions',
        order: 1,
        isLocked: false,
        requiredPoints: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelCard(
              level: testLevel,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verificar se o ícone correto é mostrado para a categoria 'functions'
      expect(find.byIcon(Icons.functions), findsOneWidget);
    });
  });
}