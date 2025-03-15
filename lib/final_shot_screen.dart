import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'shot_report_screen.dart';
import 'services/sound_service.dart';

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

  int archer1Shots = 0;
  int archer2Shots = 0;

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
        archer1Shots++;
      } else {
        rightArcherTimes.add(currentShotDuration);
        archer2Shots++;
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
            onPressed: () {
              // Ayarlar sayfasına git
            },
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
                  children: [
                    // 1. Yarışmacı (Yeşil)
                    Expanded(
                      child: GestureDetector(
                        onTap: !isRunning ? () => selectArcher(true) : null,
                        child: Card(
                          color: Colors.green,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person, size: 48, color: Colors.white),
                                const SizedBox(height: 8),
                                const Text(
                                  '1. YARIŞMACI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$archer1Shots / $totalShots',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 2. Yarışmacı (Kırmızı)
                    Expanded(
                      child: GestureDetector(
                        onTap: !isRunning ? () => selectArcher(false) : null,
                        child: Card(
                          color: Colors.red,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person, size: 48, color: Colors.white),
                                const SizedBox(height: 8),
                                const Text(
                                  '2. YARIŞMACI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$archer2Shots / $totalShots',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
