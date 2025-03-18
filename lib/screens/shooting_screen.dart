import 'dart:async';
import 'package:flutter/material.dart';
import '../models/shooting_style.dart';
import '../services/sound_service.dart';
import 'settings_screen.dart';
import 'final_shot_screen.dart';

class ShootingScreen extends StatefulWidget {
  final Function() onReset;
  final SoundService soundService;
  final int shootingTime;
  final int warningTime;
  final int practiceRounds;
  final int preparationTime;
  final int matchRounds;
  final int shotsPerSet;
  final ShootingStyle shootingStyle;
  final Function(int) onPreparationTimeChanged;
  final Function(int) onShootingTimeChanged;
  final Function(int) onWarningTimeChanged;
  final Function(int) onPracticeRoundsChanged;
  final Function(int) onMatchRoundsChanged;
  final Function(ShootingStyle) onShootingStyleChanged;

  const ShootingScreen({
    super.key,
    required this.onReset,
    required this.soundService,
    required this.shootingTime,
    required this.warningTime,
    required this.practiceRounds,
    required this.preparationTime,
    required this.matchRounds,
    required this.shotsPerSet,
    required this.shootingStyle,
    required this.onPreparationTimeChanged,
    required this.onShootingTimeChanged,
    required this.onWarningTimeChanged,
    required this.onPracticeRoundsChanged,
    required this.onMatchRoundsChanged,
    required this.onShootingStyleChanged,
  });

  @override
  State<ShootingScreen> createState() => _ShootingScreenState();
}

class _ShootingScreenState extends State<ShootingScreen> {
  bool isRunning = false;
  bool isPreparationPhase = true;
  bool isPracticeRound = false;
  Timer? _timer;
  int remainingTime = 0;
  int currentSet = 1;
  int currentShotInSet = 1;

  @override
  void initState() {
    super.initState();
    // Deneme atışı 0'dan büyükse deneme ile başla, değilse yarışma ile başla
    isPracticeRound = false;
    currentSet = 1;
    currentShotInSet = 1;
    remainingTime = widget.preparationTime;
    isPreparationPhase = true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _playSound(String soundType) {
    if (soundType == 'whistle') {
      widget.soundService.playWhistle();
    } else if (soundType == 'beep') {
      widget.soundService.playBeep();
    }
  }

  void _startTimer() {
    setState(() {
      isRunning = true;
    });
    _playSound('whistle');

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;

          if (!isPreparationPhase && remainingTime == widget.warningTime) {
            _playSound('beep');
          }

          if (!isPreparationPhase && remainingTime <= 5 && remainingTime > 0) {
            _playSound('beep');
          }
        } else {
          _timer?.cancel();
          isRunning = false;
          _playSound('whistle');

          if (isPreparationPhase) {
            setState(() {
              isPreparationPhase = false;
              remainingTime = widget.shootingTime;
            });
            _startTimer();
          } else {
            _finishShot();
          }
        }
      });
    });
  }

  void _finishShot() {
    print('DEBUG - Atış bitti');
    print('Mevcut durum:');
    print(
      'Set: $currentSet / ${widget.matchRounds}',
    );
    print('Atış: $currentShotInSet / 2');
    print('Mod: "Yarışma"');

    setState(() {
      isPreparationPhase = true;
      remainingTime = widget.preparationTime;

      // Sonraki atışa geç
      if (currentShotInSet < 2) {
        currentShotInSet++;
        print('DEBUG - Sonraki atışa geçildi');
        return;
      }

      // Set bitti, sıfırla
      currentShotInSet = 1;

      // Set kontrolü
      if (currentSet >= widget.matchRounds) {
        print('DEBUG - Yarışma bitti!');
        return;
      }
      // Sonraki sete geç
      currentSet++;
      print('DEBUG - Sonraki sete geçildi: $currentSet');
    });

    print('DEBUG - Sonraki durum:');
    print(
      'Set: $currentSet / ${widget.matchRounds}',
    );
    print('Atış: $currentShotInSet / 2');
    print('Mod: "Yarışma"');
    print('-------------------');
  }

  void stopTimer() {
    setState(() {
      isRunning = false;
    });
  }

  void continueTimer() {
    _startTimer();
  }

  void resetTimer() {
    setState(() {
      isRunning = false;
      remainingTime =
          isPreparationPhase ? widget.preparationTime : widget.shootingTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color timerColor = isPreparationPhase
        ? Colors.orange
        : (remainingTime <= widget.warningTime ? Colors.orange : Colors.green);

    String phaseText = isPreparationPhase 
        ? 'HAZIRLIK'
        : 'Set $currentSet/${widget.matchRounds}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ottoman Archery Timer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SettingsScreen(
                            preparationTime: widget.preparationTime,
                            shootingTime: widget.shootingTime,
                            warningTime: widget.warningTime,
                            practiceRounds: widget.practiceRounds,
                            matchRounds: widget.matchRounds,
                            shootingStyle: widget.shootingStyle,
                            onPreparationTimeChanged:
                                widget.onPreparationTimeChanged,
                            onShootingTimeChanged: widget.onShootingTimeChanged,
                            onWarningTimeChanged: widget.onWarningTimeChanged,
                            onPracticeRoundsChanged:
                                widget.onPracticeRoundsChanged,
                            onMatchRoundsChanged: widget.onMatchRoundsChanged,
                            onShootingStyleChanged:
                                widget.onShootingStyleChanged,
                          ),
                    ),
                  );
                  break;
                case 'final_shot':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => FinalShotScreen(
                            soundService: widget.soundService,
                            onReset: widget.onReset,
                          ),
                    ),
                  );
                  break;
                case 'reset':
                  widget.onReset();
                  break;
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Ayarlar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'final_shot',
                    child: Row(
                      children: [
                        Icon(Icons.sports_score, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Final Atışı'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Sıfırla'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
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
              Text(
                phaseText,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: isRunning ? stopTimer : continueTimer,
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
                    onPressed: _finishShot,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'BİTİR',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Atış: $currentShotInSet / 2',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'YARIŞMA',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
