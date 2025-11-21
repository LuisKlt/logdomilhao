import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logdomilhao/core/theme/app_theme.dart';
import 'package:logdomilhao/providers/gamification_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationProvider>(
      builder: (context, gamificationProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Meu Progresso'),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estatísticas principais
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Estatísticas Gerais',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              'Pontuação',
                              '${gamificationProvider.points}',
                              Icons.emoji_events,
                            ),
                            _buildStatCard(
                              'Nível',
                              '${gamificationProvider.currentLevel}',
                              Icons.star,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              'Acertos',
                              '${gamificationProvider.correctAnswers}',
                              Icons.check_circle,
                            ),
                            _buildStatCard(
                              'Precisão',
                              '${gamificationProvider.accuracy.toStringAsFixed(1)}%',
                              Icons.show_chart,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Conquistas
                const Text(
                  'Conquistas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...gamificationProvider.achievements.map((achievement) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: achievement.isUnlocked 
                        ? Colors.green[50] 
                        : Colors.grey[100],
                    child: ListTile(
                      leading: Icon(
                        achievement.isUnlocked 
                            ? Icons.check_circle 
                            : Icons.lock,
                        color: achievement.isUnlocked 
                            ? Colors.green 
                            : Colors.grey,
                      ),
                      title: Text(achievement.title),
                      subtitle: Text(achievement.description),
                      trailing: achievement.isUnlocked
                          ? const Icon(Icons.verified, color: Colors.green)
                          : null,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}