import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logdomilhao/data/models/score_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('logdomilhao.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        totalPoints INTEGER NOT NULL DEFAULT 0,
        currentLevel INTEGER NOT NULL DEFAULT 1,
        language TEXT NOT NULL DEFAULT 'pt'
      )
    ''');

    await db.execute('''
      CREATE TABLE levels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        order_num INTEGER NOT NULL,
        isLocked INTEGER NOT NULL DEFAULT 1,
        requiredPoints INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        levelId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        content TEXT NOT NULL,
        correctAnswer TEXT NOT NULL,
        options TEXT NOT NULL,
        points INTEGER NOT NULL DEFAULT 10,
        FOREIGN KEY (levelId) REFERENCES levels (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        exerciseId INTEGER NOT NULL,
        points INTEGER NOT NULL,
        isCorrect INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // 1. Usuário Padrão
    await db.insert('users', {
      'username': 'Estudante',
      'totalPoints': 0,
      'currentLevel': 1,
      'language': 'pt'
    });

    // ===============================================
    // 2. INSERIR TODOS OS 15 NÍVEIS
    // ===============================================

    // Nível 1: Estrutura Básica
    await db.insert('levels', {
      'title': 'Estrutura Básica',
      'description': 'Esqueleto de um programa C: includes, main, sintaxe',
      'category': 'fundamentos',
      'order_num': 1,
      'isLocked': 0,
      'requiredPoints': 0
    });

    // Nível 2: Tipos de Dados Primitivos
    await db.insert('levels', {
      'title': 'Tipos Primitivos',
      'description': 'int, float, double, char: declaração e uso',
      'category': 'variaveis',
      'order_num': 2,
      'isLocked': 1,
      'requiredPoints': 50
    });

    // Nível 3: Constantes e Modificadores
    await db.insert('levels', {
      'title': 'Constantes e Modificadores',
      'description': '#define, const, unsigned, short, long',
      'category': 'variaveis',
      'order_num': 3,
      'isLocked': 1,
      'requiredPoints': 100
    });

    // Nível 4: Operadores Aritméticos
    await db.insert('levels', {
      'title': 'Operadores Aritméticos',
      'description': '+ - * / % ++ -- e precedência',
      'category': 'operadores',
      'order_num': 4,
      'isLocked': 1,
      'requiredPoints': 150
    });

    // Nível 5: Operadores Relacionais
    await db.insert('levels', {
      'title': 'Operadores Relacionais',
      'description': '== != > < >= <= comparando valores',
      'category': 'operadores',
      'order_num': 5,
      'isLocked': 1,
      'requiredPoints': 200
    });

    // Nível 6: Operadores Lógicos
    await db.insert('levels', {
      'title': 'Operadores Lógicos',
      'description': '&& || ! combinando condições',
      'category': 'operadores',
      'order_num': 6,
      'isLocked': 1,
      'requiredPoints': 250
    });

    // Nível 7: Saída com printf
    await db.insert('levels', {
      'title': 'Saída: Função printf',
      'description': 'Formatação de saída com %d, %f, %c, %s',
      'category': 'io',
      'order_num': 7,
      'isLocked': 1,
      'requiredPoints': 300
    });

    // Nível 8: Entrada com scanf
    await db.insert('levels', {
      'title': 'Entrada: Função scanf',
      'description': 'Leitura de dados do teclado com formatação',
      'category': 'io',
      'order_num': 8,
      'isLocked': 1,
      'requiredPoints': 350
    });

    // Nível 9: Condicional if-else
    await db.insert('levels', {
      'title': 'Condicional if-else',
      'description': 'Tomada de decisão simples e encadeada',
      'category': 'controle',
      'order_num': 9,
      'isLocked': 1,
      'requiredPoints': 400
    });

    // Nível 10: Condicional switch-case
    await db.insert('levels', {
      'title': 'Condicional switch-case',
      'description': 'Seleção múltipla com break e default',
      'category': 'controle',
      'order_num': 10,
      'isLocked': 1,
      'requiredPoints': 450
    });

    // Nível 11: Laço for
    await db.insert('levels', {
      'title': 'Laço for',
      'description': 'Repetição controlada por contador',
      'category': 'loops',
      'order_num': 11,
      'isLocked': 1,
      'requiredPoints': 500
    });

    // Nível 12: Laço while
    await db.insert('levels', {
      'title': 'Laço while',
      'description': 'Repetição com condição no início',
      'category': 'loops',
      'order_num': 12,
      'isLocked': 1,
      'requiredPoints': 550
    });

    // Nível 13: Laço do-while
    await db.insert('levels', {
      'title': 'Laço do-while',
      'description': 'Repetição com condição no final',
      'category': 'loops',
      'order_num': 13,
      'isLocked': 1,
      'requiredPoints': 600
    });

    // Nível 14: Funções Simples
    await db.insert('levels', {
      'title': 'Funções Simples',
      'description': 'Declaração, definição e chamada básica',
      'category': 'funcoes',
      'order_num': 14,
      'isLocked': 1,
      'requiredPoints': 650
    });

    // Nível 15: Funções com Parâmetros
    await db.insert('levels', {
      'title': 'Funções com Parâmetros',
      'description': 'Passagem de valores e tipos de retorno',
      'category': 'funcoes',
      'order_num': 15,
      'isLocked': 1,
      'requiredPoints': 700
    });

    // ===============================================
    // 3. INSERIR TODOS OS 150 EXERCÍCIOS
    // ===============================================

    // === NÍVEL 1: ESTRUTURA BÁSICA ===
    await _insertLevel1Exercises(db);

    // === NÍVEL 2: TIPOS DE DADOS PRIMITIVOS ===
    await _insertLevel2Exercises(db);

    // === NÍVEL 3: CONSTANTES E MODIFICADORES ===
    await _insertLevel3Exercises(db);

    // === NÍVEL 4: OPERADORES ARITMÉTICOS ===
    await _insertLevel4Exercises(db);

    // === NÍVEL 5: OPERADORES RELACIONAIS ===
    await _insertLevel5Exercises(db);

    // === NÍVEL 6: OPERADORES LÓGICOS ===
    await _insertLevel6Exercises(db);

    // === NÍVEL 7: SAÍDA COM PRINTF ===
    await _insertLevel7Exercises(db);

    // === NÍVEL 8: ENTRADA COM SCANF ===
    await _insertLevel8Exercises(db);

    // === NÍVEL 9: CONDICIONAL IF-ELSE ===
    await _insertLevel9Exercises(db);

    // === NÍVEL 10: CONDICIONAL SWITCH-CASE ===
    await _insertLevel10Exercises(db);

    // === NÍVEL 11: LAÇO FOR ===
    await _insertLevel11Exercises(db);

    // === NÍVEL 12: LAÇO WHILE ===
    await _insertLevel12Exercises(db);

    // === NÍVEL 13: LAÇO DO-WHILE ===
    await _insertLevel13Exercises(db);

    // === NÍVEL 14: FUNÇÕES SIMPLES ===
    await _insertLevel14Exercises(db);

    // === NÍVEL 15: FUNÇÕES COM PARÂMETROS ===
    await _insertLevel15Exercises(db);
  }

  // ===============================================
  // FUNÇÕES PARA INSERIR EXERCÍCIOS DE CADA NÍVEL
  // ===============================================

  Future<void> _insertLevel1Exercises(Database db) async {
    // Ex 1.1
    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Programa Mínimo',
      'description': 'Identifique o programa C mais simples possível',
      'type': 'multiple_choice',
      'content': 'Qual destes é um programa C válido?',
      'correctAnswer': '#include <stdio.h>\nint main() {\n  return 0;\n}',
      'options':
          '#include <stdio.h>\nint main() {\n  return 0;\n}|int main() {\n  return 0;\n}|main() {\n  return 0;\n}|program inicio\n  retorne 0\nfim',
      'points': 10
    });

    // Ex 1.2
    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Função Principal',
      'description': 'Entenda a função main',
      'type': 'fill_blank',
      'content': 'Complete a assinatura da função principal: ___ main()',
      'correctAnswer': 'int',
      'options': '',
      'points': 10
    });

    // Ex 1.3
    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Incluindo stdio',
      'description': 'Adicione a biblioteca padrão de entrada/saída',
      'type': 'code_ordering',
      'content': 'Ordene para incluir a biblioteca stdio.h',
      'correctAnswer': '#include <stdio.h>',
      'options': '#include|<stdio.h>',
      'points': 10
    });

    // Ex 1.4
    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Comentário de Linha',
      'description': 'Adicione um comentário de uma linha',
      'type': 'multiple_choice',
      'content': 'Como fazer um comentário de uma linha em C?',
      'correctAnswer': '// Comentário aqui',
      'options':
          '// Comentário aqui|/* Comentário aqui */|# Comentário aqui|-- Comentário aqui',
      'points': 10
    });

    // Ex 1.5
    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Comentário de Bloco',
      'description': 'Faça um comentário de múltiplas linhas',
      'type': 'fill_blank',
      'content':
          'Complete para comentar várias linhas:\n/*\n  Programa: Hello World\n  Autor: Você\n___',
      'correctAnswer': '*/',
      'options': '',
      'points': 10
    });

    // Ex 1.6
    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Ponto e Vírgula',
      'description': 'Entenda onde colocar ;',
      'type': 'multiple_choice',
      'content': 'Onde o ponto e vírgula é OBRIGATÓRIO?',
      'correctAnswer': 'Após cada instrução',
      'options':
          'Após cada linha|Após cada instrução|Após cada função|No final do arquivo',
      'points': 10
    });

    // Ex 1.7
    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Delimitadores de Bloco',
      'description': 'Use chaves para delimitar o corpo da função',
      'type': 'code_ordering',
      'content': 'Ordene a estrutura do main com chaves',
      'correctAnswer': 'int main() {\n  // código aqui\n}',
      'options': 'int main()|{\n  // código aqui\n}',
      'points': 10
    });

    // Ex 1.8
    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Retorno da Função',
      'description': 'Entenda o significado de return 0',
      'type': 'multiple_choice',
      'content': 'O que significa "return 0" no final do main?',
      'correctAnswer': 'Programa executou com sucesso',
      'options':
          'Programa falhou|Programa executou com sucesso|Retorna o valor 0|Termina o programa',
      'points': 10
    });

    // Ex 1.9
    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Programa Completo',
      'description': 'Monte um programa C completo',
      'type': 'code_ordering',
      'content': 'Ordene um programa que imprime "Olá"',
      'correctAnswer':
          '#include <stdio.h>\nint main() {\n  printf("Olá");\n  return 0;\n}',
      'options':
          '#include <stdio.h>|int main()|{\n  printf("Olá");|\n  return 0;\n}',
      'points': 15
    });

    // Ex 1.10
    await db.insert('exercises', {
      'levelId': 1,
      'title': 'Identificando Erro',
      'description': 'Encontre o erro na estrutura',
      'type': 'multiple_choice',
      'content':
          'Qual o erro neste código?\n#include <stdio.h>\nmain() {\n  printf("Teste")\n  return 0;\n}',
      'correctAnswer': 'Falta ponto e vírgula após printf',
      'options':
          'Falta #include|main deveria ser int main|Falta ponto e vírgula após printf|Falta chave de fechamento',
      'points': 10
    });
  }

  Future<void> _insertLevel2Exercises(Database db) async {
    // Ex 2.1
    await db.insert('exercises', {
      'levelId': 2,
      'title': 'Declaração de Inteiro',
      'description': 'Declare uma variável inteira',
      'type': 'multiple_choice',
      'content': 'Como declarar uma variável inteira chamada "idade"?',
      'correctAnswer': 'int idade;',
      'options': 'integer idade;|int idade;|var idade;|idade int;',
      'points': 10
    });

    // Ex 2.2
    await db.insert('exercises', {
      'levelId': 2,
      'title': 'Declaração de Float',
      'description': 'Declare um número decimal',
      'type': 'fill_blank',
      'content':
          'Complete para declarar um float chamado "altura":\n___ altura;',
      'correctAnswer': 'float',
      'options': '',
      'points': 10
    });

    // Ex 2.3
    await db.insert('exercises', {
      'levelId': 2,
      'title': 'Declaração de Char',
      'description': 'Declare uma variável caractere',
      'type': 'code_ordering',
      'content': 'Ordene para declarar um char chamado "letra"',
      'correctAnswer': 'char letra;',
      'options': 'char|letra;',
      'points': 10
    });

    // Ex 2.4
    await db.insert('exercises', {
      'levelId': 2,
      'title': 'Declaração com Inicialização',
      'description': 'Declare e inicialize em uma linha',
      'type': 'multiple_choice',
      'content': 'Como declarar e inicializar um int com valor 10?',
      'correctAnswer': 'int x = 10;',
      'options': 'int x = 10;|int x := 10;|x int = 10;|int 10 = x;',
      'points': 10
    });

    // Ex 2.5
    await db.insert('exercises', {
      'levelId': 2,
      'title': 'Declaração Múltipla',
      'description': 'Declare várias variáveis de uma vez',
      'type': 'fill_blank',
      'content': 'Complete para declarar dois ints: a e b:\nint a, ___;',
      'correctAnswer': 'b',
      'options': '',
      'points': 10
    });

    // Ex 2.6
    await db.insert('exercises', {
      'levelId': 2,
      'title': 'Valor de Char',
      'description': 'Atribua um valor a um char',
      'type': 'multiple_choice',
      'content': 'Como atribuir a letra "A" a um char?',
      'correctAnswer': 'letra = \'A\';',
      'options': 'letra = "A";|letra = \'A\';|letra = A;|letra = char("A");',
      'points': 10
    });

    // Ex 2.7
    await db.insert('exercises', {
      'levelId': 2,
      'title': 'Tipo Double',
      'description': 'Diferença entre float e double',
      'type': 'code_ordering',
      'content':
          'Ordene para declarar um double chamado "pi" com valor 3.14159',
      'correctAnswer': 'double pi = 3.14159;',
      'options': 'double|pi|=|3.14159;',
      'points': 10
    });

    // Ex 2.8
    await db.insert('exercises', {
      'levelId': 2,
      'title': 'Tamanho dos Tipos',
      'description': 'Conheça o espaço ocupado por cada tipo',
      'type': 'multiple_choice',
      'content': 'Qual tipo geralmente ocupa 1 byte?',
      'correctAnswer': 'char',
      'options': 'int|float|char|double',
      'points': 10
    });

    // Ex 2.9
    await db.insert('exercises', {
      'levelId': 2,
      'title': 'Programa com Variáveis',
      'description': 'Crie um programa com múltiplas declarações',
      'type': 'code_ordering',
      'content': 'Ordene um programa com int idade=20 e float altura=1.75',
      'correctAnswer':
          '#include <stdio.h>\nint main() {\n  int idade = 20;\n  float altura = 1.75;\n  return 0;\n}',
      'options':
          '#include <stdio.h>|int main()|{\n  int idade = 20;|\n  float altura = 1.75;|\n  return 0;\n}',
      'points': 15
    });

    // Ex 2.10
    await db.insert('exercises', {
      'levelId': 2,
      'title': 'Corrigindo Erro de Tipo',
      'description': 'Identifique atribuição incorreta',
      'type': 'multiple_choice',
      'content': 'Qual o erro?\nint numero = 3.14;',
      'correctAnswer': 'Atribuição de float para int sem cast',
      'options':
          'Falta ponto e vírgula|3.14 não é número válido|Atribuição de float para int sem cast|int não pode ter valor decimal',
      'points': 10
    });
  }

  Future<void> _insertLevel3Exercises(Database db) async {
    // Ex 3.1: #define
    await db.insert('exercises', {
      'levelId': 3,
      'title': 'Constante #define',
      'description': 'Use #define para criar constantes',
      'type': 'multiple_choice',
      'content': 'Como definir uma constante PI com valor 3.14159?',
      'correctAnswer': '#define PI 3.14159',
      'options':
          '#define PI 3.14159|const PI = 3.14159;|PI = 3.14159;|define PI 3.14159',
      'points': 15
    });

    // Ex 3.2: const keyword
    await db.insert('exercises', {
      'levelId': 3,
      'title': 'Palavra-chave const',
      'description': 'Use const para variáveis constantes',
      'type': 'fill_blank',
      'content':
          'Complete para criar uma constante inteira:\n___ int MAX = 100;',
      'correctAnswer': 'const',
      'options': '',
      'points': 15
    });

    // Ex 3.3: unsigned int
    await db.insert('exercises', {
      'levelId': 3,
      'title': 'Inteiro sem Sinal',
      'description': 'Declare um inteiro apenas positivo',
      'type': 'code_ordering',
      'content': 'Ordene para declarar um unsigned int chamado "contador"',
      'correctAnswer': 'unsigned int contador;',
      'options': 'unsigned|int|contador;',
      'points': 15
    });

    // Ex 3.4: short vs long
    await db.insert('exercises', {
      'levelId': 3,
      'title': 'Short e Long',
      'description': 'Diferença entre short int e long int',
      'type': 'multiple_choice',
      'content': 'Qual ocupa menos espaço na memória?',
      'correctAnswer': 'short int',
      'options': 'short int|long int|int|unsigned int',
      'points': 15
    });

    // Ex 3.5: long double
    await db.insert('exercises', {
      'levelId': 3,
      'title': 'Double Longo',
      'description': 'Declare um número decimal de alta precisão',
      'type': 'fill_blank',
      'content': 'Complete: ___ double pi = 3.141592653589793;',
      'correctAnswer': 'long',
      'options': '',
      'points': 15
    });

    // Ex 3.6: signed char
    await db.insert('exercises', {
      'levelId': 3,
      'title': 'Char com Sinal',
      'description': 'Char pode ser signed ou unsigned',
      'type': 'multiple_choice',
      'content': 'Por padrão, char é:',
      'correctAnswer': 'Depende da implementação',
      'options':
          'signed|unsigned|Depende da implementação|Nenhuma das anteriores',
      'points': 15
    });

    // Ex 3.7: const com array
    await db.insert('exercises', {
      'levelId': 3,
      'title': 'Array Constante',
      'description': 'Crie um array que não pode ser modificado',
      'type': 'code_ordering',
      'content': 'Ordene para criar um array constante de inteiros',
      'correctAnswer': 'const int dias[7] = {1, 2, 3, 4, 5, 6, 7};',
      'options': 'const|int|dias[7]|=|{1, 2, 3, 4, 5, 6, 7};',
      'points': 20
    });

    // Ex 3.8: volatile
    await db.insert('exercises', {
      'levelId': 3,
      'title': 'Modificador volatile',
      'description': 'Use volatile para variáveis que podem mudar externamente',
      'type': 'multiple_choice',
      'content': 'Quando usar volatile?',
      'correctAnswer': 'Variáveis modificadas por hardware ou interrupções',
      'options':
          'Variáveis constantes|Variáveis modificadas por hardware ou interrupções|Variáveis locais|Variáveis globais',
      'points': 15
    });

    // Ex 3.9: static local
    await db.insert('exercises', {
      'levelId': 3,
      'title': 'Variável Static Local',
      'description': 'Mantenha valor entre chamadas de função',
      'type': 'fill_blank',
      'content':
          'Complete para criar uma variável static:\n___ int contador = 0;',
      'correctAnswer': 'static',
      'options': '',
      'points': 15
    });

    // Ex 3.10: Múltiplos modificadores
    await db.insert('exercises', {
      'levelId': 3,
      'title': 'Combinando Modificadores',
      'description': 'Combine const, unsigned e long',
      'type': 'code_ordering',
      'content': 'Ordene para declarar uma constante longa sem sinal',
      'correctAnswer': 'const unsigned long int MAX_SIZE = 4294967295;',
      'options': 'const|unsigned|long|int|MAX_SIZE|=|4294967295;',
      'points': 20
    });
  }

  Future<void> _insertLevel4Exercises(Database db) async {
    // Ex 4.1: Adição
    await db.insert('exercises', {
      'levelId': 4,
      'title': 'Operador de Adição',
      'description': 'Some dois números inteiros',
      'type': 'multiple_choice',
      'content': 'Como somar 5 + 3 em C?',
      'correctAnswer': '5 + 3',
      'options': '5 + 3|5 plus 3|5 add 3|5 & 3',
      'points': 15
    });

    // Ex 4.2: Subtração
    await db.insert('exercises', {
      'levelId': 4,
      'title': 'Operador de Subtração',
      'description': 'Subtraia dois números',
      'type': 'fill_blank',
      'content': 'Complete: int resultado = 10 ___ 4; // resultado = 6',
      'correctAnswer': '-',
      'options': '',
      'points': 15
    });

    // Ex 4.3: Multiplicação
    await db.insert('exercises', {
      'levelId': 4,
      'title': 'Operador de Multiplicação',
      'description': 'Multiplique dois valores',
      'type': 'code_ordering',
      'content': 'Ordene para calcular área = comprimento * largura',
      'correctAnswer': 'area = comprimento * largura;',
      'options': 'area|=|comprimento|*|largura;',
      'points': 15
    });

    // Ex 4.4: Divisão inteira
    await db.insert('exercises', {
      'levelId': 4,
      'title': 'Divisão Inteira',
      'description': 'Divisão entre inteiros resulta em inteiro',
      'type': 'multiple_choice',
      'content': 'Qual o resultado de 7 / 2 em C (com ints)?',
      'correctAnswer': '3',
      'options': '3.5|3|4|3.0',
      'points': 15
    });

    // Ex 4.5: Módulo
    await db.insert('exercises', {
      'levelId': 4,
      'title': 'Operador Módulo',
      'description': 'Obtenha o resto da divisão',
      'type': 'fill_blank',
      'content': 'Complete para obter resto de 10 ÷ 3:\nint resto = 10 ___ 3;',
      'correctAnswer': '%',
      'options': '',
      'points': 15
    });

    // Ex 4.6: Incremento
    await db.insert('exercises', {
      'levelId': 4,
      'title': 'Operador de Incremento',
      'description': 'Aumente uma variável em 1',
      'type': 'multiple_choice',
      'content': 'Como incrementar x em 1?',
      'correctAnswer': 'x++ ou ++x',
      'options': 'x++ ou ++x|x += 1|x = x + 1|Todas as anteriores',
      'points': 15
    });

    // Ex 4.7: Decremento
    await db.insert('exercises', {
      'levelId': 4,
      'title': 'Operador de Decremento',
      'description': 'Diminua uma variável em 1',
      'type': 'code_ordering',
      'content': 'Ordene para decrementar y depois de usar seu valor',
      'correctAnswer': 'int resultado = y--;',
      'options': 'int|resultado|=|y--;',
      'points': 15
    });

    // Ex 4.8: Precedência
    await db.insert('exercises', {
      'levelId': 4,
      'title': 'Precedência de Operadores',
      'description': 'Ordem de avaliação das operações',
      'type': 'multiple_choice',
      'content': 'Qual operador tem MAIOR precedência?',
      'correctAnswer': '*',
      'options': '+|-|*|/',
      'points': 15
    });

    // Ex 4.9: Expressão complexa
    await db.insert('exercises', {
      'levelId': 4,
      'title': 'Expressão Aritmética',
      'description': 'Combine múltiplos operadores',
      'type': 'fill_blank',
      'content': 'Complete: int x = (10 + 5) ___ 3; // x = 5',
      'correctAnswer': '/',
      'options': '',
      'points': 15
    });

    // Ex 4.10: Operador composto
    await db.insert('exercises', {
      'levelId': 4,
      'title': 'Operadores Compostos',
      'description': 'Use += para adicionar a uma variável',
      'type': 'code_ordering',
      'content': 'Ordene para adicionar 5 a soma usando operador composto',
      'correctAnswer': 'soma += 5;',
      'options': 'soma|+=|5;',
      'points': 15
    });
  }

  Future<void> _insertLevel5Exercises(Database db) async {
    // Ex 5.1: Igualdade
    await db.insert('exercises', {
      'levelId': 5,
      'title': 'Operador de Igualdade',
      'description': 'Compare se dois valores são iguais',
      'type': 'multiple_choice',
      'content': 'Como verificar se a é igual a b?',
      'correctAnswer': 'a == b',
      'options': 'a = b|a == b|a equals b|a === b',
      'points': 15
    });

    // Ex 5.2: Diferença
    await db.insert('exercises', {
      'levelId': 5,
      'title': 'Operador de Diferença',
      'description': 'Verifique se valores são diferentes',
      'type': 'fill_blank',
      'content': 'Complete: if (x ___ y) { /* x é diferente de y */ }',
      'correctAnswer': '!=',
      'options': '',
      'points': 15
    });

    // Ex 5.3: Maior que
    await db.insert('exercises', {
      'levelId': 5,
      'title': 'Maior Que',
      'description': 'Verifique se um valor é maior que outro',
      'type': 'code_ordering',
      'content': 'Ordene para verificar se idade é maior que 18',
      'correctAnswer': 'if (idade > 18)',
      'options': 'if|(idade|>|18)',
      'points': 15
    });

    // Ex 5.4: Menor que
    await db.insert('exercises', {
      'levelId': 5,
      'title': 'Menor Que',
      'description': 'Verifique se um valor é menor que outro',
      'type': 'multiple_choice',
      'content': 'Como verificar se x é menor que 10?',
      'correctAnswer': 'x < 10',
      'options': 'x < 10|x > 10|x <= 10|x == 10',
      'points': 15
    });

    // Ex 5.5: Maior ou igual
    await db.insert('exercises', {
      'levelId': 5,
      'title': 'Maior ou Igual',
      'description': 'Verifique se um valor é maior ou igual a outro',
      'type': 'fill_blank',
      'content': 'Complete: if (nota ___ 7.0) { /* aprovado */ }',
      'correctAnswer': '>=',
      'options': '',
      'points': 15
    });

    // Ex 5.6: Menor ou igual
    await db.insert('exercises', {
      'levelId': 5,
      'title': 'Menor ou Igual',
      'description': 'Verifique se um valor é menor ou igual a outro',
      'type': 'multiple_choice',
      'content': 'Como verificar se idade é menor ou igual a 12?',
      'correctAnswer': 'idade <= 12',
      'options': 'idade < 12|idade <= 12|idade > 12|idade == 12',
      'points': 15
    });

    // Ex 5.7: Comparação de char
    await db.insert('exercises', {
      'levelId': 5,
      'title': 'Comparando Caracteres',
      'description': 'Chars podem ser comparados com operadores relacionais',
      'type': 'code_ordering',
      'content': 'Ordene para verificar se letra é maior que "M"',
      'correctAnswer': 'if (letra > \'M\')',
      'options': 'if|(letra|>|\'M\')',
      'points': 15
    });

    // Ex 5.8: Resultado booleano
    await db.insert('exercises', {
      'levelId': 5,
      'title': 'Resultado da Comparação',
      'description': 'Operadores relacionais retornam 0 ou 1',
      'type': 'multiple_choice',
      'content': 'O que retorna a expressão 5 > 3?',
      'correctAnswer': '1',
      'options': '0|1|5|3',
      'points': 15
    });

    // Ex 5.9: Comparação float
    await db.insert('exercises', {
      'levelId': 5,
      'title': 'Comparando Floats',
      'description': 'Cuidado ao comparar números decimais',
      'type': 'fill_blank',
      'content': 'Complete com cuidado: if (fabs(x - y) ___ 0.0001)',
      'correctAnswer': '<',
      'options': '',
      'points': 15
    });

    // Ex 5.10: Expressão relacional
    await db.insert('exercises', {
      'levelId': 5,
      'title': 'Expressão Relacional Complexa',
      'description': 'Combine múltiplas comparações',
      'type': 'code_ordering',
      'content': 'Ordene para verificar se x está entre 1 e 10',
      'correctAnswer': 'if (x >= 1 && x <= 10)',
      'options': 'if|(x|>=|1|&&|x|<=|10)',
      'points': 20
    });
  }

  Future<void> _insertLevel6Exercises(Database db) async {
    // Ex 6.1: AND lógico
    await db.insert('exercises', {
      'levelId': 6,
      'title': 'AND Lógico',
      'description': 'Verifique se duas condições são verdadeiras',
      'type': 'multiple_choice',
      'content': 'Como verificar se A E B são verdadeiros?',
      'correctAnswer': 'A && B',
      'options': 'A & B|A && B|A AND B|A || B',
      'points': 15
    });

    // Ex 6.2: OR lógico
    await db.insert('exercises', {
      'levelId': 6,
      'title': 'OR Lógico',
      'description': 'Verifique se pelo menos uma condição é verdadeira',
      'type': 'fill_blank',
      'content': 'Complete: if (chovendo ___ fazendo_sol)',
      'correctAnswer': '||',
      'options': '',
      'points': 15
    });

    // Ex 6.3: NOT lógico
    await db.insert('exercises', {
      'levelId': 6,
      'title': 'NOT Lógico',
      'description': 'Inverta o valor de uma condição',
      'type': 'code_ordering',
      'content': 'Ordene para verificar se NÃO está chovendo',
      'correctAnswer': 'if (!chovendo)',
      'options': 'if|(!chovendo)',
      'points': 15
    });

    // Ex 6.4: Precedência lógica
    await db.insert('exercises', {
      'levelId': 6,
      'title': 'Precedência Lógica',
      'description': 'NOT tem maior precedência que AND e OR',
      'type': 'multiple_choice',
      'content': 'Qual tem maior precedência?',
      'correctAnswer': '!',
      'options': '&&||!|==',
      'points': 15
    });

    // Ex 6.5: Combinação AND-OR
    await db.insert('exercises', {
      'levelId': 6,
      'title': 'Combinação AND e OR',
      'description': 'Combine operadores lógicos',
      'type': 'fill_blank',
      'content': 'Complete: if (idade >= 18 ___ idade <= 65 ___ estudante)',
      'correctAnswer': '&&',
      'options': '',
      'points': 15
    });

    // Ex 6.6: Short-circuit
    await db.insert('exercises', {
      'levelId': 6,
      'title': 'Short-Circuit Evaluation',
      'description':
          'AND para se primeira for falsa, OR para se primeira for verdadeira',
      'type': 'multiple_choice',
      'content': 'Em (x != 0 && y/x > 2), o que acontece se x for 0?',
      'correctAnswer': 'Segunda parte não é avaliada',
      'options':
          'Divisão por zero|Segunda parte não é avaliada|Resultado é 0|Erro de compilação',
      'points': 15
    });

    // Ex 6.7: Expressão lógica completa
    await db.insert('exercises', {
      'levelId': 6,
      'title': 'Expressão Lógica Completa',
      'description': 'Monte uma condição complexa',
      'type': 'code_ordering',
      'content': 'Ordene: if idade >= 18 && (carteira || acompanhado)',
      'correctAnswer': 'if (idade >= 18 && (carteira || acompanhado))',
      'options': 'if|(idade|>=|18|&&|(carteira|||acompanhado))',
      'points': 20
    });

    // Ex 6.8: Operador ternário
    await db.insert('exercises', {
      'levelId': 6,
      'title': 'Operador Ternário',
      'description': 'If-else em uma linha',
      'type': 'multiple_choice',
      'content': 'Como escrever "se x>0 então y=1 senão y=0"?',
      'correctAnswer': 'y = (x > 0) ? 1 : 0;',
      'options':
          'y = if x>0 then 1 else 0;|y = (x > 0) ? 1 : 0;|y = x>0 ? 1 : 0;|y = (x > 0) : 1 ? 0;',
      'points': 15
    });

    // Ex 6.9: NOT com expressão
    await db.insert('exercises', {
      'levelId': 6,
      'title': 'Negação Completa',
      'description': 'Negue uma expressão composta',
      'type': 'fill_blank',
      'content': 'Complete: if (___ (x < 0 || x > 100))',
      'correctAnswer': '!',
      'options': '',
      'points': 15
    });

    // Ex 6.10: De Morgan
    await db.insert('exercises', {
      'levelId': 6,
      'title': 'Leis de De Morgan',
      'description': '!(A && B) = !A || !B',
      'type': 'code_ordering',
      'content': 'Ordene a negação de (idade>=18 && tem_carteira)',
      'correctAnswer': '!(idade >= 18 && tem_carteira)',
      'options': '!|(idade|>=|18|&&|tem_carteira)',
      'points': 20
    });
  }

  Future<void> _insertLevel7Exercises(Database db) async {
    // Ex 7.1: printf básico
    await db.insert('exercises', {
      'levelId': 7,
      'title': 'printf Simples',
      'description': 'Imprima uma mensagem simples',
      'type': 'multiple_choice',
      'content': 'Como imprimir "Hello World"?',
      'correctAnswer': 'printf("Hello World");',
      'options':
          'print("Hello World");|printf("Hello World");|cout << "Hello World";|echo "Hello World"',
      'points': 15
    });

    // Ex 7.2: printf com inteiro
    await db.insert('exercises', {
      'levelId': 7,
      'title': 'printf com Inteiro',
      'description': 'Imprima um valor inteiro',
      'type': 'fill_blank',
      'content': 'Complete: printf("Idade: %d", ___);',
      'correctAnswer': 'idade',
      'options': '',
      'points': 15
    });

    // Ex 7.3: printf com float
    await db.insert('exercises', {
      'levelId': 7,
      'title': 'printf com Float',
      'description': 'Imprima um número decimal',
      'type': 'code_ordering',
      'content': 'Ordene: printf("Preço: %.2f", preco);',
      'correctAnswer': 'printf("Preço: %.2f", preco);',
      'options': 'printf|("Preço: %.2f"|, preco);',
      'points': 15
    });

    // Ex 7.4: %s para string
    await db.insert('exercises', {
      'levelId': 7,
      'title': 'printf com String',
      'description': 'Imprima uma string',
      'type': 'multiple_choice',
      'content': 'Como imprimir uma string nome?',
      'correctAnswer': 'printf("Nome: %s", nome);',
      'options':
          'printf("Nome: nome");|printf("Nome: %s", nome);|printf("Nome: %c", nome);|printf("Nome: %d", nome);',
      'points': 15
    });

    // Ex 7.5: %c para char
    await db.insert('exercises', {
      'levelId': 7,
      'title': 'printf com Char',
      'description': 'Imprima um caractere',
      'type': 'fill_blank',
      'content': 'Complete: printf("Primeira letra: %c", ___);',
      'correctAnswer': 'letra',
      'options': '',
      'points': 15
    });

    // Ex 7.6: Múltiplos valores
    await db.insert('exercises', {
      'levelId': 7,
      'title': 'printf Múltiplo',
      'description': 'Imprima vários valores de uma vez',
      'type': 'multiple_choice',
      'content': 'Como imprimir nome e idade juntos?',
      'correctAnswer': 'printf("Nome: %s, Idade: %d", nome, idade);',
      'options':
          'printf("Nome: %s, Idade: %d", nome, idade);|printf(nome, idade);|print("%s %d", nome, idade);|printf("Nome: nome, Idade: idade");',
      'points': 15
    });

    // Ex 7.7: Quebra de linha
    await db.insert('exercises', {
      'levelId': 7,
      'title': 'Quebra de Linha',
      'description': 'Use \\n para nova linha',
      'type': 'code_ordering',
      'content': 'Ordene para imprimir duas linhas',
      'correctAnswer': 'printf("Linha 1\\nLinha 2");',
      'options': 'printf|("Linha 1\\nLinha 2");',
      'points': 15
    });

    // Ex 7.8: Tabulação
    await db.insert('exercises', {
      'levelId': 7,
      'title': 'Tabulação',
      'description': 'Use \\t para tabulação',
      'type': 'multiple_choice',
      'content': 'Como imprimir com tabulação?',
      'correctAnswer': 'printf("Nome:\\t%s", nome);',
      'options':
          'printf("Nome:    %s", nome);|printf("Nome:\\t%s", nome);|printf("Nome:%s", \\t, nome);|printf("Nome:" + TAB + "%s", nome);',
      'points': 15
    });

    // Ex 7.9: Formatação avançada
    await db.insert('exercises', {
      'levelId': 7,
      'title': 'Formatação Avançada',
      'description': 'Controle largura e precisão',
      'type': 'fill_blank',
      'content':
          'Complete para imprimir float com 3 casas: printf("%.___f", pi);',
      'correctAnswer': '.3',
      'options': '',
      'points': 15
    });

    // Ex 7.10: puts vs printf
    await db.insert('exercises', {
      'levelId': 7,
      'title': 'puts para Strings',
      'description': 'puts adiciona \\n automaticamente',
      'type': 'code_ordering',
      'content': 'Ordene para usar puts em vez de printf',
      'correctAnswer': 'puts("Hello World");',
      'options': 'puts|("Hello World");',
      'points': 15
    });
  }

  Future<void> _insertLevel8Exercises(Database db) async {
    // Ex 8.1: scanf básico
    await db.insert('exercises', {
      'levelId': 8,
      'title': 'scanf Simples',
      'description': 'Leia um inteiro do teclado',
      'type': 'multiple_choice',
      'content': 'Como ler um inteiro para variável idade?',
      'correctAnswer': 'scanf("%d", &idade);',
      'options':
          'scanf("%d", idade);|scanf("%d", &idade);|read("%d", &idade);|input("%d", &idade);',
      'points': 15
    });

    // Ex 8.2: scanf com float
    await db.insert('exercises', {
      'levelId': 8,
      'title': 'scanf com Float',
      'description': 'Leia um número decimal',
      'type': 'fill_blank',
      'content': 'Complete: scanf("___", &altura);',
      'correctAnswer': '%f',
      'options': '',
      'points': 15
    });

    // Ex 8.3: scanf com char
    await db.insert('exercises', {
      'levelId': 8,
      'title': 'scanf com Char',
      'description': 'Leia um caractere',
      'type': 'code_ordering',
      'content': 'Ordene: scanf("%c", &letra);',
      'options': 'scanf|("%c"|, &letra);',
      'correctAnswer': 'scanf("%c", &letra);',
      'points': 15
    });

    // Ex 8.4: scanf com string
    await db.insert('exercises', {
      'levelId': 8,
      'title': 'scanf com String',
      'description': 'Leia uma string (sem espaços)',
      'type': 'multiple_choice',
      'content': 'Como ler uma string para variável nome?',
      'correctAnswer': 'scanf("%s", nome);',
      'options':
          'scanf("%s", nome);|scanf("%s", &nome);|scanf("%c", nome);|scanf("%d", nome);',
      'points': 15
    });

    // Ex 8.5: Múltiplas entradas
    await db.insert('exercises', {
      'levelId': 8,
      'title': 'scanf Múltiplo',
      'description': 'Leia vários valores de uma vez',
      'type': 'fill_blank',
      'content': 'Complete: scanf("%d %f", &idade, ___);',
      'correctAnswer': '&altura',
      'options': '',
      'points': 15
    });

    // Ex 8.6: Espaços em scanf
    await db.insert('exercises', {
      'levelId': 8,
      'title': 'Espaços no scanf',
      'description': 'scanf ignora espaços em branco para números',
      'type': 'multiple_choice',
      'content': 'Para scanf("%d%d", &a, &b), qual entrada funciona?',
      'correctAnswer': '10 20',
      'options': '10,20|10 20|10-20|10\\n20',
      'points': 15
    });

    // Ex 8.7: Proteção buffer
    await db.insert('exercises', {
      'levelId': 8,
      'title': 'Proteção de Buffer',
      'description': 'Evite overflow com largura máxima',
      'type': 'code_ordering',
      'content': 'Ordene para ler no máximo 19 caracteres',
      'correctAnswer': 'scanf("%19s", nome);',
      'options': 'scanf|("%19s"|, nome);',
      'points': 15
    });

    // Ex 8.8: Retorno do scanf
    await db.insert('exercises', {
      'levelId': 8,
      'title': 'Valor de Retorno',
      'description': 'scanf retorna número de itens lidos',
      'type': 'multiple_choice',
      'content': 'O que scanf retorna se ler 2 valores com sucesso?',
      'correctAnswer': '2',
      'options': '0|1|2|-1',
      'points': 15
    });

    // Ex 8.9: Leitura específica
    await db.insert('exercises', {
      'levelId': 8,
      'title': 'Formato Específico',
      'description': 'Leia dados em formato específico',
      'type': 'fill_blank',
      'content':
          'Complete para ler data dd/mm/aaaa: scanf("%d/%d/%d", &dia, &mes, ___);',
      'correctAnswer': '&ano',
      'options': '',
      'points': 15
    });

    // Ex 8.10: Programa completo E/S
    await db.insert('exercises', {
      'levelId': 8,
      'title': 'Programa Completo E/S',
      'description': 'Combine printf e scanf',
      'type': 'code_ordering',
      'content': 'Ordene: pedir nome, ler e cumprimentar',
      'correctAnswer':
          'printf("Digite seu nome: ");\nscanf("%s", nome);\nprintf("Olá, %s!", nome);',
      'options':
          'printf("Digite seu nome: ");|scanf("%s", nome);|printf("Olá, %s!", nome);',
      'points': 20
    });
  }

  Future<void> _insertLevel9Exercises(Database db) async {
    // Ex 9.1: if simples
    await db.insert('exercises', {
      'levelId': 9,
      'title': 'if Simples',
      'description': 'Execute código condicionalmente',
      'type': 'multiple_choice',
      'content': 'Como executar código se x for maior que 0?',
      'correctAnswer': 'if (x > 0) { /* código */ }',
      'options':
          'if x > 0 then { /* código */ }|if (x > 0) { /* código */ }|when x > 0 { /* código */ }|case x > 0: { /* código */ }',
      'points': 20
    });

    // Ex 9.2: if com else
    await db.insert('exercises', {
      'levelId': 9,
      'title': 'if-else',
      'description': 'Execute um ou outro bloco',
      'type': 'fill_blank',
      'content':
          'Complete: if (idade >= 18) { printf("Maior"); } ___ { printf("Menor"); }',
      'correctAnswer': 'else',
      'options': '',
      'points': 20
    });

    // Ex 9.3: if-else encadeado
    await db.insert('exercises', {
      'levelId': 9,
      'title': 'if-else if-else',
      'description': 'Múltiplas condições',
      'type': 'code_ordering',
      'content': 'Ordene: if nota >= 9 "A", else if >= 7 "B", else "C"',
      'correctAnswer':
          'if (nota >= 9) printf("A");\nelse if (nota >= 7) printf("B");\nelse printf("C");',
      'options':
          'if (nota >= 9) printf("A");|else if (nota >= 7) printf("B");|else printf("C");',
      'points': 25
    });

    // Ex 9.4: Operador ternário
    await db.insert('exercises', {
      'levelId': 9,
      'title': 'Operador Ternário',
      'description': 'If-else em uma expressão',
      'type': 'multiple_choice',
      'content': 'Como atribuir 1 se x>0 senão 0 usando ternário?',
      'correctAnswer': 'y = (x > 0) ? 1 : 0;',
      'options':
          'y = if x>0 1 else 0;|y = (x > 0) ? 1 : 0;|y = x>0 : 1 ? 0;|y = (x > 0) then 1 else 0;',
      'points': 20
    });

    // Ex 9.5: Condição aninhada
    await db.insert('exercises', {
      'levelId': 9,
      'title': 'if Aninhado',
      'description': 'if dentro de outro if',
      'type': 'fill_blank',
      'content': 'Complete: if (x > 0) { if (y > 0) { printf("___"); } }',
      'correctAnswer': 'Primeiro quadrante',
      'options': '',
      'points': 20
    });

    // Ex 9.6: Operadores lógicos
    await db.insert('exercises', {
      'levelId': 9,
      'title': 'Condição Composta',
      'description': 'Combine condições com operadores lógicos',
      'type': 'multiple_choice',
      'content': 'Como verificar se x está entre 1 e 10?',
      'correctAnswer': 'if (x >= 1 && x <= 10)',
      'options':
          'if (x > 1 && x < 10)|if (x >= 1 && x <= 10)|if (1 <= x <= 10)|if (x in [1..10])',
      'points': 20
    });

    // Ex 9.7: Programa completo
    await db.insert('exercises', {
      'levelId': 9,
      'title': 'Programa com if-else',
      'description': 'Crie um programa que classifica notas',
      'type': 'code_ordering',
      'content': 'Ordene: ler nota, se >=7 "Aprovado" senão "Reprovado"',
      'correctAnswer':
          '#include <stdio.h>\nint main() {\n  float nota;\n  printf("Digite a nota: ");\n  scanf("%f", &nota);\n  if (nota >= 7.0) printf("Aprovado");\n  else printf("Reprovado");\n  return 0;\n}',
      'options':
          '#include <stdio.h>|int main()|{\n  float nota;|printf("Digite a nota: ");|scanf("%f", &nota);|if (nota >= 7.0) printf("Aprovado");|else printf("Reprovado");|return 0;\n}',
      'points': 25
    });

    // Ex 9.8: if sem chaves
    await db.insert('exercises', {
      'levelId': 9,
      'title': 'if sem Chaves',
      'description': 'if com apenas uma instrução pode omitir chaves',
      'type': 'multiple_choice',
      'content': 'Qual está correto?',
      'correctAnswer': 'if (x > 0) printf("Positivo");',
      'options':
          'if x > 0 printf("Positivo");|if (x > 0) printf("Positivo");|if (x > 0) then printf("Positivo");|if (x > 0) { printf("Positivo") }',
      'points': 20
    });

    // Ex 9.9: else if
    await db.insert('exercises', {
      'levelId': 9,
      'title': 'else if',
      'description': 'Cadeia de condições',
      'type': 'fill_blank',
      'content':
          'Complete: if (x > 0) printf("Positivo"); ___ printf("Zero"); else printf("Negativo");',
      'correctAnswer': 'else if (x == 0)',
      'options': '',
      'points': 20
    });

    // Ex 9.10: Erro comum
    await db.insert('exercises', {
      'levelId': 9,
      'title': 'Erro de Igualdade',
      'description': '= é atribuição, == é comparação',
      'type': 'multiple_choice',
      'content': 'Qual o erro? if (x = 0) printf("Zero");',
      'correctAnswer': 'Usou = em vez de ==',
      'options':
          'Falta ponto e vírgula|Usou = em vez de ==|Falta chaves|Não há erro',
      'points': 20
    });
  }

  Future<void> _insertLevel10Exercises(Database db) async {
    // Ex 10.1: switch básico
    await db.insert('exercises', {
      'levelId': 10,
      'title': 'switch Simples',
      'description': 'Seleção múltipla com switch',
      'type': 'multiple_choice',
      'content': 'Como fazer switch em variável opcao?',
      'correctAnswer': 'switch(opcao) { case 1: ... }',
      'options':
          'switch opcao { case 1: ... }|switch(opcao) { case 1: ... }|switch (opcao) then case 1: ...|select opcao case 1: ...',
      'points': 20
    });

    // Ex 10.2: case
    await db.insert('exercises', {
      'levelId': 10,
      'title': 'case',
      'description': 'Defina casos específicos',
      'type': 'fill_blank',
      'content': 'Complete: switch(dia) { ___ 1: printf("Domingo"); break; }',
      'correctAnswer': 'case',
      'options': '',
      'points': 20
    });

    // Ex 10.3: break
    await db.insert('exercises', {
      'levelId': 10,
      'title': 'break no switch',
      'description': 'Evite fall-through com break',
      'type': 'code_ordering',
      'content': 'Ordene um switch para opções 1-3 com break',
      'correctAnswer':
          'switch(opcao) {\n  case 1: printf("Um"); break;\n  case 2: printf("Dois"); break;\n  case 3: printf("Três"); break;\n}',
      'options':
          'switch(opcao)|{\n  case 1:|printf("Um"); break;|\n  case 2:|printf("Dois"); break;|\n  case 3:|printf("Três"); break;\n}',
      'points': 25
    });

    // Ex 10.4: default
    await db.insert('exercises', {
      'levelId': 10,
      'title': 'case default',
      'description': 'Trate casos não especificados',
      'type': 'multiple_choice',
      'content': 'Como tratar todos os outros casos?',
      'correctAnswer': 'default: ...',
      'options': 'else: ...|default: ...|otherwise: ...|case *: ...',
      'points': 20
    });

    // Ex 10.5: múltiplos cases
    await db.insert('exercises', {
      'levelId': 10,
      'title': 'Múltiplos Cases',
      'description': 'Vários valores executam mesmo código',
      'type': 'fill_blank',
      'content': 'Complete: case 1: ___ 2: printf("Um ou Dois"); break;',
      'correctAnswer': 'case',
      'options': '',
      'points': 20
    });

    // Ex 10.6: switch vs if
    await db.insert('exercises', {
      'levelId': 10,
      'title': 'switch vs if-else',
      'description': 'switch é mais eficiente para múltiplos valores',
      'type': 'multiple_choice',
      'content': 'Quando usar switch em vez de if-else?',
      'correctAnswer': 'Comparar variável com valores constantes específicos',
      'options':
          'Sempre|Comparar variável com valores constantes específicos|Quando há muitas condições complexas|Quando precisa de intervalos',
      'points': 20
    });

    // Ex 10.7: switch com char
    await db.insert('exercises', {
      'levelId': 10,
      'title': 'switch com Char',
      'description': 'switch funciona com chars',
      'type': 'code_ordering',
      'content': 'Ordene um switch para vogais',
      'correctAnswer':
          'switch(letra) {\n  case \'a\':\n  case \'e\':\n  case \'i\':\n  case \'o\':\n  case \'u\': printf("Vogal"); break;\n  default: printf("Não vogal");\n}',
      'options':
          'switch(letra)|{\n  case \'a\':|\n  case \'e\':|\n  case \'i\':|\n  case \'o\':|\n  case \'u\':|printf("Vogal"); break;|\n  default:|printf("Não vogal");\n}',
      'points': 25
    });

    // Ex 10.8: fall-through intencional
    await db.insert('exercises', {
      'levelId': 10,
      'title': 'Fall-through Intencional',
      'description': 'À vezes queremos continuar sem break',
      'type': 'multiple_choice',
      'content': 'O que acontece sem break?',
      'correctAnswer': 'Executa próximo case também',
      'options':
          'Erro de compilação|Executa próximo case também|Para execução|Volta ao início',
      'points': 20
    });

    // Ex 10.9: switch aninhado
    await db.insert('exercises', {
      'levelId': 10,
      'title': 'switch Aninhado',
      'description': 'switch dentro de outro switch',
      'type': 'fill_blank',
      'content':
          'Complete: switch(x) { case 1: switch(y) { case 1: printf("___"); } }',
      'correctAnswer': 'Ambos 1',
      'options': '',
      'points': 20
    });

    // Ex 10.10: erros comuns
    await db.insert('exercises', {
      'levelId': 10,
      'title': 'Erros Comuns',
      'description': 'switch só funciona com tipos inteiros',
      'type': 'multiple_choice',
      'content': 'Qual NÃO funciona com switch?',
      'correctAnswer': 'float',
      'options': 'int|char|float|enum',
      'points': 20
    });
  }

  Future<void> _insertLevel11Exercises(Database db) async {
    // Ex 11.1: for básico
    await db.insert('exercises', {
      'levelId': 11,
      'title': 'for Simples',
      'description': 'Laço for com contador',
      'type': 'multiple_choice',
      'content': 'Como imprimir números 1 a 5 com for?',
      'correctAnswer': 'for(int i=1; i<=5; i++) printf("%d ", i);',
      'options':
          'for i=1 to 5 printf("%d ", i);|for(int i=1; i<=5; i++) printf("%d ", i);|for i in range(1,6): printf("%d ", i);|loop i=1..5 printf("%d ", i);',
      'points': 25
    });

    // Ex 11.2: inicialização
    await db.insert('exercises', {
      'levelId': 11,
      'title': 'Inicialização do for',
      'description': 'Declare e inicialize variável de controle',
      'type': 'fill_blank',
      'content': 'Complete: for(___ i=0; i<10; i++)',
      'correctAnswer': 'int',
      'options': '',
      'points': 25
    });

    // Ex 11.3: três partes
    await db.insert('exercises', {
      'levelId': 11,
      'title': 'Três Partes do for',
      'description': 'inicialização, condição, incremento',
      'type': 'code_ordering',
      'content': 'Ordene um for que conta de 0 a 9',
      'correctAnswer': 'for(int i=0; i<10; i++)',
      'options': 'for|(int i=0;|i<10;|i++)',
      'points': 30
    });

    // Ex 11.4: decremento
    await db.insert('exercises', {
      'levelId': 11,
      'title': 'for com Decremento',
      'description': 'Conte regressivamente',
      'type': 'multiple_choice',
      'content': 'Como contar de 10 até 1?',
      'correctAnswer': 'for(int i=10; i>=1; i--)',
      'options':
          'for(int i=10; i>=1; i--)|for(int i=10; i<=1; i--)|for(int i=1; i<=10; i++)|for(int i=10; i>0; i++)',
      'points': 25
    });

    // Ex 11.5: passo 2
    await db.insert('exercises', {
      'levelId': 11,
      'title': 'Passo Diferente',
      'description': 'Incremente de 2 em 2',
      'type': 'fill_blank',
      'content': 'Complete: for(int i=0; i<20; i = i ___)',
      'correctAnswer': '+ 2',
      'options': '',
      'points': 25
    });

    // Ex 11.6: laço infinito
    await db.insert('exercises', {
      'levelId': 11,
      'title': 'for Infinito',
      'description': 'Crie um loop infinito com for',
      'type': 'multiple_choice',
      'content': 'Como criar um for infinito?',
      'correctAnswer': 'for(;;)',
      'options': 'for(;;)|for(true)|for(1)|for(i=0; i<infinity; i++)',
      'points': 25
    });

    // Ex 11.7: múltiplas variáveis
    await db.insert('exercises', {
      'levelId': 11,
      'title': 'Múltiplas Variáveis',
      'description': 'Use mais de uma variável no for',
      'type': 'code_ordering',
      'content': 'Ordene for com duas variáveis',
      'correctAnswer': 'for(int i=0, j=10; i<j; i++, j--)',
      'options': 'for|(int i=0, j=10;|i<j;|i++, j--)',
      'points': 30
    });

    // Ex 11.8: for aninhado
    await db.insert('exercises', {
      'levelId': 11,
      'title': 'for Aninhado',
      'description': 'Laço dentro de laço',
      'type': 'multiple_choice',
      'content': 'Como imprimir uma matriz 3x3?',
      'correctAnswer':
          'for(i=0; i<3; i++) for(j=0; j<3; j++) printf("%d ", matriz[i][j]);',
      'options':
          'for(i=0; i<3; i++) for(j=0; j<3; j++) printf("%d ", matriz[i][j]);|for(i,j in 0..3) printf("%d ", matriz[i][j]);|for(i=0; i<9; i++) printf("%d ", matriz[i]);|for(i=0..3) for(j=0..3) printf("%d ", matriz[i][j]);',
      'points': 25
    });

    // Ex 11.9: break no for
    await db.insert('exercises', {
      'levelId': 11,
      'title': 'break no for',
      'description': 'Interrompa o laço prematuramente',
      'type': 'fill_blank',
      'content': 'Complete: for(int i=0; i<100; i++) { if(i==50) ___; }',
      'correctAnswer': 'break',
      'options': '',
      'points': 25
    });

    // Ex 11.10: continue no for
    await db.insert('exercises', {
      'levelId': 11,
      'title': 'continue no for',
      'description': 'Pule para próxima iteração',
      'type': 'multiple_choice',
      'content': 'O que faz continue em um for?',
      'correctAnswer': 'Pula para próxima iteração, executando incremento',
      'options':
          'Termina o laço|Pula para próxima iteração, executando incremento|Volta ao início sem incrementar|Pula apenas o código atual',
      'points': 25
    });
  }

  Future<void> _insertLevel12Exercises(Database db) async {
    // Ex 12.1: while básico
    await db.insert('exercises', {
      'levelId': 12,
      'title': 'while Simples',
      'description': 'Laço com condição no início',
      'type': 'multiple_choice',
      'content': 'Como imprimir números 1 a 5 com while?',
      'correctAnswer': 'int i=1; while(i<=5) { printf("%d ", i); i++; }',
      'options':
          'while(i=1; i<=5; i++) printf("%d ", i);|int i=1; while(i<=5) { printf("%d ", i); i++; }|while i in 1..5 printf("%d ", i);|for i=1 to 5 while printf("%d ", i);',
      'points': 25
    });

    // Ex 12.2: condição while
    await db.insert('exercises', {
      'levelId': 12,
      'title': 'Condição do while',
      'description': 'while repete enquanto condição verdadeira',
      'type': 'fill_blank',
      'content': 'Complete: while(contador ___ 10)',
      'correctAnswer': '<',
      'options': '',
      'points': 25
    });

    // Ex 12.3: estrutura completa
    await db.insert('exercises', {
      'levelId': 12,
      'title': 'Estrutura completa',
      'description': 'Inicialização, condição, atualização',
      'type': 'code_ordering',
      'content': 'Ordene um while que soma números até 100',
      'correctAnswer':
          'int soma=0, i=1;\nwhile(i <= 100) {\n  soma += i;\n  i++;\n}',
      'options': 'int soma=0, i=1;|while(i <= 100)|{\n  soma += i;|\n  i++;\n}',
      'points': 30
    });

    // Ex 12.4: while vs for
    await db.insert('exercises', {
      'levelId': 12,
      'title': 'while vs for',
      'description': 'Use while quando não sabe número de iterações',
      'type': 'multiple_choice',
      'content': 'Quando usar while em vez de for?',
      'correctAnswer': 'Quando não se sabe quantas iterações serão necessárias',
      'options':
          'Sempre|Quando não se sabe quantas iterações serão necessárias|Para contar iterações|Para loops aninhados',
      'points': 25
    });

    // Ex 12.5: loop infinito
    await db.insert('exercises', {
      'levelId': 12,
      'title': 'while Infinito',
      'description': 'Crie um loop infinito com while',
      'type': 'fill_blank',
      'content': 'Complete: while(___) { /* código */ }',
      'correctAnswer': '1',
      'options': '',
      'points': 25
    });

    // Ex 12.6: condição complexa
    await db.insert('exercises', {
      'levelId': 12,
      'title': 'Condição Complexa',
      'description': 'Use expressões complexas na condição',
      'type': 'multiple_choice',
      'content': 'Como ler números até digitar 0?',
      'correctAnswer': 'while(scanf("%d", &n), n != 0)',
      'options':
          'while(n != 0) scanf("%d", &n);|while(scanf("%d", &n), n != 0)|do { scanf("%d", &n); } while(n != 0);|for(; n != 0;) scanf("%d", &n);',
      'points': 25
    });

    // Ex 12.7: break no while
    await db.insert('exercises', {
      'levelId': 12,
      'title': 'break no while',
      'description': 'Interrompa o laço prematuramente',
      'type': 'code_ordering',
      'content': 'Ordene um while com break quando encontrar -1',
      'correctAnswer':
          'while(1) {\n  scanf("%d", &n);\n  if(n == -1) break;\n  printf("%d ", n);\n}',
      'options':
          'while(1)|{\n  scanf("%d", &n);|if(n == -1) break;|printf("%d ", n);\n}',
      'points': 30
    });

    // Ex 12.8: continue no while
    await db.insert('exercises', {
      'levelId': 12,
      'title': 'continue no while',
      'description': 'Pule para próxima iteração',
      'type': 'multiple_choice',
      'content': 'O que faz continue em um while?',
      'correctAnswer': 'Volta para testar a condição',
      'options':
          'Termina o laço|Volta para testar a condição|Pula para próximo bloco|Ignora tudo',
      'points': 25
    });

    // Ex 12.9: while aninhado
    await db.insert('exercises', {
      'levelId': 12,
      'title': 'while Aninhado',
      'description': 'while dentro de while',
      'type': 'fill_blank',
      'content':
          'Complete: while(i<3) { while(j<3) { printf("(%d,%d) ", i, j); j++; } i++; j=___; }',
      'correctAnswer': '0',
      'options': '',
      'points': 25
    });

    // Ex 12.10: erro comum
    await db.insert('exercises', {
      'levelId': 12,
      'title': 'Erro Comum',
      'description': 'Esquecer de atualizar variável de controle',
      'type': 'multiple_choice',
      'content': 'Qual cria loop infinito?',
      'correctAnswer': 'int i=0; while(i<10) { printf("%d", i); }',
      'options':
          'int i=0; while(i<10) { printf("%d", i); i++; }|int i=0; while(i<10) { printf("%d", i); }|for(int i=0; i<10; i++) printf("%d", i);|int i=0; do { printf("%d", i); i++; } while(i<10);',
      'points': 25
    });
  }

  Future<void> _insertLevel13Exercises(Database db) async {
    // Ex 13.1: do-while básico
    await db.insert('exercises', {
      'levelId': 13,
      'title': 'do-while Simples',
      'description': 'Laço com condição no final',
      'type': 'multiple_choice',
      'content': 'Como pedir número até ser positivo com do-while?',
      'correctAnswer': 'do { scanf("%d", &n); } while(n <= 0);',
      'options':
          'do { scanf("%d", &n); } while(n <= 0);|while(n <= 0) scanf("%d", &n);|do scanf("%d", &n) while n <= 0;|repeat scanf("%d", &n) until n > 0;',
      'points': 30
    });

    // Ex 13.2: estrutura do-while
    await db.insert('exercises', {
      'levelId': 13,
      'title': 'Estrutura do-while',
      'description': 'Executa pelo menos uma vez',
      'type': 'fill_blank',
      'content': 'Complete: ___ { printf("Menu"); } while(opcao != 0);',
      'correctAnswer': 'do',
      'options': '',
      'points': 30
    });

    // Ex 13.3: do-while completo
    await db.insert('exercises', {
      'levelId': 13,
      'title': 'do-while Completo',
      'description': 'Monte um menu simples',
      'type': 'code_ordering',
      'content': 'Ordene um menu que repete até opção 0',
      'correctAnswer':
          'do {\n  printf("1. Opção 1\\n2. Opção 2\\n0. Sair");\n  scanf("%d", &opcao);\n} while(opcao != 0);',
      'options':
          'do|{\n  printf("1. Opção 1\\n2. Opção 2\\n0. Sair");|scanf("%d", &opcao);\n}|while(opcao != 0);',
      'points': 35
    });

    // Ex 13.4: diferença while/do-while
    await db.insert('exercises', {
      'levelId': 13,
      'title': 'Diferença while/do-while',
      'description': 'do-while sempre executa pelo menos uma vez',
      'type': 'multiple_choice',
      'content': 'Qual a principal diferença?',
      'correctAnswer': 'do-while executa pelo menos uma vez',
      'options':
          'do-while é mais rápido|do-while executa pelo menos uma vez|while é mais legível|Não há diferença',
      'points': 30
    });

    // Ex 13.5: condição do-while
    await db.insert('exercises', {
      'levelId': 13,
      'title': 'Condição do-while',
      'description': 'Condição testada no final',
      'type': 'fill_blank',
      'content': 'Complete: do { soma += n; scanf("%d", &n); } while(n ___ 0);',
      'correctAnswer': '!=',
      'options': '',
      'points': 30
    });

    // Ex 13.6: uso típico
    await db.insert('exercises', {
      'levelId': 13,
      'title': 'Uso Típico',
      'description': 'do-while ideal para menus',
      'type': 'multiple_choice',
      'content': 'Quando usar do-while?',
      'correctAnswer': 'Quando precisa executar pelo menos uma vez',
      'options':
          'Sempre|Quando precisa executar pelo menos uma vez|Para contar iterações|Para loops infinitos',
      'points': 30
    });

    // Ex 13.7: break no do-while
    await db.insert('exercises', {
      'levelId': 13,
      'title': 'break no do-while',
      'description': 'Interrompa o laço',
      'type': 'code_ordering',
      'content': 'Ordene um do-while com break se n for negativo',
      'correctAnswer':
          'do {\n  scanf("%d", &n);\n  if(n < 0) break;\n  printf("%d ", n);\n} while(n != 0);',
      'options':
          'do|{\n  scanf("%d", &n);|if(n < 0) break;|printf("%d ", n);\n}|while(n != 0);',
      'points': 35
    });

    // Ex 13.8: continue no do-while
    await db.insert('exercises', {
      'levelId': 13,
      'title': 'continue no do-while',
      'description': 'Pule para testar condição',
      'type': 'multiple_choice',
      'content': 'O que faz continue em do-while?',
      'correctAnswer': 'Vai para o teste da condição',
      'options':
          'Termina o laço|Vai para o teste da condição|Pula para próxima instrução|Volta ao início do bloco',
      'points': 30
    });

    // Ex 13.9: do-while aninhado
    await db.insert('exercises', {
      'levelId': 13,
      'title': 'do-while Aninhado',
      'description': 'do-while dentro de do-while',
      'type': 'fill_blank',
      'content':
          'Complete: do { do { printf("*"); j++; } while(j<5); printf("\\n"); i++; j=___; } while(i<3);',
      'correctAnswer': '0',
      'options': '',
      'points': 30
    });

    // Ex 13.10: ponto e vírgula
    await db.insert('exercises', {
      'levelId': 13,
      'title': 'Ponto e Vírgula',
      'description': 'do-while termina com ;',
      'type': 'multiple_choice',
      'content': 'Qual está correto?',
      'correctAnswer': 'do { } while(condicao);',
      'options':
          'do { } while(condicao);|do { } while(condicao)|do { } while condicao;|do { } while condicao',
      'points': 30
    });
  }

  Future<void> _insertLevel14Exercises(Database db) async {
    // Ex 14.1: função básica
    await db.insert('exercises', {
      'levelId': 14,
      'title': 'Declaração de Função',
      'description': 'Crie uma função simples',
      'type': 'multiple_choice',
      'content': 'Como declarar uma função chamada "ola"?',
      'correctAnswer': 'void ola() { printf("Olá"); }',
      'options':
          'function ola() { printf("Olá"); }|void ola() { printf("Olá"); }|def ola(): printf("Olá")|ola() { printf("Olá"); }',
      'points': 30
    });

    // Ex 14.2: chamada de função
    await db.insert('exercises', {
      'levelId': 14,
      'title': 'Chamando Função',
      'description': 'Execute uma função',
      'type': 'fill_blank',
      'content': 'Complete para chamar função ola: ___();',
      'correctAnswer': 'ola',
      'options': '',
      'points': 30
    });

    // Ex 14.3: função com retorno
    await db.insert('exercises', {
      'levelId': 14,
      'title': 'Função com Retorno',
      'description': 'Função que retorna valor',
      'type': 'code_ordering',
      'content': 'Ordene função que retorna 42',
      'correctAnswer': 'int resposta() {\n  return 42;\n}',
      'options': 'int resposta()|{\n  return 42;\n}',
      'points': 35
    });

    // Ex 14.4: return
    await db.insert('exercises', {
      'levelId': 14,
      'title': 'Instrução return',
      'description': 'Retorne valor da função',
      'type': 'multiple_choice',
      'content': 'Como retornar valor 10 de uma função?',
      'correctAnswer': 'return 10;',
      'options': 'return 10;|exit 10;|ret 10;|give 10;',
      'points': 30
    });

    // Ex 14.5: void
    await db.insert('exercises', {
      'levelId': 14,
      'title': 'Tipo void',
      'description': 'Função que não retorna valor',
      'type': 'fill_blank',
      'content': 'Complete: ___ imprimir() { printf("Teste"); }',
      'correctAnswer': 'void',
      'options': '',
      'points': 30
    });

    // Ex 14.6: protótipo
    await db.insert('exercises', {
      'levelId': 14,
      'title': 'Protótipo de Função',
      'description': 'Declare função antes de usar',
      'type': 'multiple_choice',
      'content': 'Como prototipar função int soma(int, int)?',
      'correctAnswer': 'int soma(int a, int b);',
      'options':
          'int soma(int a, int b);|int soma(a, b);|soma(int a, int b);|function soma(int a, int b)',
      'points': 30
    });

    // Ex 14.7: função main
    await db.insert('exercises', {
      'levelId': 14,
      'title': 'Função main',
      'description': 'main é uma função especial',
      'type': 'code_ordering',
      'content': 'Ordene programa com função auxiliar',
      'correctAnswer':
          '#include <stdio.h>\nvoid ola() { printf("Olá"); }\nint main() { ola(); return 0; }',
      'options':
          '#include <stdio.h>|void ola() { printf("Olá"); }|int main()|{ ola(); return 0; }',
      'points': 35
    });

    // Ex 14.8: escopo local
    await db.insert('exercises', {
      'levelId': 14,
      'title': 'Escopo Local',
      'description': 'Variáveis dentro de função são locais',
      'type': 'multiple_choice',
      'content': 'Onde variável local é visível?',
      'correctAnswer': 'Apenas dentro da função onde foi declarada',
      'options':
          'Em todo o programa|Apenas dentro da função onde foi declarada|Em funções do mesmo tipo|No arquivo inteiro',
      'points': 30
    });

    // Ex 14.9: função dentro de função
    await db.insert('exercises', {
      'levelId': 14,
      'title': 'Erro Comum',
      'description': 'Não pode definir função dentro de função',
      'type': 'fill_blank',
      'content': 'Complete: Em C, não pode definir função ___ de outra função',
      'correctAnswer': 'dentro',
      'options': '',
      'points': 30
    });

    // Ex 14.10: múltiplas funções
    await db.insert('exercises', {
      'levelId': 14,
      'title': 'Múltiplas Funções',
      'description': 'Programa com várias funções',
      'type': 'multiple_choice',
      'content': 'Qual a ordem correta?',
      'correctAnswer': 'Protótipos, main, definições',
      'options':
          'Main, protótipos, definições|Protótipos, main, definições|Definições, main|Apenas main',
      'points': 30
    });
  }

  Future<void> _insertLevel15Exercises(Database db) async {
    // Ex 15.1: função com parâmetro
    await db.insert('exercises', {
      'levelId': 15,
      'title': 'Parâmetro de Função',
      'description': 'Função que recebe argumentos',
      'type': 'multiple_choice',
      'content': 'Como criar função que recebe int x?',
      'correctAnswer': 'void funcao(int x) { }',
      'options':
          'void funcao(int x) { }|void funcao(x int) { }|function funcao(int x) { }|funcao(int x) { }',
      'points': 30
    });

    // Ex 15.2: múltiplos parâmetros
    await db.insert('exercises', {
      'levelId': 15,
      'title': 'Múltiplos Parâmetros',
      'description': 'Função com mais de um parâmetro',
      'type': 'fill_blank',
      'content': 'Complete: int soma(int a, int ___) { return a + b; }',
      'correctAnswer': 'b',
      'options': '',
      'points': 30
    });

    // Ex 15.3: chamada com argumentos
    await db.insert('exercises', {
      'levelId': 15,
      'title': 'Passando Argumentos',
      'description': 'Passe valores para função',
      'type': 'code_ordering',
      'content': 'Ordene chamada da função soma com 5 e 3',
      'correctAnswer': 'int resultado = soma(5, 3);',
      'options': 'int|resultado|=|soma(5, 3);',
      'points': 35
    });

    // Ex 15.4: passagem por valor
    await db.insert('exercises', {
      'levelId': 15,
      'title': 'Passagem por Valor',
      'description': 'Cópia do valor, não altera original',
      'type': 'multiple_choice',
      'content': 'O que acontece se modificar parâmetro?',
      'correctAnswer': 'Modifica apenas a cópia local',
      'options':
          'Modifica variável original|Modifica apenas a cópia local|Erro de compilação|Resultado imprevisível',
      'points': 30
    });

    // Ex 15.5: função com retorno
    await db.insert('exercises', {
      'levelId': 15,
      'title': 'Retornando Valor',
      'description': 'Use return para enviar resultado',
      'type': 'fill_blank',
      'content': 'Complete: int quadrado(int x) { ___ x * x; }',
      'correctAnswer': 'return',
      'options': '',
      'points': 30
    });

    // Ex 15.6: tipo de retorno
    await db.insert('exercises', {
      'levelId': 15,
      'title': 'Tipo de Retorno',
      'description': 'Função pode retornar qualquer tipo',
      'type': 'multiple_choice',
      'content': 'Qual NÃO pode ser tipo de retorno?',
      'correctAnswer': 'array',
      'options': 'int|float|char|array',
      'points': 30
    });

    // Ex 15.7: função fatorial
    await db.insert('exercises', {
      'levelId': 15,
      'title': 'Função Recursiva',
      'description': 'Função que chama a si mesma',
      'type': 'code_ordering',
      'content': 'Ordene função fatorial recursiva',
      'correctAnswer':
          'int fatorial(int n) {\n  if(n <= 1) return 1;\n  return n * fatorial(n-1);\n}',
      'options':
          'int fatorial(int n)|{\n  if(n <= 1)|return 1;|\n  return n * fatorial(n-1);\n}',
      'points': 35
    });

    // Ex 15.8: parâmetro formal vs real
    await db.insert('exercises', {
      'levelId': 15,
      'title': 'Parâmetros Formais/Reais',
      'description': 'Formais na definição, reais na chamada',
      'type': 'multiple_choice',
      'content': 'Em "int soma(int a, int b)", a e b são:',
      'correctAnswer': 'Parâmetros formais',
      'options': 'Parâmetros reais|Parâmetros formais|Argumentos|Valores',
      'points': 30
    });

    // Ex 15.9: função void com parâmetro
    await db.insert('exercises', {
      'levelId': 15,
      'title': 'void com Parâmetro',
      'description': 'Função sem retorno pode ter parâmetros',
      'type': 'fill_blank',
      'content':
          'Complete: void imprimir(int vezes) { for(int i=0; i<___; i++) printf("Oi\\n"); }',
      'correctAnswer': 'vezes',
      'options': '',
      'points': 30
    });

    // Ex 15.10: programa completo
    await db.insert('exercises', {
      'levelId': 15,
      'title': 'Programa com Funções',
      'description': 'Programa completo usando funções',
      'type': 'multiple_choice',
      'content': 'Qual a estrutura correta?',
      'correctAnswer': 'Protótipos, main, definições',
      'options':
          'Definições, protótipos, main|Protótipos, main, definições|Main, definições|Apenas funções',
      'points': 30
    });
  }

  // Métodos para operações CRUD
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
      String table, String whereClause, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.query(table, where: whereClause, whereArgs: whereArgs);
  }

  Future<int> update(String table, Map<String, dynamic> data,
      String whereClause, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.update(table, data,
        where: whereClause, whereArgs: whereArgs);
  }

  Future<int> delete(
      String table, String whereClause, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.delete(table, where: whereClause, whereArgs: whereArgs);
  }

  // Métodos específicos para pontuações
  Future<int> insertScore(Score score) async {
    final db = await database;
    return await db.insert('scores', score.toMap());
  }

  Future<List<Score>> getScores() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('scores', orderBy: 'completedAt DESC');

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return Score.fromMap(maps[i]);
    });
  }

  Future<void> closeConnection() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
