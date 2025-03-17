import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/shooting_style.dart';
import 'screens/shooting_screen.dart';
import 'services/sound_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Archery Timer',
      theme: ThemeData.dark(),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _soundService = SoundService();
  int _preparationTime = 10;
  int _shootingTime = 240;
  int _warningTime = 30;
  int _practiceRounds = 2;
  int _matchRounds = 12;
  ShootingStyle _shootingStyle = ShootingStyle.standard;

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('preparationTime', _preparationTime);
    prefs.setInt('shootingTime', _shootingTime);
    prefs.setInt('warningTime', _warningTime);
    prefs.setInt('practiceRounds', _practiceRounds);
    prefs.setInt('matchRounds', _matchRounds);
    prefs.setInt('shootingStyle', _shootingStyle.index);
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _preparationTime = prefs.getInt('preparationTime') ?? 10;
      _shootingTime = prefs.getInt('shootingTime') ?? 240;
      _warningTime = prefs.getInt('warningTime') ?? 30;
      _practiceRounds = prefs.getInt('practiceRounds') ?? 2;
      _matchRounds = prefs.getInt('matchRounds') ?? 12;
      _shootingStyle = ShootingStyle.values[prefs.getInt('shootingStyle') ?? 0];
    });
  }

  void _onReset() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _soundService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShootingScreen(
      preparationTime: _preparationTime,
      shootingTime: _shootingTime,
      warningTime: _warningTime,
      practiceRounds: _practiceRounds,
      matchRounds: _matchRounds,
      shootingStyle: _shootingStyle,
      soundService: _soundService,
      onReset: _onReset,
      shotsPerSet: 2,
      onPreparationTimeChanged: (value) {
        setState(() {
          _preparationTime = value;
          _saveSettings();
        });
      },
      onShootingTimeChanged: (value) {
        setState(() {
          _shootingTime = value;
          _saveSettings();
        });
      },
      onWarningTimeChanged: (value) {
        setState(() {
          _warningTime = value;
          _saveSettings();
        });
      },
      onPracticeRoundsChanged: (value) {
        setState(() {
          _practiceRounds = value;
          _saveSettings();
        });
      },
      onMatchRoundsChanged: (value) {
        setState(() {
          _matchRounds = value;
          _saveSettings();
        });
      },
      onShootingStyleChanged: (value) {
        setState(() {
          _shootingStyle = value;
          _saveSettings();
        });
      },
    );
  }
}
