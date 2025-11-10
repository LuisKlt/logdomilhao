import 'package:flutter/material.dart';
import 'package:logdomilhao/data/models/exercise_model.dart';

class ExerciseWidget extends StatelessWidget {
  final Exercise exercise;
  final String? selectedOption;
  final bool showFeedback;
  final bool isCorrect;
  final Function(String) onOptionSelected;
  
  const ExerciseWidget({
    super.key,
    required this.exercise,
    required this.selectedOption,
    required this.showFeedback,
    required this.isCorrect,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título e descrição
        Text(
          exercise.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          exercise.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        
        // Conteúdo do exercício
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            exercise.content,
            style: const TextStyle(
              fontFamily: 'Courier New',
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Opções
        ...exercise.options.map((option) {
          final isSelected = selectedOption == option;
          final showCorrect = showFeedback && option == exercise.correctAnswer;
          final showIncorrect = showFeedback && isSelected && !isCorrect;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: showFeedback ? null : () => onOptionSelected(option),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: showCorrect
                      ? Colors.green.withOpacity(0.2)
                      : showIncorrect
                          ? Colors.red.withOpacity(0.2)
                          : isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: showCorrect
                        ? Colors.green
                        : showIncorrect
                            ? Colors.red
                            : isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(option),
                    ),
                    if (showCorrect)
                      const Icon(Icons.check_circle, color: Colors.green)
                    else if (showIncorrect)
                      const Icon(Icons.cancel, color: Colors.red),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        
        // Feedback
        if (showFeedback)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCorrect ? Colors.green : Colors.red,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCorrect
                        ? 'Correto! +${exercise.points} pontos'
                        : 'Incorreto! A resposta correta é: ${exercise.correctAnswer}',
                    style: TextStyle(
                      color: isCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}