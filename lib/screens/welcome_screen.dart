import 'package:flutter/material.dart';
import '../models/settings.dart';
import '../models/shooting_style.dart';
import '../services/sound_service.dart';
import 'shooting_screen.dart';

class WelcomeScreen extends StatefulWidget {
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

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ShootingScreen(
              preparationTime: widget.settings.preparationTime,
              shootingTime: widget.settings.shootingTime,
              warningTime: widget.settings.warningTime,
              practiceRounds: widget.settings.practiceRounds,
              matchRounds: widget.settings.matchRounds,
              shotsPerSet: 2,
              shootingStyle: widget.settings.shootingStyle,
              soundService: widget.soundService,
              onReset: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomeScreen(
                      settings: widget.settings,
                      soundService: widget.soundService,
                      onPreparationTimeChanged: widget.onPreparationTimeChanged,
                      onShootingTimeChanged: widget.onShootingTimeChanged,
                      onWarningTimeChanged: widget.onWarningTimeChanged,
                      onPracticeRoundsChanged: widget.onPracticeRoundsChanged,
                      onMatchRoundsChanged: widget.onMatchRoundsChanged,
                      onShootingStyleChanged: widget.onShootingStyleChanged,
                    ),
                  ),
                );
              },
              onPreparationTimeChanged: widget.onPreparationTimeChanged,
              onShootingTimeChanged: widget.onShootingTimeChanged,
              onWarningTimeChanged: widget.onWarningTimeChanged,
              onPracticeRoundsChanged: widget.onPracticeRoundsChanged,
              onMatchRoundsChanged: widget.onMatchRoundsChanged,
              onShootingStyleChanged: widget.onShootingStyleChanged,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 5,
            ),
            const SizedBox(height: 32),
            const Text(
              'Yükleniyor...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
