import 'package:flutter/material.dart';
import 'package:logdomilhao/core/theme/app_theme.dart';
import 'package:logdomilhao/data/models/level_model.dart';
import 'package:logdomilhao/presentation/screens/exercise_screen.dart';
import 'package:logdomilhao/presentation/widgets/level_card.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  // Dados de exemplo para demonstração
  List<Level> _getLevels() {
    return [
      Level(
        id: 1,
        title: 'Variáveis e Tipos',
        description: 'Aprenda sobre variáveis e tipos de dados em programação',
        category: 'variables',
        order: 1,
        isLocked: false,
        requiredPoints: 0,
      ),
      Level(
        id: 2,
        title: 'Entrada e Saída',
        description: 'Aprenda como receber e exibir dados em programação',
        category: 'input_output',
        order: 2,
        isLocked: true,
        requiredPoints: 50,
      ),
      Level(
        id: 3,
        title: 'Condicionais',
        description: 'Aprenda sobre estruturas condicionais em programação',
        category: 'conditionals',
        order: 3,
        isLocked: true,
        requiredPoints: 100,
      ),
      Level(
        id: 4,
        title: 'Laços de Repetição',
        description: 'Aprenda sobre estruturas de repetição em programação',
        category: 'loops',
        order: 4,
        isLocked: true,
        requiredPoints: 150,
      ),
      Level(
        id: 5,
        title: 'Funções',
        description: 'Aprenda sobre funções e modularização em programação',
        category: 'functions',
        order: 5,
        isLocked: true,
        requiredPoints: 200,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final levels = _getLevels();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Níveis de Aprendizado'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text('1', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seu Progresso',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '10 pontos',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Navegar para a tela de progresso
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ver Progresso'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                return LevelCard(
                  level: level,
                  onTap: () {
                    if (!level.isLocked) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ExerciseScreen(levelId: level.id!),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Você precisa de ${level.requiredPoints} pontos para desbloquear este nível',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}