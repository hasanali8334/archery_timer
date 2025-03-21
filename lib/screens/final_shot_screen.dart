import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../shot_report_screen.dart';
import '../services/sound_service.dart';
import '../screens/final_shot_settings_screen.dart';

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
  bool isPaused = false;
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        builder:
            (context) => FinalShotSettingsScreen(
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
      _timer?.cancel();

      if (isLeftArcherActive) {
        if (archer1Shots < totalShots) {
          leftArcherTimes.add(currentShotDuration);
          setState(() {
            archer1Shots++;
          });
        }
      } else {
        if (archer2Shots < totalShots) {
          rightArcherTimes.add(currentShotDuration);
          setState(() {
            archer2Shots++;
          });
        }
      }

      // Her iki yarışmacı da atışlarını tamamladı mı kontrol et
      if (archer1Shots >= totalShots && archer2Shots >= totalShots) {
        _playSound('whistle');
        _resetScreen();
        return;
      }

      setState(() {
        isLeftArcherActive = !isLeftArcherActive;
        currentShotDuration = 0;
        remainingTime = shootingTime;
      });

      _startCountdown(); // Yeni süre için geri sayımı başlat
    }
  }

  void _resetScreen() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      isArcherSelected = false;
      isPreparationPhase = true;
      isShootingPhase = false;
      remainingTime = preparationTime;
      archer1Shots = 0;
      archer2Shots = 0;
      leftArcherTimes.clear();
      rightArcherTimes.clear();
    });
  }

  void _checkIfFinished() {
    if (archer1Shots >= totalShots && archer2Shots >= totalShots) {
      _playSound('whistle');
      _resetScreen();
    }
  }

  void _startCountdown({bool continueFromPause = false}) {
    _timer?.cancel();
    if (!continueFromPause) {
      _playSound('whistle');
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPaused) {
        timer.cancel();
        return;
      }

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
          timer.cancel();
          if (isPreparationPhase) {
            // Hazırlık süresi bitti, atış süresine geç
            isPreparationPhase = false;
            isShootingPhase = true;
            remainingTime = shootingTime;
            currentShotDuration = 0;
            _startCountdown(); // Yeni süre için geri sayımı başlat
          } else if (isShootingPhase) {
            // Atış süresi bittiğinde düdük çal
            _playSound('whistle');

            // Atış süresini kaydet
            if (isLeftArcherActive) {
              if (archer1Shots < totalShots) {
                leftArcherTimes.add(currentShotDuration);
                setState(() {
                  archer1Shots++;
                });
              }
            } else {
              if (archer2Shots < totalShots) {
                rightArcherTimes.add(currentShotDuration);
                setState(() {
                  archer2Shots++;
                });
              }
            }

            // Her iki yarışmacı da atışlarını tamamladı mı kontrol et
            _checkIfFinished();

            // Eğer yarışma bitmemişse ve aktif yarışmacı atışlarını tamamlamamışsa diğer yarışmacıya geç
            if (isRunning) {
              bool canSwitchArcher =
                  isLeftArcherActive
                      ? archer1Shots < totalShots
                      : archer2Shots < totalShots;

              if (canSwitchArcher) {
                isLeftArcherActive = !isLeftArcherActive;
                currentShotDuration = 0;
                remainingTime = shootingTime;
                _startCountdown(); // Yeni süre için geri sayımı başlat
              } else {
                // Aktif yarışmacı atışlarını tamamladı, diğer yarışmacı tamamlamadıysa ona geç
                bool otherArcherCanShoot =
                    isLeftArcherActive
                        ? archer2Shots < totalShots
                        : archer1Shots < totalShots;

                if (otherArcherCanShoot) {
                  isLeftArcherActive = !isLeftArcherActive;
                  currentShotDuration = 0;
                  remainingTime = shootingTime;
                  _startCountdown(); // Yeni süre için geri sayımı başlat
                }
              }
            }
          }
        }
      });
    });
  }

  void _toggleTimer() {
    if (isRunning && !isPaused) {
      // Timer'ı durdur
      _timer?.cancel();
      setState(() {
        isPaused = true;
      });
    } else if (isRunning && isPaused) {
      // Timer'ı devam ettir
      setState(() {
        isPaused = false;
      });
      _startCountdown(continueFromPause: true);
    }
  }

  void showResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ShotReportScreen(
              leftArcherTimes: leftArcherTimes,
              rightArcherTimes: rightArcherTimes,
            ),
      ),
    );
  }

  String formatTime(int time) {
    return time.toString().padLeft(2, '0');
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _stopTimer();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Final Atışı'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _stopTimer();
              Navigator.pop(context);
            },
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
                        transform:
                            Matrix4.identity()
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
                        transform:
                            Matrix4.identity()
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
                                if (isRunning)
                                  Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: _toggleTimer,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isPaused ? Colors.green : Colors.red,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                        ),
                                        child: Text(
                                          isPaused ? 'DEVAM ET' : 'DURDUR',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      if (isShootingPhase && !isPaused)
                                        ElevatedButton(
                                          onPressed: () => switchArcher(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 32,
                                              vertical: 16,
                                            ),
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
      ),
    );
  }
}
