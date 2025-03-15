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
    required this.shootingStyle,
  });

  @override
  State<ShootingScreen> createState() => _ShootingScreenState();
}

class _ShootingScreenState extends State<ShootingScreen> {
  Timer? _timer;
  bool isRunning = false;
  bool isPreparationPhase = true;
  bool isShootingPhase = false;
  bool isABGroup = true;
  late int remainingTime;
  int currentShotInSet = 1; // 1-2 arası atış sırası (AB veya CD için)
  int currentSet = 1; // 1-2 arası set sırası (her seride 2 set var)
  int currentRound = 1; // Mevcut seri sayısı
  bool isPracticeRound = true;
  bool isPaused = false;
  int currentShotDuration = 0;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.preparationTime;
    _updateTargetGroup();
    isPaused = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTargetGroup() {
    if (widget.shootingStyle == ShootingStyle.standart) {
      isABGroup = true;
    } else if (widget.shootingStyle == ShootingStyle.donusumsuzABCD) {
      // Dönüşümsüz: Set 1'de AB, Set 2'de CD atıyor
      isABGroup = currentSet == 1;
    } else {
      // Dönüşümlü: Tek sayılı serilerde AB-CD, çift sayılı serilerde CD-AB
      if (currentRound % 2 == 1) {
        // Tek sayılı seri
        isABGroup = currentSet == 1;
      } else {
        // Çift sayılı seri
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

  void _startCountdown() {
    _timer?.cancel();
    if (!isPaused) {
      _playSound('whistle');
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
          if (!isPreparationPhase) {
            currentShotDuration++;
            // Uyarı süresi kontrolü
            if (remainingTime <= widget.warningTime) {
              _playSound('beep');
            }
            // Son 5 saniye kontrolü
            if (remainingTime <= 5 && remainingTime > 0) {
              _playSound('beep');
            }
          }
        } else {
          timer.cancel();
          if (isPreparationPhase) {
            // Hazırlık süresi bitti, atış süresine geç
            isPreparationPhase = false;
            isShootingPhase = true;
            remainingTime = widget.shootingTime;
            currentShotDuration = 0;
            _startCountdown(); // Yeni süre için geri sayımı başlat
          } else if (isShootingPhase) {
            // Atış süresi bittiğinde düdük çal
            _playSound('whistle');
            isShootingPhase = false;
            isPreparationPhase = true;
            isABGroup = !isABGroup;
            remainingTime = widget.preparationTime;
            currentShotDuration = 0;
            isRunning = false;
            finishShot();
          }
        }
      });
    });
  }

  void _toggleTimer() {
    setState(() {
      if (!isRunning) {
        isRunning = true;
        _startCountdown();
      }
    });
  }

  void finishShot() {
    stopTimer();

    if (currentShotInSet == 2) {
      // Set tamamlandı
      if (currentSet == 2) {
        // Seri tamamlandı
        if (isPracticeRound && currentRound < widget.practiceRounds) {
          // Deneme serisi devam ediyor
          setState(() {
            currentShotInSet = 1;
            currentSet = 1;
            currentRound++;
            remainingTime = widget.preparationTime;
            isPreparationPhase = true;
          });
          _updateTargetGroup();
        } else if (isPracticeRound) {
          // Deneme serileri bitti, yarışma serilerine geç
          setState(() {
            isPracticeRound = false;
            currentShotInSet = 1;
            currentSet = 1;
            currentRound = 1;
            remainingTime = widget.preparationTime;
            isPreparationPhase = true;
          });
          _updateTargetGroup();
        } else if (currentRound >= widget.matchRounds) {
          // Yarışma serileri bitti, ana menüye dön
          widget.onReset();
        } else {
          // Sonraki seriye geç
          setState(() {
            currentShotInSet = 1;
            currentSet = 1;
            currentRound++;
            remainingTime = widget.preparationTime;
            isPreparationPhase = true;
          });
          _updateTargetGroup();
        }
      } else {
        // Sonraki sete geç
        setState(() {
          currentShotInSet = 1;
          currentSet++;
          remainingTime = widget.preparationTime;
          isPreparationPhase = true;
        });
        _updateTargetGroup();
      }
    } else {
      // Sonraki atışa geç
      setState(() {
        currentShotInSet++;
        remainingTime = widget.preparationTime;
        isPreparationPhase = true;
      });
      _updateTargetGroup();
    }
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
    _startCountdown();
  }

  void resetTimer() {
    setState(() {
      isRunning = false;
      isPaused = false;
      remainingTime =
          isPreparationPhase ? widget.preparationTime : widget.shootingTime;
    });
  }

  String _formatTime(int seconds) {
    return seconds.toString();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.blue.shade700;
    if (!isPreparationPhase && remainingTime <= 5 && remainingTime > 0) {
      backgroundColor = Colors.red;
    } else if (!isPreparationPhase && remainingTime <= widget.warningTime) {
      backgroundColor = Colors.orange;
    }

    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Üst kısım (AB/CD göstergesi)
          Container(
            color: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isABGroup ? 1.0 : 0.0,
                child: Text(
                  'AB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Orta kısım (Süre göstergesi)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Deneme atışı yazısı
                if (isPracticeRound && widget.practiceRounds > 0)
                  Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'DENEME ATIŞI',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                // Süre göstergesi
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPreparationPhase ? Colors.orange : Colors.green,
                  ),
                  child: Text(
                    _formatTime(remainingTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Alt kısım (Butonlar)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isRunning)
                ElevatedButton(
                  onPressed: _toggleTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    isPaused ? 'DEVAM ET' : 'BAŞLA',
                    style: const TextStyle(fontSize: 20),
                  ),
                )
              else ...[
                ElevatedButton(
                  onPressed: stopTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('DURDUR', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: finishShot,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('BİTİR', style: TextStyle(fontSize: 20)),
                ),
              ],
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: widget.onReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('ANA MENÜ', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
