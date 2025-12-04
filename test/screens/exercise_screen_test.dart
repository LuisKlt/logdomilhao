import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logdomilhao/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end App Tests', () {
    testWidgets('Complete flow: Home -> Levels -> Exercise -> Progress', 
      (WidgetTester tester) async {
      
      // Iniciar o app
      app.main();
      await tester.pumpAndSettle();

      // Verificar se a SplashScreen aparece
      expect(find.text('LogDoMilhão'), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Verificar se a HomeScreen aparece
      expect(find.text('COMEÇAR APRENDIZADO'), findsOneWidget);
      
      // Navegar para LevelsScreen
      await tester.tap(find.text('COMEÇAR APRENDIZADO'));
      await tester.pumpAndSettle();

      // Verificar se LevelsScreen aparece
      expect(find.text('Níveis de Aprendizado'), findsOneWidget);
      
      // Clicar no primeiro nível (deve estar desbloqueado)
      await tester.tap(find.text('Variáveis e Tipos').first);
      await tester.pumpAndSettle();

      // Verificar se ExerciseScreen aparece
      expect(find.text('Nível 1 - Exercício 1'), findsOneWidget);
      
      // Voltar para LevelsScreen
      await tester.pageBack();
      await tester.pumpAndSettle();
      
      // Navegar para SettingsScreen
      await tester.tap(find.byIcon(Icons.settings).first);
      await tester.pumpAndSettle();
      
      // Verificar se SettingsScreen aparece
      expect(find.text('Configurações'), findsOneWidget);
      
      // Voltar para HomeScreen
      await tester.pageBack();
      await tester.pumpAndSettle();
    });

    testWidgets('Exercise completion flow', (WidgetTester tester) async {
      // Este teste simula a realização de um exercício
      // Nota: Você precisará adaptar baseado na implementação real dos exercícios
      
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));
      
      // Navegar para exercícios
      await tester.tap(find.text('COMEÇAR APRENDIZADO'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Variáveis e Tipos').first);
      await tester.pumpAndSettle();
      
      // Aqui você implementaria a interação com os exercícios
      // Como selecionar resposta, preencher campo, etc.
      
      // Exemplo para múltipla escolha:
      // await tester.tap(find.text('Resposta Correta').first);
      // await tester.pump();
      // await tester.tap(find.text('VERIFICAR'));
      // await tester.pumpAndSettle();
      
      // Verificar se os pontos foram atualizados
      // expect(find.text('Pontuação: 20'), findsOneWidget);
    });
  });
}