import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/settings.dart';
import 'models/shooting_style.dart';
import 'services/sound_service.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MainScreen());
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Settings _settings;
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    _settings = Settings(
      preparationTime: 10,
      shootingTime: 240,
      warningTime: 30,
      practiceRounds: 2,
      matchRounds: 12,
      shootingStyle: ShootingStyle.standard,
    );
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _settings = Settings(
        preparationTime: prefs.getInt('preparationTime') ?? 10,
        shootingTime: prefs.getInt('shootingTime') ?? 240,
        warningTime: prefs.getInt('warningTime') ?? 30,
        practiceRounds: prefs.getInt('practiceRounds') ?? 2,
        matchRounds: prefs.getInt('matchRounds') ?? 12,
        shootingStyle: ShootingStyle.values[prefs.getInt('shootingStyle') ?? 0],
      );
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('preparationTime', _settings.preparationTime);
    await prefs.setInt('shootingTime', _settings.shootingTime);
    await prefs.setInt('warningTime', _settings.warningTime);
    await prefs.setInt('practiceRounds', _settings.practiceRounds);
    await prefs.setInt('matchRounds', _settings.matchRounds);
    await prefs.setInt('shootingStyle', _settings.shootingStyle.index);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ottoman Archery Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue.shade700,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: WelcomeScreen(
        settings: _settings,
        soundService: _soundService,
        onPreparationTimeChanged: (value) {
          setState(() {
            _settings = Settings(
              preparationTime: value,
              shootingTime: _settings.shootingTime,
              warningTime: _settings.warningTime,
              practiceRounds: _settings.practiceRounds,
              matchRounds: _settings.matchRounds,
              shootingStyle: _settings.shootingStyle,
            );
            _saveSettings();
          });
        },
        onShootingTimeChanged: (value) {
          setState(() {
            _settings = Settings(
              preparationTime: _settings.preparationTime,
              shootingTime: value,
              warningTime: _settings.warningTime,
              practiceRounds: _settings.practiceRounds,
              matchRounds: _settings.matchRounds,
              shootingStyle: _settings.shootingStyle,
            );
            _saveSettings();
          });
        },
        onWarningTimeChanged: (value) {
          setState(() {
            _settings = Settings(
              preparationTime: _settings.preparationTime,
              shootingTime: _settings.shootingTime,
              warningTime: value,
              practiceRounds: _settings.practiceRounds,
              matchRounds: _settings.matchRounds,
              shootingStyle: _settings.shootingStyle,
            );
            _saveSettings();
          });
        },
        onPracticeRoundsChanged: (value) {
          setState(() {
            _settings = Settings(
              preparationTime: _settings.preparationTime,
              shootingTime: _settings.shootingTime,
              warningTime: _settings.warningTime,
              practiceRounds: value,
              matchRounds: _settings.matchRounds,
              shootingStyle: _settings.shootingStyle,
            );
            _saveSettings();
          });
        },
        onMatchRoundsChanged: (value) {
          setState(() {
            _settings = Settings(
              preparationTime: _settings.preparationTime,
              shootingTime: _settings.shootingTime,
              warningTime: _settings.warningTime,
              practiceRounds: _settings.practiceRounds,
              matchRounds: value,
              shootingStyle: _settings.shootingStyle,
            );
            _saveSettings();
          });
        },
        onShootingStyleChanged: (value) {
          setState(() {
            _settings = Settings(
              preparationTime: _settings.preparationTime,
              shootingTime: _settings.shootingTime,
              warningTime: _settings.warningTime,
              practiceRounds: _settings.practiceRounds,
              matchRounds: _settings.matchRounds,
              shootingStyle: value,
            );
            _saveSettings();
          });
        },
      ),
    );
  }
}
