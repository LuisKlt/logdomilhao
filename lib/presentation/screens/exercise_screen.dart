import 'package:flutter/material.dart';
import 'package:logdomilhao/core/theme/app_theme.dart';
import 'package:logdomilhao/data/models/exercise_model.dart';
import 'package:logdomilhao/providers/exercise_provider.dart';
import 'package:logdomilhao/providers/gamification_provider.dart';
import 'package:provider/provider.dart';

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
  int _levelScore = 0; // Pontuação acumulada nesta sessão
  late TextEditingController _codeController;
  List<String> _codeBlocks = [];
  List<String> _selectedOrder = [];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    
    // Carregar exercícios do banco ao iniciar a tela
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
        // Salva no histórico global e soma pontos do usuário
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
    
    // Tenta desbloquear o próximo nível
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
              Navigator.of(context).pop(); // Fecha Dialog
              Navigator.of(context).pop(); // Volta para tela de níveis
            },
            child: const Text('VOLTAR AOS NÍVEIS'),
          ),
        ],
      ),
    );
  }

  // ... (Os métodos _buildMultipleChoice, _buildFillBlank, _buildCodeOrdering 
  // permanecem praticamente iguais aos que você enviou, apenas certifique-se 
  // de usar a variável `currentExercise` corretamente).
  
  // Vou simplificar a inclusão deles aqui para focar na lógica:
  
  Widget _buildExerciseContent(Exercise exercise) {
    // Lógica específica para code_ordering na primeira vez
    if (exercise.type == 'code_ordering' && _codeBlocks.isEmpty) {
       _codeBlocks = List.from(exercise.options);
       _codeBlocks.shuffle();
    }

    switch (exercise.type) {
      case 'fill_blank': return _buildFillBlank(exercise);
      case 'code_ordering': return _buildCodeOrdering(exercise);
      default: return _buildMultipleChoice(exercise);
    }
  }
  
  // (Copie os métodos _buildFillBlank, _buildCodeOrdering e _buildMultipleChoice do seu arquivo original para cá)
  // ...

  // Widgets auxiliares copiados do seu código original
  Widget _buildMultipleChoice(Exercise exercise) {
    return Column(
      children: exercise.options.map((option) {
        final isSelected = _selectedAnswer == option;
        final isCorrect = option == exercise.correctAnswer;
        Color? color = isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null;
        
        if (_hasAnswered) {
            if (isSelected && isCorrect) color = Colors.green[100];
            else if (isSelected && !isCorrect) color = Colors.red[100];
            else if (isCorrect) color = Colors.green[50];
        }

        return Card(
            color: color,
            child: ListTile(
                title: Text(option),
                leading: _hasAnswered && isCorrect ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: _hasAnswered ? null : () => setState(() => _selectedAnswer = option),
            ),
        );
      }).toList(),
    );
  }

  Widget _buildFillBlank(Exercise exercise) {
    return TextField(
      controller: _codeController,
      enabled: !_hasAnswered,
      // --- CORREÇÃO: Adicionar o onChanged para atualizar o botão ---
      onChanged: (value) {
        setState(() {});
      },
      // --------------------------------------------------------------
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Digite o código',
        hintText: 'Ex: int, String, print...', // Dica visual ajuda
        suffixIcon: _hasAnswered
            ? Icon(
                _isCorrect ? Icons.check : Icons.close,
                color: _isCorrect ? Colors.green : Colors.red,
              )
            : null,
      ),
    );
  }

  Widget _buildCodeOrdering(Exercise exercise) {
     // Implementação simples para evitar erros, use a sua completa
     return Column(children: [
         const Text("Ordene os blocos (Implementação simplificada)"),
         ..._codeBlocks.map((b) => Chip(label: Text(b))).toList(),
         if(!_hasAnswered) 
            ElevatedButton(
                onPressed: () => setState(() { _selectedOrder = List.from(_codeBlocks); }), // Simula ordenação
                child: const Text("Usar esta ordem")
            )
     ]);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nível ${widget.levelId}'),
        backgroundColor: AppTheme.primaryColor,
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
              LinearProgressIndicator(
                value: (_currentExerciseIndex + 1) / exercises.length,
                color: AppTheme.primaryColor,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentExercise.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(currentExercise.description),
                      const SizedBox(height: 16),
                      Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.grey[200],
                          child: Text(currentExercise.content, style: const TextStyle(fontFamily: 'monospace'))
                      ),
                      const SizedBox(height: 24),
                      _buildExerciseContent(currentExercise),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _hasAnswered 
                        ? () => _nextExercise(exercises)
                        : (_selectedAnswer != null || _codeController.text.isNotEmpty || _selectedOrder.isNotEmpty 
                            ? () => _checkAnswer(exercises) 
                            : null),
                    child: Text(_hasAnswered ? ( _currentExerciseIndex == exercises.length -1 ? 'FINALIZAR' : 'PRÓXIMO') : 'VERIFICAR'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}