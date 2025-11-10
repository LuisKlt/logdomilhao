import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logdomilhao/core/theme/app_theme.dart';
import 'package:logdomilhao/data/models/exercise_model.dart';

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
  int _score = 0;
  TextEditingController _codeController = TextEditingController();
  List<String> _codeBlocks = [];
  List<String> _selectedOrder = [];

  // Dados de exemplo para demonstração
  List<Exercise> _getExercises() {
    if (widget.levelId == 1) {
      return [
        Exercise(
          id: 1,
          levelId: 1,
          title: 'Declaração de Variáveis em C',
          description: 'Complete o código para declarar uma variável inteira',
          type: 'fill_blank',
          content: 'Complete o código abaixo para declarar uma variável inteira chamada "idade" com valor 25:',
          correctAnswer: 'int idade = 25;',
          options: [],
          points: 10,
        ),
        Exercise(
          id: 2,
          levelId: 1,
          title: 'Ordenação de Código - Loop For',
          description: 'Arraste os blocos para ordenar o código corretamente',
          type: 'code_ordering',
          content: 'Ordene os blocos para criar um loop for que imprime números de 1 a 5:',
          correctAnswer: 'for(int i=1;i<=5;i++){printf("%d",i);}',
          options: [
            'for(int i=1;',
            'i<=5;',
            'i++){',
            'printf("%d",i);',
            '}'
          ],
          points: 15,
        ),
        Exercise(
          id: 3,
          levelId: 1,
          title: 'Funções em C',
          description: 'Selecione a sintaxe correta para declarar uma função',
          type: 'multiple_choice',
          content: 'Qual é a forma correta de declarar uma função que retorna um inteiro e não recebe parâmetros?',
          correctAnswer: 'int funcao()',
          options: [
            'function int funcao()',
            'int funcao()',
            'funcao() int',
            'int funcao(void)'
          ],
          points: 12,
        ),
      ];
    }
    return [];
  }

  void _checkAnswer() {
    final exercises = _getExercises();
    final currentExercise = exercises[_currentExerciseIndex];
    
    setState(() {
      _hasAnswered = true;
      
      switch (currentExercise.type) {
        case 'multiple_choice':
          _isCorrect = _selectedAnswer == currentExercise.correctAnswer;
          break;
        case 'fill_blank':
          _isCorrect = _codeController.text.trim() == currentExercise.correctAnswer;
          break;
        case 'code_ordering':
          _isCorrect = _selectedOrder.join('') == currentExercise.correctAnswer;
          break;
      }
      
      if (_isCorrect) {
        _score += currentExercise.points;
      }
    });
  }

  void _nextExercise() {
    final exercises = _getExercises();
    
    setState(() {
      if (_currentExerciseIndex < exercises.length - 1) {
        _currentExerciseIndex++;
        _selectedAnswer = null;
        _hasAnswered = false;
        _codeController.clear();
        _selectedOrder.clear();
        _codeBlocks = List.from(exercises[_currentExerciseIndex].options);
        _codeBlocks.shuffle();
      } else {
        _showFinalResult();
      }
    });
  }

  void _showFinalResult() {
    final exercises = _getExercises();
    final totalPoints = exercises.fold(0, (sum, exercise) => sum + exercise.points);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Nível Concluído!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _score >= totalPoints / 2 ? Icons.emoji_events : Icons.sentiment_satisfied,
              color: _score >= totalPoints / 2 ? Colors.amber : Colors.blue,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Você marcou $_score de $totalPoints pontos!',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _score >= totalPoints / 2
                  ? 'Parabéns! Você desbloqueou o próximo nível!'
                  : 'Continue praticando para melhorar sua pontuação!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('CONTINUAR'),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoice(Exercise exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...exercise.options.map((option) {
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
            backgroundColor = AppTheme.primaryColor.withOpacity(0.1);
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
                          : AppTheme.primaryColor,
                    )
                  : Icon(
                      _hasAnswered && isCorrect
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: _hasAnswered && isCorrect ? Colors.green : Colors.grey,
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
      ],
    );
  }

  Widget _buildFillBlank(Exercise exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '#include <stdio.h>',
                style: TextStyle(color: Colors.green, fontFamily: 'Monospace'),
              ),
              const Text(
                'int main() {',
                style: TextStyle(color: Colors.white, fontFamily: 'Monospace'),
              ),
              Row(
                children: [
                  const Text(
                    '    ',
                    style: TextStyle(color: Colors.white, fontFamily: 'Monospace'),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      enabled: !_hasAnswered,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Monospace'),
                      decoration: const InputDecoration(
                        hintText: 'Digite o código aqui...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const Text(
                '    return 0;',
                style: TextStyle(color: Colors.white, fontFamily: 'Monospace'),
              ),
              const Text(
                '}',
                style: TextStyle(color: Colors.white, fontFamily: 'Monospace'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_hasAnswered)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isCorrect ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isCorrect ? Colors.green : Colors.red,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isCorrect ? Icons.check : Icons.close,
                  color: _isCorrect ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isCorrect 
                        ? 'Correto! A declaração está certa.'
                        : 'Resposta correta: ${exercise.correctAnswer}',
                    style: TextStyle(
                      color: _isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCodeOrdering(Exercise exercise) {
    if (_codeBlocks.isEmpty) {
      _codeBlocks = List.from(exercise.options);
      _codeBlocks.shuffle();
    }

    return Column(
      children: [
        // Área de blocos disponíveis
        Text(
          'Arraste os blocos para a área abaixo na ordem correta:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        
        // Blocos disponíveis
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _codeBlocks.map((block) {
            final isSelected = _selectedOrder.contains(block);
            return Draggable<String>(
              data: block,
              feedback: Material(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Text(block),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: isSelected ? 0.0 : 0.5,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Text(block),
                ),
              ),
              child: isSelected
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Text(
                        block,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Text(block),
                    ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 24),
        
        // Área de soltura
        Container(
          width: double.infinity,
          height: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey[400]!,
              style: BorderStyle.dashed,
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Text(block),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(block),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: _hasAnswered
                                ? null
                                : () {
                                    setState(() {
                                      _selectedOrder.remove(block);
                                    });
                                  },
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
        
        if (_hasAnswered)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isCorrect ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isCorrect ? Colors.green : Colors.red,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isCorrect ? Icons.check : Icons.close,
                  color: _isCorrect ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isCorrect 
                        ? 'Correto! A ordem está certa.'
                        : 'Ordem correta: ${exercise.correctAnswer}',
                    style: TextStyle(
                      color: _isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
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

  bool _isAnswerSelected() {
    final exercises = _getExercises();
    final currentExercise = exercises[_currentExerciseIndex];
    
    switch (currentExercise.type) {
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
    final exercises = _getExercises();
    
    if (exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Exercícios'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Nenhum exercício disponível para este nível.'),
        ),
      );
    }
    
    final currentExercise = exercises[_currentExerciseIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Nível ${widget.levelId} - Exercício ${_currentExerciseIndex + 1}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra de progresso
          LinearProgressIndicator(
            value: (_currentExerciseIndex + 1) / exercises.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          
          // Conteúdo do exercício
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentExercise.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentExercise.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      currentExercise.content,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Conteúdo interativo específico do tipo de exercício
                  _buildExerciseContent(currentExercise),
                ],
              ),
            ),
          ),
          
          // Barra inferior com botões
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
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
                Text(
                  'Pontuação: $_score',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: _hasAnswered
                      ? _nextExercise
                      : (_isAnswerSelected() ? _checkAnswer : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasAnswered ? Colors.green : AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(_hasAnswered ? 'PRÓXIMO' : 'VERIFICAR'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}