import 'package:flutter/material.dart';
import 'package:logdomilhao/data/database/database_helper.dart';
import 'package:logdomilhao/core/theme/app_theme.dart';
import 'package:logdomilhao/data/models/level_model.dart';
import 'package:logdomilhao/presentation/screens/exercise_screen.dart';
import 'package:logdomilhao/presentation/widgets/level_card.dart';
import 'package:provider/provider.dart';
import 'package:logdomilhao/providers/exercise_provider.dart';
import 'package:sqflite/sqflite.dart'; // Necessário para deletar o banco
import 'package:path/path.dart';      // Necessário para o caminho do banco

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  List<Level> _levels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    setState(() => _isLoading = true);
    try {
      final dbHelper = DatabaseHelper();
      final levelsData = await dbHelper.query('levels');
      
      final levels = levelsData.map((e) => Level.fromMap(e)).toList();
      levels.sort((a, b) => a.order.compareTo(b.order));

      if (mounted) {
        setState(() {
          _levels = levels;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erro ao carregar níveis: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Função auxiliar para resetar o banco durante o desenvolvimento
  // Adicione "BuildContext context" dentro dos parênteses
Future<void> _resetDatabase(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    
    // Mostra loading
    setState(() => _isLoading = true);

    try {
      // 1. FECHA a conexão atual corretamente
      await DatabaseHelper().closeConnection();

      // 2. Deleta o arquivo físico
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'logdomilhao.db');
      await deleteDatabase(path);

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(content: Text('Banco resetado! Recriando dados...')),
      );

      // 3. CHAMA _loadLevels IMEDIATAMENTE
      // Isso vai acessar DatabaseHelper().database, que vai ver que está null,
      // vai chamar _initDB -> _createDB -> _insertInitialData e popular tudo.
      await _loadLevels();

    } catch (e) {
      print("Erro ao resetar: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        messenger.showSnackBar(
          SnackBar(content: Text('Erro ao resetar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Níveis de Aprendizado'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Botão de DEBUG para resetar banco
          IconButton(
  icon: const Icon(Icons.refresh),
  tooltip: 'Resetar Banco (Debug)',
  // MUDANÇA AQUI: Use uma arrow function para passar o context
  onPressed: () => _resetDatabase(context), 
)
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _levels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum nível encontrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tente desinstalar e instalar o app\npara recriar o banco de dados.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadLevels,
                        child: const Text('Tentar Recarregar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLevels,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _levels.length,
                    itemBuilder: (context, index) {
                      final level = _levels[index];
                      return LevelCard(
                        level: level,
                        onTap: () async {
                          if (!level.isLocked) {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChangeNotifierProvider(
                                  create: (_) => ExerciseProvider(),
                                  child: ExerciseScreen(levelId: level.id!),
                                ),
                              ),
                            );
                            _loadLevels();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Complete o nível anterior para desbloquear este!'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}