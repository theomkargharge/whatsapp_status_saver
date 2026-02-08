import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_status_saver/core/localization/l10n/app_localizations.dart';
import 'core/utils/theme.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
   // Method to change locale from anywhere in the app
  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }
}

class _MyAppState extends State<MyApp> {

    Locale? _locale;

      Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('selected_language');
    
    if (languageCode != null) {
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Status Downloader',
      darkTheme: AppTheme.darkTheme,
      locale: _locale,
      themeMode: ThemeMode.system,
        localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('hi'), // Hindi
        Locale('bn'), // Bengali
        Locale('te'), // Telugu
        Locale('mr'), // Marathi
        Locale('ta'), // Tamil
        Locale('gu'), // Gujarati
        Locale('kn'), // Kannada
        Locale('ml'), // Malayalam
        Locale('pa'), // Punjabi
        Locale('or'), // Odia
        Locale('as'), // Assamese
        Locale('ur'), // Urdu
        // Add all 22 languages
      ],
      
      home: PermissionScreen()
    );
  }
}
