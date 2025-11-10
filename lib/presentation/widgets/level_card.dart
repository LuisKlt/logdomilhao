import 'package:flutter/material.dart';
import 'package:logdomilhao/core/theme/app_theme.dart';
import 'package:logdomilhao/data/models/level_model.dart';

class LevelCard extends StatelessWidget {
  final Level level;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.level,
    required this.onTap,
  });

  IconData _getCategoryIcon() {
    switch (level.category) {
      case 'variables':
        return Icons.data_object;
      case 'input_output':
        return Icons.input;
      case 'conditionals':
        return Icons.call_split;
      case 'loops':
        return Icons.loop;
      case 'functions':
        return Icons.functions;
      default:
        return Icons.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: level.isLocked
                      ? Colors.grey.withOpacity(0.2)
                      : AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  level.isLocked ? Icons.lock : _getCategoryIcon(),
                  size: 30,
                  color: level.isLocked ? Colors.grey : AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: level.isLocked ? Colors.grey : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: level.isLocked ? Colors.grey : Colors.black54,
                      ),
                    ),
                    if (level.isLocked) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${level.requiredPoints} pontos necessários',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: level.isLocked ? Colors.grey : AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}