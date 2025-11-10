import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logdomilhao/core/providers/gamification_provider.dart';
import 'package:logdomilhao/core/localization/app_localizations.dart';
import 'package:logdomilhao/data/models/score_model.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Carregar estatísticas do usuário
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GamificationProvider>(context, listen: false).loadUserStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gamificationProvider = Provider.of<GamificationProvider>(context);
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('progress')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localizations.translate('statistics').toUpperCase()),
            Tab(text: localizations.translate('achievements').toUpperCase()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatisticsTab(context, gamificationProvider, localizations),
          _buildAchievementsTab(context, gamificationProvider, localizations),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(BuildContext context, GamificationProvider provider, AppLocalizations localizations) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserLevelCard(context, provider, localizations),
          const SizedBox(height: 24),
          _buildStatisticsCard(context, provider, localizations),
          const SizedBox(height: 24),
          _buildRecentHistoryCard(context, provider, localizations),
        ],
      ),
    );
  }

  Widget _buildUserLevelCard(BuildContext context, GamificationProvider provider, AppLocalizations localizations) {
    final currentLevel = provider.getCurrentLevel();
    final nextLevelPoints = provider.getNextLevelPoints(provider.totalPoints);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '$currentLevel',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${localizations.translate('level')} $currentLevel',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$nextLevelPoints ${localizations.translate('next_level_points')}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 1 - (nextLevelPoints / 10),
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${localizations.translate('total_points')}: ${provider.totalPoints}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context, GamificationProvider provider, AppLocalizations localizations) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.translate('statistics'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              context,
              Icons.check_circle,
              localizations.translate('accuracy'),
              '${provider.accuracy.toStringAsFixed(1)}%',
            ),
            const Divider(),
            _buildStatItem(
              context,
              Icons.assignment,
              localizations.translate('exercises'),
              '${provider.totalExercises}',
            ),
            const Divider(),
            _buildStatItem(
              context,
              Icons.check,
              localizations.translate('correct_answers'),
              '${provider.correctAnswers}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistoryCard(BuildContext context, GamificationProvider provider, AppLocalizations localizations) {
    final recentScores = provider.recentScores;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.translate('recent_history'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            recentScores.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Nenhum exercício completado ainda.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentScores.length,
                    itemBuilder: (context, index) {
                      return _buildScoreItem(context, recentScores[index]);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(BuildContext context, Score score) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = dateFormat.format(score.completedAt);
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: score.isCorrect
            ? Colors.green[100]
            : Colors.red[100],
        child: Icon(
          score.isCorrect ? Icons.check : Icons.close,
          color: score.isCorrect ? Colors.green : Colors.red,
        ),
      ),
      title: Text('Exercício #${score.exerciseId}'),
      subtitle: Text(formattedDate),
      trailing: Text(
        '+${score.points}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildAchievementsTab(BuildContext context, GamificationProvider provider, AppLocalizations localizations) {
    final achievements = provider.achievements;
    
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(context, achievement, localizations);
      },
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement, AppLocalizations localizations) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: achievement.isUnlocked
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getAchievementIcon(achievement.id),
                    size: 40,
                    color: achievement.isUnlocked
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                ),
                if (!achievement.isUnlocked)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: achievement.isUnlocked
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: achievement.isUnlocked
                    ? null
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAchievementIcon(String achievementId) {
    switch (achievementId) {
      case 'first_step':
        return Icons.emoji_events;
      case 'dedicated_student':
        return Icons.school;
      case 'logic_master':
        return Icons.psychology;
      case 'perfect_score':
        return Icons.star;
      case 'fast_learner':
        return Icons.speed;
      default:
        return Icons.emoji_events;
    }
  }
}