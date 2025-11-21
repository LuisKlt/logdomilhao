import 'package:flutter/material.dart';
import 'package:logdomilhao/presentation/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:logdomilhao/providers/theme_provider.dart';
import 'package:logdomilhao/providers/gamification_provider.dart';
import 'package:logdomilhao/data/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar o banco de dados
  await DatabaseHelper().database;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Inicializar o GamificationProvider após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    // O GamificationProvider será inicializado automaticamente
    // quando for acessado pela primeira vez através do Consumer
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GamificationProvider(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return MaterialApp(
                title: 'LogDoMilhão',
                debugShowCheckedModeBanner: false,
                theme: themeProvider.lightTheme,
                darkTheme: themeProvider.darkTheme,
                themeMode: themeProvider.themeMode,
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}