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
  bool isRunning = false;
  bool isWarningTime = false;
  bool isBreakTime = false;
  bool isPracticeRound = true;
  bool isPreparationPhase = true;
  late int remainingTime;
  int currentShotInSet = 1; // 1-2 arası atış sırası (AB veya CD için)
  int currentSet = 1; // 1-2 arası set sırası (her seride 2 set var)
  int currentRound = 1; // Mevcut seri sayısı
  bool isGroupAB = true; // true = AB grubu, false = CD grubu
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.preparationTime;
    _updateTargetGroup();
    isPaused = false;
  }

  void _updateTargetGroup() {
    if (widget.shootingStyle == ShootingStyle.standart) {
      isGroupAB = true;
    } else if (widget.shootingStyle == ShootingStyle.donusumsuzABCD) {
      // Dönüşümsüz: AB-CD/AB-CD
      isGroupAB = currentSet == 1;
    } else {
      // Dönüşümlü: AB-CD/CD-AB
      isGroupAB = (currentRound % 2 == 1) ? currentSet == 1 : currentSet == 2;
    }
  }

  void startTimer() {
    if (!isRunning) {
      if (!isPaused) {
        widget.soundService.playWhistle();
      }
      setState(() {
        isRunning = true;
        isPaused = false;
      });
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && isRunning) {
        if (remainingTime > 0) {
          setState(() {
            remainingTime--;
            if (!isPreparationPhase &&
                remainingTime == widget.warningTime &&
                !isWarningTime) {
              isWarningTime = true;
              widget.soundService.playWarningBeep();
            }
            // Son 5 saniye kontrolü
            if (remainingTime <= 5 && remainingTime > 0) {
              widget.soundService.playBeep();
            }
          });
          startTimer();
        } else {
          widget.soundService.playLongBeep();
          if (isPreparationPhase) {
            // Hazırlık süresi bitti, atış süresine geç
            setState(() {
              isPreparationPhase = false;
              remainingTime = widget.shootingTime;
              isWarningTime = false;
            });
            startTimer(); // Atış süresini otomatik başlat
          } else {
            stopTimer();
          }
        }
      }
    });
  }

  void stopTimer() {
    setState(() {
      isRunning = false;
      isPaused = true;
    });
  }

  void continueTimer() {
    startTimer();
  }

  void finishShot() {
    widget.soundService.playLongBeep();
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
            isWarningTime = false;
            isBreakTime = false;
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
            isWarningTime = false;
            isBreakTime = false;
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
            isWarningTime = false;
            isBreakTime = false;
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
          isWarningTime = false;
          isBreakTime = true;
          isPreparationPhase = true;
        });
        _updateTargetGroup();
      }
    } else {
      // Sonraki atışa geç
      setState(() {
        currentShotInSet++;
        remainingTime = widget.preparationTime;
        isWarningTime = false;
        isPreparationPhase = true;
      });
      _updateTargetGroup();
    }
  }

  void continueAfterBreak() {
    setState(() {
      isBreakTime = false;
    });
    startTimer();
  }

  void resetTimer() {
    setState(() {
      isRunning = false;
      isPaused = false;
      remainingTime =
          isPreparationPhase ? widget.preparationTime : widget.shootingTime;
      isWarningTime = false;
    });
  }

  String formatTime(int seconds) {
    return seconds.toString();
  }

  String _getCurrentShotInfo() {
    String roundType = isPracticeRound ? 'DENEME' : 'YARIŞ';
    String roundCount =
        isPracticeRound
            ? '${currentRound}/${widget.practiceRounds}'
            : '${currentRound}/${widget.matchRounds}';
    String setInfo = '${currentSet}. SET';
    String shotInfo = '${currentShotInSet}. ATIŞ';

    return '$roundType SERİSİ $roundCount\n$setInfo - $shotInfo';
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.blue.shade700;
    if (!isPreparationPhase && remainingTime <= 5 && remainingTime > 0) {
      backgroundColor = Colors.red;
    } else if (!isPreparationPhase && isWarningTime) {
      backgroundColor = Colors.orange;
    }

    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // AB Grubu
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isGroupAB ? 200 : 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      isGroupAB
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white,
                    width: isGroupAB ? 2 : 1,
                  ),
                ),
                child: Text(
                  'AB',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isGroupAB ? 40 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // CD Grubu
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: !isGroupAB ? 200 : 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      !isGroupAB
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white,
                    width: !isGroupAB ? 2 : 1,
                  ),
                ),
                child: Text(
                  'CD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: !isGroupAB ? 40 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color:
                  isPracticeRound
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getCurrentShotInfo(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: isPracticeRound ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isPreparationPhase ? Colors.orange : Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isPreparationPhase ? 'HAZIRLIK' : 'ATIŞ',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isBreakTime)
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'MOLA',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color:
                        !isPreparationPhase &&
                                remainingTime <= 5 &&
                                remainingTime > 0
                            ? Colors.red
                            : (!isPreparationPhase && isWarningTime
                                ? Colors.orange
                                : (isPreparationPhase
                                    ? Colors.orange
                                    : Colors.green)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    formatTime(remainingTime),
                    style: const TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 40),
          if (isBreakTime)
            ElevatedButton(
              onPressed: continueAfterBreak,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('DEVAM ET', style: TextStyle(fontSize: 20)),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isRunning)
                  ElevatedButton(
                    onPressed: startTimer,
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
