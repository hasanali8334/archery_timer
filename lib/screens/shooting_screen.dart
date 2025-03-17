import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import '../models/shooting_style.dart';

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
  });

  @override
  State<ShootingScreen> createState() => _ShootingScreenState();
}

class _ShootingScreenState extends State<ShootingScreen> {
  Timer? _timer;
  bool isRunning = false;
  bool isPreparationPhase = true;
  bool isABGroup = true;
  late int remainingTime;
  int currentShotInSet = 1;
  int currentSet = 1;
  bool isPracticeRound = false;
  bool isPaused = false;
  bool isMatchFinished = false;

  @override
  void initState() {
    super.initState();
    // Deneme atışı varsa deneme ile başla, yoksa yarışma ile başla
    isPracticeRound = widget.practiceRounds > 0;
    currentSet = 1;
    currentShotInSet = 1;
    isABGroup = true;
    isPreparationPhase = true;
    remainingTime = widget.preparationTime;
    _updateTargetGroup();
    isPaused = false;
    isMatchFinished = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTargetGroup() {
    if (widget.shootingStyle == ShootingStyle.standard) {
      isABGroup = true;
    } else if (widget.shootingStyle == ShootingStyle.alternating) {
      isABGroup = currentSet == 1;
    } else {
      if (currentSet % 2 == 1) {
        isABGroup = currentSet == 1;
      } else {
        isABGroup = currentSet == 2;
      }
    }
  }

  void _playSound(String soundType) {
    if (soundType == 'whistle') {
      widget.soundService.playWhistle();
    } else if (soundType == 'beep') {
      widget.soundService.playBeep();
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void _startTimer() {
    setState(() {
      isRunning = true;
    });

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
    _stopTimer();

    print('DEBUG - Önceki durum:');
    print(
      'Set: $currentSet / ${isPracticeRound ? widget.practiceRounds : widget.matchRounds}',
    );
    print('Atış: $currentShotInSet / 2');
    print('Grup: ${isABGroup ? "AB" : "CD"}');
    print('Mod: ${isPracticeRound ? "Deneme" : "Yarışma"}');

    setState(() {
      isPreparationPhase = true;
      remainingTime = widget.preparationTime;

      // Sonraki atışa geç
      if (currentShotInSet < 2) {
        currentShotInSet++;
        // Sadece dönüşümlü atışta CD'ye geç
        if (widget.shootingStyle == ShootingStyle.rotating) {
          isABGroup = !isABGroup;
        }
        print('DEBUG - Sonraki atışa geçildi');
        return;
      }

      // Set bitti, sıfırla
      currentShotInSet = 1;
      isABGroup = true;

      // Set kontrolü
      if (isPracticeRound && widget.practiceRounds > 0) {
        // Deneme atışları
        if (currentSet >= widget.practiceRounds) {
          // Deneme bitti, yarışmaya geç
          isPracticeRound = false;
          currentSet = 1;
          print('DEBUG - Deneme bitti, yarışma başlıyor');
          return;
        }
      } else {
        // Yarışma atışları
        if (currentSet >= widget.matchRounds) {
          isMatchFinished = true;
          print('DEBUG - Yarışma bitti!');
          return;
        }
      }

      // Sonraki sete geç
      currentSet++;
      print('DEBUG - Sonraki sete geçildi: $currentSet');

      // Atış stiline göre başlangıç grubunu belirle
      switch (widget.shootingStyle) {
        case ShootingStyle.rotating:
          isABGroup = currentSet % 2 == 1;
          break;
        default:
          isABGroup = true;
          break;
      }
    });

    print('DEBUG - Sonraki durum:');
    print(
      'Set: $currentSet / ${isPracticeRound ? widget.practiceRounds : widget.matchRounds}',
    );
    print('Atış: $currentShotInSet / 2');
    print('Grup: ${isABGroup ? "AB" : "CD"}');
    print('Mod: ${isPracticeRound ? "Deneme" : "Yarışma"}');
    print('-------------------');
  }

  void stopTimer() {
    setState(() {
      isRunning = false;
      isPaused = true;
    });
  }

  void continueTimer() {
    setState(() {
      isPaused = false;
    });
    _startTimer();
  }

  void resetTimer() {
    setState(() {
      isRunning = false;
      isPaused = false;
      remainingTime =
          isPreparationPhase ? widget.preparationTime : widget.shootingTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color timerColor =
        isPreparationPhase
            ? Colors.orange
            : (remainingTime <= widget.warningTime
                ? Colors.orange
                : Colors.green);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Üst kısım (AB/CD göstergesi)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  isABGroup ? 'AB GRUBU' : 'CD GRUBU',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Set ve atış bilgisi
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPracticeRound ? 'DENEME ATIŞI' : 'YARIŞMA ATIŞI',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${currentSet}. SET - ${currentShotInSet}. ATIŞ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Timer ve butonlar
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: timerColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        remainingTime.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 96,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!isRunning)
                      Container(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text(
                          isPreparationPhase ? 'HAZIRLIK' : 'ATIŞ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed:
                            isMatchFinished
                                ? null
                                : (isRunning ? _stopTimer : _startTimer),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isRunning ? Colors.red : Colors.green,
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
                        onPressed: isMatchFinished ? null : _finishShot,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
