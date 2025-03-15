import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/shooting_screen.dart';
import 'screens/settings_screen.dart';
import 'services/sound_service.dart';
import 'models/shooting_style.dart';
import 'final_shot_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Okçuluk Zamanlayıcı',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.blue.shade700,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/final_shot': (context) => FinalShotScreen(
          soundService: SoundService(),
          onReset: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          ),
        ),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final SoundService _soundService = SoundService();
  int _preparationTime = 10;
  int _shootingTime = 120;
  int _warningTime = 30;
  int _practiceRounds = 0;
  int _matchRounds = 12;
  ShootingStyle _shootingStyle = ShootingStyle.donusumsuzABCD;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _preparationTime = prefs.getInt('preparationTime') ?? 10;
      _shootingTime = prefs.getInt('shootingTime') ?? 120;
      _warningTime = prefs.getInt('warningTime') ?? 30;
      _practiceRounds = prefs.getInt('practiceRounds') ?? 0;
      _matchRounds = prefs.getInt('matchRounds') ?? 12;
      _shootingStyle = ShootingStyle.values[prefs.getInt('shootingStyle') ?? 0];
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('preparationTime', _preparationTime);
    await prefs.setInt('shootingTime', _shootingTime);
    await prefs.setInt('warningTime', _warningTime);
    await prefs.setInt('practiceRounds', _practiceRounds);
    await prefs.setInt('matchRounds', _matchRounds);
    await prefs.setInt('shootingStyle', _shootingStyle.index);
  }

  void _resetTimer() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }

  void _showSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          preparationTime: _preparationTime,
          shootingTime: _shootingTime,
          warningTime: _warningTime,
          practiceRounds: _practiceRounds,
          matchRounds: _matchRounds,
          shootingStyle: _shootingStyle,
          onPreparationTimeChanged: (value) {
            setState(() {
              _preparationTime = value;
            });
            _saveSettings();
          },
          onShootingTimeChanged: (value) {
            setState(() {
              _shootingTime = value;
            });
            _saveSettings();
          },
          onWarningTimeChanged: (value) {
            setState(() {
              _warningTime = value;
            });
            _saveSettings();
          },
          onPracticeRoundsChanged: (value) {
            setState(() {
              _practiceRounds = value;
            });
            _saveSettings();
          },
          onMatchRoundsChanged: (value) {
            setState(() {
              _matchRounds = value;
            });
            _saveSettings();
          },
          onShootingStyleChanged: (value) {
            setState(() {
              _shootingStyle = value;
            });
            _saveSettings();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _soundService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Okçuluk Zamanlayıcı'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsScreen,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ShootingScreen(
              onReset: _resetTimer,
              soundService: _soundService,
              shootingTime: _shootingTime,
              warningTime: _warningTime,
              shootingStyle: _shootingStyle,
              practiceRounds: _practiceRounds,
              preparationTime: _preparationTime,
              matchRounds: _matchRounds,
              shotsPerSet: 6,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FinalShotScreen(
                      soundService: _soundService,
                      onReset: _resetTimer,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'FİNAL ATIŞI',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
