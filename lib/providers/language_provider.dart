import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('pt', 'BR');
  
  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguageFromPrefs();
  }

  Future<void> _loadLanguageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'pt';
    final countryCode = prefs.getString('country_code') ?? 'BR';
    
    _locale = Locale(languageCode, countryCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');
    
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode, String countryCode) async {
    await setLocale(Locale(languageCode, countryCode));
  }
}