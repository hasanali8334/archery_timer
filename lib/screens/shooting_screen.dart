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
  bool isShootingPhase = false;
  bool isABGroup = true;
  late int remainingTime;
  int currentShotInSet = 1; // 1-2 arası atış sırası (AB veya CD için)
  int currentSet = 1; // 1-2 arası set sırası (her seride 2 set var)
  int currentRound = 1; // Mevcut seri sayısı
  bool isPracticeRound = true;
  bool isPaused = false;
  int currentShotDuration = 0;
  int _practiceRoundCount = 0;
  bool isMatchFinished = false;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.preparationTime;
    _updateTargetGroup();
    isPaused = false;
    _practiceRoundCount = 0;
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

          // Uyarı süresi kontrolü
          if (!isPreparationPhase && remainingTime == widget.warningTime) {
            _playSound('beep'); // Uyarı başlangıcında tek beep
          }

          // Son 5 saniye kontrolü
          if (!isPreparationPhase && remainingTime <= 5 && remainingTime > 0) {
            _playSound('beep');
          }
        } else {
          _timer?.cancel();
          isRunning = false;
          _playSound('whistle');

          if (isPreparationPhase) {
            // Hazırlık süresi bitti, atış süresine geç
            setState(() {
              isPreparationPhase = false;
              remainingTime = widget.shootingTime;
            });
            _startTimer();
          } else {
            // Atış süresi bitti, sonraki atışa geç
            _finishShot();
          }
        }
      });
    });
  }

  void _finishShot() {
    _stopTimer();

    print('DEBUG - Önceki durum:');
    print('Set: $currentSet / ${widget.matchRounds}');
    print('Atış: $currentShotInSet / 2');
    print('Grup: ${isABGroup ? "AB" : "CD"}');
    print('Deneme: $isPracticeRound');

    // Yarışma bitti mi kontrolü
    if (!isPracticeRound && currentSet >= widget.matchRounds && currentShotInSet >= 2) {
      setState(() {
        isMatchFinished = true;
      });
      print('DEBUG - Yarışma bitti!');
      return;
    }

    setState(() {
      isPreparationPhase = true;
      remainingTime = widget.preparationTime;

      // Deneme atışları tamamlandıysa yarışma atışlarına geç
      if (widget.practiceRounds > 0) {
        if (currentSet > _practiceRoundCount && isPracticeRound) {
          _practiceRoundCount++;
          if (_practiceRoundCount >= widget.practiceRounds) {
            isPracticeRound = false;
            currentSet = 1;
            currentShotInSet = 1;
            isABGroup = true;
            print('DEBUG - Deneme atışları bitti!');
            return;
          }
        }
      }

      // Atış bitti mi kontrolü
      if (currentShotInSet >= 2) {  // Her sette 2 atış: 1 AB + 1 CD
        // Yeni set başlat
        currentShotInSet = 1;
        currentSet++;

        // Atış stiline göre başlangıç grubunu belirle
        switch (widget.shootingStyle) {
          case ShootingStyle.standard:
          case ShootingStyle.alternating:
            isABGroup = true;  // Her sette AB başlar
            break;
          case ShootingStyle.rotating:
            isABGroup = currentSet % 2 == 1;  // Tek setlerde AB, çift setlerde CD başlar
            break;
        }
      } else {
        // Sonraki atışa geç
        currentShotInSet++;
        isABGroup = !isABGroup;  // AB -> CD veya CD -> AB
      }
    });

    print('DEBUG - Sonraki durum:');
    print('Set: $currentSet / ${widget.matchRounds}');
    print('Atış: $currentShotInSet / 2');
    print('Grup: ${isABGroup ? "AB" : "CD"}');
    print('Deneme: $isPracticeRound');
    print('-------------------');
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

  String _formatTime(int seconds) {
    return '$seconds';
  }

  // Sonraki atış bilgisini döndürür
  String _getNextShotInfo() {
    if (isMatchFinished) {
      return 'YARIŞMA BİTTİ';
    }
    return '${isABGroup ? 'AB' : 'CD'} GRUBU\n${currentSet}. SET - ${currentShotInSet}. ATIŞ';
  }

  @override
  Widget build(BuildContext context) {
    // Timer arkaplan rengi
    Color timerColor = isPreparationPhase
        ? Colors.orange
        : (remainingTime <= widget.warningTime ? Colors.orange : Colors.green);

    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: SafeArea(
        child: Column(
          children: [
            // Üst kısım (AB/CD göstergesi)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: 1.0,
                  child: Text(
                    isMatchFinished ? 'BİTTİ' : (isABGroup ? 'AB' : 'CD'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Deneme/Yarış serisi göstergesi
            if (widget.practiceRounds > 0 && !isMatchFinished)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isPracticeRound ? 'DENEME SERİSİ' : 'YARIŞ SERİSİ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${currentSet}. SET - ${currentShotInSet}. ATIŞ',
                    style: TextStyle(
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Süre göstergesi
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: timerColor,
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
                    // Sonraki atış bilgisi
                    if (!isRunning)
                      Container(
                        padding: const EdgeInsets.only(top: 24),
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            _getNextShotInfo(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Alt kısım (butonlar)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Üst sıra butonları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: isMatchFinished ? null : (isRunning ? _stopTimer : _startTimer),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRunning ? Colors.orange : Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          isRunning ? 'DURDUR' : 'BAŞLAT',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: isMatchFinished ? null : _finishShot,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'BİTİR',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Alt sıra butonu
                  ElevatedButton(
                    onPressed: widget.onReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'SIFIRLA',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
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
