import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logdomilhao/presentation/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:logdomilhao/providers/theme_provider.dart';
import 'package:logdomilhao/providers/language_provider.dart';
import 'package:logdomilhao/providers/gamification_provider.dart';
import 'package:logdomilhao/l10n/app_localizations.dart';
import 'package:logdomilhao/data/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar o banco de dados
  await DatabaseHelper().database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GamificationProvider(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Consumer2<ThemeProvider, LanguageProvider>(
            builder: (context, themeProvider, languageProvider, _) {
              return MaterialApp(
                title: 'LogDoMilhão',
                debugShowCheckedModeBanner: false,
                theme: themeProvider.lightTheme,
                darkTheme: themeProvider.darkTheme,
                themeMode: themeProvider.themeMode,
                locale: languageProvider.locale,
                supportedLocales: const [
                  Locale('pt'),
                  Locale('en'),
                  Locale('es'),
                ],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
