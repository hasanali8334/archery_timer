import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'shot_report_screen.dart';
import 'services/sound_service.dart';
import 'screens/final_shot_settings_screen.dart';

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
  bool isRunning = false;
  bool isArcherSelected = false;
  bool isPreparationPhase = true;
  bool isShootingPhase = false;
  bool isLeftArcherActive = true;
  late int remainingTime;
  int preparationTime = 10;
  int shootingTime = 20;
  int totalShots = 5;
  int warningTime = 10;
  int currentShotDuration = 0;
  List<int> leftArcherTimes = [];
  List<int> rightArcherTimes = [];
  int archer1Shots = 0;
  int archer2Shots = 0;
  String archer1Name = '1. YARIŞMACI';
  String archer2Name = '2. YARIŞMACI';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    remainingTime = preparationTime;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      shootingTime = prefs.getInt('finalShootingTime') ?? 20;
      totalShots = prefs.getInt('finalTotalShots') ?? 5;
      archer1Name = prefs.getString('finalArcher1Name') ?? '1. YARIŞMACI';
      archer2Name = prefs.getString('finalArcher2Name') ?? '2. YARIŞMACI';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('finalShootingTime', shootingTime);
    await prefs.setInt('finalTotalShots', totalShots);
    await prefs.setString('finalArcher1Name', archer1Name);
    await prefs.setString('finalArcher2Name', archer2Name);
  }

  void _showSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinalShotSettingsScreen(
          shootingTime: shootingTime,
          totalShots: totalShots,
          archer1Name: archer1Name,
          archer2Name: archer2Name,
          onShootingTimeChanged: (value) {
            setState(() {
              shootingTime = value;
            });
            _saveSettings();
          },
          onTotalShotsChanged: (value) {
            setState(() {
              totalShots = value;
            });
            _saveSettings();
          },
          onArcher1NameChanged: (value) {
            setState(() {
              archer1Name = value;
            });
            _saveSettings();
          },
          onArcher2NameChanged: (value) {
            setState(() {
              archer2Name = value;
            });
            _saveSettings();
          },
        ),
      ),
    );
  }

  void _playSound(String soundType) {
    if (soundType == 'whistle') {
      widget.soundService.playWhistle();
    } else if (soundType == 'beep') {
      widget.soundService.playBeep();
    }
  }

  void selectArcher(bool isLeft) {
    if (!isRunning && !isArcherSelected) {
      setState(() {
        isArcherSelected = true;
        isLeftArcherActive = isLeft;
        isPreparationPhase = true;
        isShootingPhase = false;
        remainingTime = preparationTime;
        isRunning = true;
      });
      _startCountdown();
    }
  }

  void switchArcher() {
    if (isRunning && isShootingPhase) {
      if (isLeftArcherActive) {
        leftArcherTimes.add(currentShotDuration);
        archer1Shots++;
      } else {
        rightArcherTimes.add(currentShotDuration);
        archer2Shots++;
      }
      
      setState(() {
        isLeftArcherActive = !isLeftArcherActive;
        currentShotDuration = 0;
        remainingTime = shootingTime;
      });
      _playSound('whistle');
    }
  }

  void _startCountdown() {
    _playSound('whistle');

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
          
          if (isShootingPhase) {
            currentShotDuration++;
            
            // Uyarı süresi kontrolü
            if (remainingTime <= warningTime) {
              _playSound('beep');
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
          } else if (isShootingPhase) {
            // Atış süresi bittiğinde düdük çal
            _playSound('whistle');
            isShootingPhase = false;
            
            if (isLeftArcherActive) {
              leftArcherTimes.add(currentShotDuration);
              archer1Shots++;
            } else {
              rightArcherTimes.add(currentShotDuration);
              archer2Shots++;
            }
            
            if (leftArcherTimes.length >= totalShots && rightArcherTimes.length >= totalShots) {
              timer.cancel();
              isRunning = false;
              showResults();
            } else {
              isLeftArcherActive = !isLeftArcherActive;
              currentShotDuration = 0;
              remainingTime = shootingTime;
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

  String formatTime(int time) {
    int minutes = time ~/ 60;
    int seconds = time % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Final Atışı'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onReset,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsScreen,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Üst kısım: Yarışmacı kartları
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Sol yarışmacı kartı
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: isLeftArcherActive ? 180 : 150,
                      height: isLeftArcherActive ? 220 : 180,
                      transform: Matrix4.identity()
                        ..translate(0.0, isLeftArcherActive ? -20.0 : 0.0),
                      decoration: BoxDecoration(
                        color: isLeftArcherActive ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => selectArcher(true),
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                size: isLeftArcherActive ? 56 : 48,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                archer1Name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isLeftArcherActive ? 22 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Atış: $archer1Shots/$totalShots',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isLeftArcherActive ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Sağ yarışmacı kartı
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: !isLeftArcherActive ? 180 : 150,
                      height: !isLeftArcherActive ? 220 : 180,
                      transform: Matrix4.identity()
                        ..translate(0.0, !isLeftArcherActive ? -20.0 : 0.0),
                      decoration: BoxDecoration(
                        color: !isLeftArcherActive ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => selectArcher(false),
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                size: !isLeftArcherActive ? 56 : 48,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                archer2Name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: !isLeftArcherActive ? 22 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Atış: $archer2Shots/$totalShots',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: !isLeftArcherActive ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Orta kısım: Timer veya başlangıç mesajı
              Expanded(
                flex: 2,
                child: Card(
                  color: Colors.orange,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isRunning && !isArcherSelected)
                          const Text(
                            'Başlamak için\nyarışmacı seçin',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Column(
                            children: [
                              Text(
                                formatTime(remainingTime),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 72,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (isRunning && isShootingPhase)
                                ElevatedButton(
                                  onPressed: () => switchArcher(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  ),
                                  child: const Text(
                                    'DİĞER YARIŞMACIYA GEÇ',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Alt kısım: Sıfırla butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Sıfırla',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
