import 'package:flutter/material.dart';
import '../models/settings.dart';
import '../models/shooting_style.dart';
import '../services/sound_service.dart';
import 'shooting_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final Settings settings;
  final SoundService soundService;
  final Function(int) onPreparationTimeChanged;
  final Function(int) onShootingTimeChanged;
  final Function(int) onWarningTimeChanged;
  final Function(int) onPracticeRoundsChanged;
  final Function(int) onMatchRoundsChanged;
  final Function(ShootingStyle) onShootingStyleChanged;

  const WelcomeScreen({
    super.key,
    required this.settings,
    required this.soundService,
    required this.onPreparationTimeChanged,
    required this.onShootingTimeChanged,
    required this.onWarningTimeChanged,
    required this.onPracticeRoundsChanged,
    required this.onMatchRoundsChanged,
    required this.onShootingStyleChanged,
  });

  void _startShooting(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ShootingScreen(
          preparationTime: settings.preparationTime,
          shootingTime: settings.shootingTime,
          warningTime: settings.warningTime,
          practiceRounds: settings.practiceRounds,
          matchRounds: settings.matchRounds,
          shotsPerSet: 2,
          shootingStyle: settings.shootingStyle,
          soundService: soundService,
          onReset: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WelcomeScreen(
                  settings: settings,
                  soundService: soundService,
                  onPreparationTimeChanged: onPreparationTimeChanged,
                  onShootingTimeChanged: onShootingTimeChanged,
                  onWarningTimeChanged: onWarningTimeChanged,
                  onPracticeRoundsChanged: onPracticeRoundsChanged,
                  onMatchRoundsChanged: onMatchRoundsChanged,
                  onShootingStyleChanged: onShootingStyleChanged,
                ),
              ),
            );
          },
          onPreparationTimeChanged: onPreparationTimeChanged,
          onShootingTimeChanged: onShootingTimeChanged,
          onWarningTimeChanged: onWarningTimeChanged,
          onPracticeRoundsChanged: onPracticeRoundsChanged,
          onMatchRoundsChanged: onMatchRoundsChanged,
          onShootingStyleChanged: onShootingStyleChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 32),
            const Text(
              'Ottoman Archery Timer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 64),
            ElevatedButton(
              onPressed: () => _startShooting(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: Text(
                'BAŞLA',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
