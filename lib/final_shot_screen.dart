import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'shot_report_screen.dart';
import 'services/sound_service.dart';

class FinalShotScreen extends StatefulWidget {
  final SoundService soundService;
  const FinalShotScreen({
    super.key,
    required this.soundService,
  });

  @override
  State<FinalShotScreen> createState() => _FinalShotScreenState();
}

class _FinalShotScreenState extends State<FinalShotScreen> {
  bool isRunning = false;
  bool isPreparationPhase = false;
  bool isShootingPhase = false;
  Timer? _timer;
  bool _warningPlayed = false;
  bool preparationUsed = false;
  
  int preparationTime = 10;
  int shootingTime = 20;
  int totalShots = 3;
  int currentShotDuration = 0;
  int warningTime = 5;
  
  int remainingTime = 0;
  bool isLeftArcherActive = true;
  bool isArcherSelected = false;
  
  List<int> leftArcherTimes = [];
  List<int> rightArcherTimes = [];

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      preparationTime = prefs.getInt('preparationTime') ?? 10;
      shootingTime = prefs.getInt('shootingTime') ?? 20;
      warningTime = prefs.getInt('warningTime') ?? 5;
      totalShots = prefs.getInt('finalShotCount') ?? 3;
    });
  }

  void _playSound(String soundType) {
    if (soundType == 'whistle') {
      widget.soundService.playWhistle();
    } else if (soundType == 'beep') {
      widget.soundService.playBeep();
    }
  }

  void selectArcher(bool isLeft) {
    if (!isRunning && !preparationUsed) {
      setState(() {
        isArcherSelected = true;
        isLeftArcherActive = isLeft;
        isPreparationPhase = true;
        isShootingPhase = false;
        remainingTime = preparationTime;
        isRunning = true;
        preparationUsed = true;
      });
      _startCountdown();
    }
  }

  void switchArcher() {
    if (isRunning && isShootingPhase) {
      if (isLeftArcherActive) {
        leftArcherTimes.add(currentShotDuration);
      } else {
        rightArcherTimes.add(currentShotDuration);
      }
      
      setState(() {
        isLeftArcherActive = !isLeftArcherActive;
        currentShotDuration = 0;
        remainingTime = shootingTime;
        _warningPlayed = false;
      });
      _playSound('whistle');
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _playSound('whistle');
    _warningPlayed = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
          
          if (isShootingPhase) {
            currentShotDuration++;
            
            // Uyarı süresi kontrolü
            if (remainingTime <= warningTime && !_warningPlayed) {
              _playSound('beep');
              _warningPlayed = true;
            }
            // Son 5 saniye kontrolü
            if (remainingTime <= 5 && remainingTime > 0) {
              _playSound('beep');
            }
          }
        } else {
          if (isPreparationPhase) {
            // Hazırlık süresi bittiğinde düdük çal ve otomatik olarak atış süresine geç
            _playSound('whistle');
            isPreparationPhase = false;
            isShootingPhase = true;
            remainingTime = shootingTime;
            currentShotDuration = 0;
            _warningPlayed = false;
          } else if (isShootingPhase) {
            // Atış süresi bittiğinde düdük çal
            _playSound('whistle');
            isShootingPhase = false;
            
            if (isLeftArcherActive) {
              leftArcherTimes.add(currentShotDuration);
            } else {
              rightArcherTimes.add(currentShotDuration);
            }
            
            if (leftArcherTimes.length >= totalShots && rightArcherTimes.length >= totalShots) {
              timer.cancel();
              isRunning = false;
              showResults();
            } else {
              isLeftArcherActive = !isLeftArcherActive;
              currentShotDuration = 0;
              remainingTime = shootingTime;
              _warningPlayed = false;
              _playSound('whistle');
            }
          }
        }
      });
    });
  }

  void showResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShotReportScreen(
          leftArcherTimes: leftArcherTimes,
          rightArcherTimes: rightArcherTimes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue.shade700,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Sol Yarışmacı (AB)
                GestureDetector(
                  onTap: () => !isRunning && !preparationUsed ? selectArcher(true) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isLeftArcherActive ? 200 : 100,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isLeftArcherActive 
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white,
                        width: isLeftArcherActive ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'AB',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isLeftArcherActive ? 40 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (leftArcherTimes.isNotEmpty)
                          Text(
                            '${leftArcherTimes.length}/$totalShots',
                            style: TextStyle(
                              fontSize: isLeftArcherActive ? 24 : 16,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Sağ Yarışmacı (CD)
                GestureDetector(
                  onTap: () => !isRunning && !preparationUsed ? selectArcher(false) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: !isLeftArcherActive ? 200 : 100,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: !isLeftArcherActive 
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white,
                        width: !isLeftArcherActive ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'CD',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: !isLeftArcherActive ? 40 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (rightArcherTimes.isNotEmpty)
                          Text(
                            '${rightArcherTimes.length}/$totalShots',
                            style: TextStyle(
                              fontSize: !isLeftArcherActive ? 24 : 16,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'FİNAL ATIŞI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (!isArcherSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'YARIŞMACI SEÇİN',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: remainingTime <= warningTime && !isPreparationPhase
                    ? Colors.red 
                    : (isPreparationPhase ? Colors.orange : Colors.green),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isArcherSelected ? remainingTime.toString() : '0',
                style: const TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (isRunning && isShootingPhase)
              ElevatedButton(
                onPressed: switchArcher,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'DİĞER YARIŞMACIYA GEÇ',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'GERİ',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
