import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logdomilhao/data/models/exercise_model.dart';
import 'package:logdomilhao/providers/exercise_provider.dart';
import 'package:logdomilhao/providers/gamification_provider.dart';

class ExerciseScreen extends StatefulWidget {
  final int levelId;

  const ExerciseScreen({
    super.key,
    required this.levelId,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  int _currentExerciseIndex = 0;
  String? _selectedAnswer;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  int _levelScore = 0;
  late TextEditingController _codeController;
  List<String> _codeBlocks = [];
  List<String> _selectedOrder = [];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExerciseProvider>(context, listen: false)
          .loadExercisesByLevel(widget.levelId);
    });
  }

  void _checkAnswer(List<Exercise> exercises) {
    final currentExercise = exercises[_currentExerciseIndex];
    final gamificationProvider = Provider.of<GamificationProvider>(context, listen: false);

    setState(() {
      _hasAnswered = true;
      bool correct = false;

      switch (currentExercise.type) {
        case 'multiple_choice':
          correct = _selectedAnswer == currentExercise.correctAnswer;
          break;
        case 'fill_blank':
          correct = _codeController.text.trim() == currentExercise.correctAnswer;
          break;
        case 'code_ordering':
          correct = _selectedOrder.join('') == currentExercise.correctAnswer;
          break;
      }

      _isCorrect = correct;

      if (_isCorrect) {
        _levelScore += currentExercise.points;
        gamificationProvider.addScore(
          currentExercise.id!, 
          true, 
          currentExercise.points
        );
      } else {
        gamificationProvider.addScore(
          currentExercise.id!, 
          false, 
          0
        );
      }
    });
  }

  void _nextExercise(List<Exercise> exercises) {
    setState(() {
      if (_currentExerciseIndex < exercises.length - 1) {
        _currentExerciseIndex++;
        _selectedAnswer = null;
        _hasAnswered = false;
        _codeController.clear();
        _selectedOrder.clear();
        _codeBlocks = [];
      } else {
        _showFinalResult(exercises);
      }
    });
  }

  Future<void> _showFinalResult(List<Exercise> exercises) async {
    final maxPoints = exercises.fold(0, (sum, e) => sum + e.points);
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    
    final bool unlockedNew = await exerciseProvider.submitLevelResult(
      context, 
      widget.levelId, 
      _levelScore, 
      maxPoints
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Nível Concluído!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _levelScore >= (maxPoints / 2) ? Icons.emoji_events : Icons.sentiment_neutral,
              color: _levelScore >= (maxPoints / 2) ? Colors.amber : Colors.grey,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Você fez $_levelScore de $maxPoints pontos!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (unlockedNew)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8)
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_open, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Próximo nível desbloqueado!', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            if (!unlockedNew && _levelScore < (maxPoints / 2))
              const Text(
                'Você precisa de pelo menos 50% dos pontos para avançar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('VOLTAR AOS NÍVEIS'),
          ),
        ],
      ),
    );
  }

  // =============== WIDGETS INTERATIVOS MELHORADOS ===============

  Widget _buildMultipleChoice(Exercise exercise) {
    return Column(
      children: exercise.options.map((option) {
        final isSelected = _selectedAnswer == option;
        final isCorrect = option == exercise.correctAnswer;
        
        Color? backgroundColor;
        if (_hasAnswered) {
          if (isSelected && isCorrect) {
            backgroundColor = Colors.green[100];
          } else if (isSelected && !isCorrect) {
            backgroundColor = Colors.red[100];
          } else if (isCorrect) {
            backgroundColor = Colors.green[50];
          }
        } else if (isSelected) {
          backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: backgroundColor,
          child: ListTile(
            onTap: _hasAnswered ? null : () {
              setState(() {
                _selectedAnswer = option;
              });
            },
            leading: isSelected
                ? Icon(
                    _hasAnswered
                        ? (isCorrect ? Icons.check_circle : Icons.cancel)
                        : Icons.radio_button_checked,
                    color: _hasAnswered
                        ? (isCorrect ? Colors.green : Colors.red)
                        : Theme.of(context).primaryColor,
                  )
                : Icon(
                    _hasAnswered && isCorrect
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: _hasAnswered && isCorrect
                        ? Colors.green
                        : Colors.grey,
                  ),
            title: Text(
              option,
              style: TextStyle(
                fontWeight: isSelected || (_hasAnswered && isCorrect)
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFillBlank(Exercise exercise) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruções
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Complete o código abaixo com a resposta correta:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.hintColor,
            ),
          ),
        ),
        
        // Editor de código (simulado)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.black87,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hasAnswered
                  ? (_isCorrect ? Colors.green : Colors.red)
                  : Colors.grey[600]!,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#include <stdio.h>',
                style: TextStyle(
                  color: Colors.green,
                  fontFamily: 'Monospace',
                  fontSize: 14,
                ),
              ),
              Text(
                'int main() {',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Monospace',
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  Text(
                    '    ',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Monospace',
                      fontSize: 14,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      enabled: !_hasAnswered,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Monospace',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: '// Digite seu código aqui...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        errorText: _codeController.text.isEmpty && _hasAnswered
                            ? 'Campo obrigatório'
                            : null,
                        errorStyle: TextStyle(color: Colors.orange[400]),
                      ),
                      onChanged: (value) {
                        if (_hasAnswered) return;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              Text(
                '    return 0;',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Monospace',
                  fontSize: 14,
                ),
              ),
              Text(
                '}',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Monospace',
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        // Botão de limpar (só aparece se tiver texto e não tiver respondido)
        if (!_hasAnswered && _codeController.text.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _codeController.clear();
                  });
                },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Limpar'),
              ),
            ),
          ),
        
        const SizedBox(height: 20),
        
        // Feedback da resposta
        if (_hasAnswered)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isCorrect ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCorrect ? Colors.green : Colors.red,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.error,
                      color: _isCorrect ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isCorrect ? 'Correto!' : 'Resposta Incorreta',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _isCorrect
                      ? 'Parabéns! Você escreveu o código corretamente.'
                      : 'Resposta esperada: ${exercise.correctAnswer}',
                  style: TextStyle(
                    color: _isCorrect ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCodeOrdering(Exercise exercise) {
    final theme = Theme.of(context);
    
    // Inicializar blocos se estiver vazio
    if (_codeBlocks.isEmpty) {
      _codeBlocks = List.from(exercise.options);
      _codeBlocks.shuffle();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruções
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Arraste os blocos para a área de montagem na ordem correta:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.hintColor,
            ),
          ),
        ),
        
        // Área de blocos disponíveis
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Blocos Disponíveis',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.hintColor,
                    ),
                  ),
                  if (!_hasAnswered)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _codeBlocks.shuffle();
                        });
                      },
                      icon: const Icon(Icons.shuffle, size: 16),
                      label: const Text('Embaralhar'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _codeBlocks.map((block) {
                  final isSelected = _selectedOrder.contains(block);
                  return Draggable<String>(
                    data: block,
                    feedback: Material(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          block,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: isSelected ? 0.0 : 0.5,
                      child: _buildCodeBlock(block, isSelected: false),
                    ),
                    child: isSelected
                        ? _buildCodeBlock(
                            block,
                            isSelected: true,
                            color: Colors.grey[300]!,
                          )
                        : _buildCodeBlock(
                            block,
                            isSelected: false,
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Área de montagem
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Área de Montagem',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 150),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.dividerColor,
                    style: BorderStyle.solid,
                  ),
                ),
                child: DragTarget<String>(
                  onAccept: (data) {
                    setState(() {
                      if (!_selectedOrder.contains(data)) {
                        _selectedOrder.add(data);
                      }
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedOrder.map((block) {
                        return Draggable<String>(
                          data: block,
                          feedback: Material(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Text(
                                block,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  block,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (!_hasAnswered)
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    onPressed: () {
                                      setState(() {
                                        _selectedOrder.remove(block);
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              
              // Botão de reset
              if (!_hasAnswered && _selectedOrder.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedOrder.clear();
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Reiniciar'),
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Feedback da resposta
        if (_hasAnswered)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isCorrect ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCorrect ? Colors.green : Colors.red,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.error,
                      color: _isCorrect ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isCorrect ? 'Ordem Correta!' : 'Ordem Incorreta',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _isCorrect
                      ? 'Parabéns! Você ordenou os blocos corretamente.'
                      : 'Ordem correta: ${exercise.correctAnswer}',
                  style: TextStyle(
                    color: _isCorrect ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCodeBlock(String text, {bool isSelected = false, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.grey[400]! : Colors.transparent,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.grey[600] : null,
        ),
      ),
    );
  }

  Widget _buildExerciseContent(Exercise exercise) {
    switch (exercise.type) {
      case 'fill_blank':
        return _buildFillBlank(exercise);
      case 'code_ordering':
        return _buildCodeOrdering(exercise);
      case 'multiple_choice':
      default:
        return _buildMultipleChoice(exercise);
    }
  }

  bool _isAnswerSelected(Exercise exercise) {
    switch (exercise.type) {
      case 'multiple_choice':
        return _selectedAnswer != null;
      case 'fill_blank':
        return _codeController.text.trim().isNotEmpty;
      case 'code_ordering':
        return _selectedOrder.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Nível ${widget.levelId} - Exercício ${_currentExerciseIndex + 1}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ExerciseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.exercises.isEmpty) {
            return const Center(child: Text('Nenhum exercício encontrado neste nível.'));
          }

          final exercises = provider.exercises;
          final currentExercise = exercises[_currentExerciseIndex];

          return Column(
            children: [
              // Barra de progresso
              LinearProgressIndicator(
                value: (_currentExerciseIndex + 1) / exercises.length,
                backgroundColor: theme.dividerColor,
                color: theme.primaryColor,
              ),

              // Conteúdo do exercício
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título e descrição
                      Text(
                        currentExercise.title,
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentExercise.description,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Enunciado do exercício
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Text(
                          currentExercise.content,
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Conteúdo interativo específico
                      _buildExerciseContent(currentExercise),
                    ],
                  ),
                ),
              ),

              // Barra inferior com botões
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pontos deste nível: $_levelScore',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Consumer<GamificationProvider>(
                          builder: (context, gamificationProvider, child) {
                            return Text(
                              'Total: ${gamificationProvider.points} pts',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.hintColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _hasAnswered
                          ? () => _nextExercise(exercises)
                          : (_isAnswerSelected(currentExercise) 
                              ? () => _checkAnswer(exercises) 
                              : null),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasAnswered
                            ? Colors.green
                            : (_isAnswerSelected(currentExercise)
                                ? theme.primaryColor
                                : Colors.grey),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        _hasAnswered
                            ? (_currentExerciseIndex < exercises.length - 1
                                ? 'PRÓXIMO'
                                : 'FINALIZAR')
                            : (_isAnswerSelected(currentExercise)
                                ? 'VERIFICAR'
                                : 'RESPONDA'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}