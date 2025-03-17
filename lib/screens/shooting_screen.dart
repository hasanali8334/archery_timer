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
    isPracticeRound = false;  
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
    print('Set: $currentSet / ${widget.matchRounds}');
    print('Atış: $currentShotInSet / 2');
    print('Grup: ${isABGroup ? "AB" : "CD"}');

    setState(() {
      isPreparationPhase = true;
      remainingTime = widget.preparationTime;

      if (currentShotInSet < 2) {
        currentShotInSet++;
        isABGroup = !isABGroup;  
        print('DEBUG - Sonraki atışa geçildi');
        return;
      }

      currentShotInSet = 1;
      isABGroup = true;

      if (currentSet >= widget.matchRounds) {
        isMatchFinished = true;
        print('DEBUG - Yarışma bitti!');
        return;
      }

      currentSet++;
      print('DEBUG - Sonraki sete geçildi: $currentSet');

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
    print('Set: $currentSet / ${widget.matchRounds}');
    print('Atış: $currentShotInSet / 2');
    print('Grup: ${isABGroup ? "AB" : "CD"}');
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

  String _formatTime(int seconds) {
    return '$seconds';
  }

  String _getNextShotInfo() {
    if (isMatchFinished) {
      return 'YARIŞMA BİTTİ';
    }
    return '${isABGroup ? 'AB' : 'CD'} GRUBU\n${currentSet}. SET - ${currentShotInSet}. ATIŞ';
  }

  @override
  Widget build(BuildContext context) {
    Color timerColor = isPreparationPhase
        ? Colors.orange
        : (remainingTime <= widget.warningTime ? Colors.orange : Colors.green);

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
                      builder: (context) => SettingsScreen(
                        preparationTime: widget.preparationTime,
                        shootingTime: widget.shootingTime,
                        warningTime: widget.warningTime,
                        practiceRounds: widget.practiceRounds,
                        matchRounds: widget.matchRounds,
                        shootingStyle: widget.shootingStyle,
                        onPreparationTimeChanged: (value) {
                          setState(() {
                            widget.onPreparationTimeChanged(value);
                          });
                        },
                        onShootingTimeChanged: (value) {
                          setState(() {
                            widget.onShootingTimeChanged(value);
                          });
                        },
                        onWarningTimeChanged: (value) {
                          setState(() {
                            widget.onWarningTimeChanged(value);
                          });
                        },
                        onPracticeRoundsChanged: (value) {
                          setState(() {
                            widget.onPracticeRoundsChanged(value);
                          });
                        },
                        onMatchRoundsChanged: (value) {
                          setState(() {
                            widget.onMatchRoundsChanged(value);
                          });
                        },
                        onShootingStyleChanged: (value) {
                          setState(() {
                            widget.onShootingStyleChanged(value);
                          });
                        },
                      ),
                    ),
                  );
                  break;
                case 'final_shot':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FinalShotScreen(
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
            itemBuilder: (BuildContext context) => [
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
      backgroundColor: Colors.blue.shade700,
      body: SafeArea(
        child: Column(
          children: [
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
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
