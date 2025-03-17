import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sound_service.dart';

class FinalShotScreen extends StatefulWidget {
  final SoundService soundService;
  final VoidCallback onReset;

  const FinalShotScreen({
    super.key,
    required this.soundService,
    required this.onReset,
  });

  @override
  State<FinalShotScreen> createState() => _FinalShotScreenState();
}

class _FinalShotScreenState extends State<FinalShotScreen> {
  Timer? _timer;
  bool isRunning = false;
  bool isPreparationPhase = true;
  int remainingTime = 10; // 10 saniye hazırlık
  static const int shootingTime = 40; // 40 saniye atış
  static const int warningTime = 10; // 10 saniye uyarı

  void _startTimer() {
    if (_timer != null) return;

    setState(() {
      isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;

          if (!isPreparationPhase && remainingTime == warningTime) {
            widget.soundService.playSound('beep');
          }

          if (!isPreparationPhase && remainingTime <= 5 && remainingTime > 0) {
            widget.soundService.playSound('beep');
          }

          if (remainingTime == 0) {
            widget.soundService.playSound('beep');
          }
        } else {
          _stopTimer();
          if (isPreparationPhase) {
            // Hazırlık bitti, atışa geç
            isPreparationPhase = false;
            remainingTime = shootingTime;
            _startTimer();
          }
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      isRunning = false;
    });
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      isPreparationPhase = true;
      remainingTime = 10;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color timerColor = isPreparationPhase
        ? Colors.orange
        : (remainingTime <= warningTime ? Colors.orange : Colors.green);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Final Atışı'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isPreparationPhase ? 'HAZIRLIK' : 'ATIŞ',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                remainingTime.toString(),
                style: TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: timerColor,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: isRunning ? _stopTimer : _startTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      isRunning ? 'DURDUR' : 'BAŞLAT',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _resetTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'SIFIRLA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
