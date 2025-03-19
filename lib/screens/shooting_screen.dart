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
  bool isMatchFinished = false;
  Timer? _timer;
  int remainingTime = 0;
  int currentSet = 1;
  int currentShotInSet = 1;
  int currentSeri = 1;
  String shootinggroup = 'AB';
  List<String> seri = ['', 'AB', 'CD', 'CD', 'AB'];

  @override
  void initState() {
    super.initState();
    remainingTime = widget.preparationTime;
    isPracticeRound = widget.practiceRounds > 0;
    isPreparationPhase = true;
    currentSet = 1;
    currentShotInSet = 1;
    currentSeri = 1;
    _updateSeriList();
    _updateShootingGroup();
    print(
        'DEBUG - InitState: Set $currentSet, Shot $currentShotInSet, Seri $currentSeri, Grup $shootinggroup');
  }

  void _updateSeriList() {
    print('DEBUG - Shooting Style: ${widget.shootingStyle}');
    switch (widget.shootingStyle) {
      case ShootingStyle.standard:
        seri = ['', 'AB', 'AB', 'AB', 'AB'];
        break;
      case ShootingStyle.alternating:
        seri = ['', 'AB', 'CD', 'AB', 'CD'];
        break;
      case ShootingStyle.rotating:
        seri = ['', 'AB', 'CD', 'CD', 'AB'];
        break;
    }
    print('DEBUG - Seri Listesi: $seri');
  }

  void _updateShootingGroup() {
    if (widget.shootingStyle == ShootingStyle.standard) {
      shootinggroup = "AB";
    } else {
      // Rotating ve Alternating stiller için seri listesinden grubu al
      shootinggroup = _getShootingGroupForSeries(currentSeri);
      print(
          'DEBUG - Grup güncellendi: Seri $currentSeri -> Grup $shootinggroup');
    }
  }

  String _getShootingGroupForSeries(int seri) {
    List<String> seriesList = ["", "AB", "CD", "CD", "AB"];
    print(
        'DEBUG - Seri için grup seçiliyor: Seri $seri -> Grup ${seriesList[seri]}');
    return seriesList[seri];
  }

  void _onPhaseComplete() {
    // _timer?.cancel();
    setState(() {
      if (isPreparationPhase) {
        // Hazırlık fazı bitti, atış fazına geç
        isPreparationPhase = false;
        remainingTime = widget.shootingTime;
        widget.soundService.playWhistle();
        print('DEBUG - Atış fazına geçildi');
        return;
      }

      // Atış fazı bitti
      isPreparationPhase = true;
      remainingTime = widget.preparationTime;
      widget.soundService.playWhistle();

      // Sonraki atışa geç
      if (currentShotInSet < 2) {
        currentShotInSet++;
        print(
            'DEBUG - Atış öncesi: Set $currentSet, Shot $currentShotInSet, Seri $currentSeri, Grup $shootinggroup');

        // Her atış sonunda grup değişimi yap
        if (widget.shootingStyle == ShootingStyle.rotating ||
            widget.shootingStyle == ShootingStyle.alternating) {
          int nextSeri = (currentSeri % 4) + 1;
          print('DEBUG - Seri değişiyor: $currentSeri -> $nextSeri');
          currentSeri = nextSeri;
          _updateShootingGroup();
        }
        return;
      }

      // Set tamamlandı, sonraki sete geç
      currentShotInSet = 1;
      currentSet++;

      // Eğer deneme atışları varsa ve henüz bitmemişse
      if (isPracticeRound) {
        if (currentSet <= widget.practiceRounds) {
          print(
              'DEBUG - Set öncesi: Set $currentSet, Shot $currentShotInSet, Seri $currentSeri, Grup $shootinggroup');
          if (widget.shootingStyle == ShootingStyle.rotating ||
              widget.shootingStyle == ShootingStyle.alternating) {
            int nextSeri = (currentSeri % 4) + 1;
            print(
                'DEBUG - Deneme seti seri değişiyor: $currentSeri -> $nextSeri');
            currentSeri = nextSeri;
            _updateShootingGroup();
          }
          return;
        }
        // Deneme atışları bitti, normal setlere geç
        isPracticeRound = false;
        currentSet = 1;
        currentSeri = 1;
        _updateShootingGroup();
        print(
            'DEBUG - Normal setlere geçildi: Set $currentSet, Seri $currentSeri, Grup $shootinggroup');
        return;
      }

      // Normal setler
      if (currentSet > widget.matchRounds) {
        // Tüm setler tamamlandı
        isMatchFinished = true;
        widget.soundService.playWhistle();
        print('DEBUG - Yarışma bitti!');
        return;
      }

      print(
          'DEBUG - Set öncesi: Set $currentSet, Shot $currentShotInSet, Seri $currentSeri, Grup $shootinggroup');
      // Her atış sonunda grup değişimi yap
      if (widget.shootingStyle == ShootingStyle.rotating ||
          widget.shootingStyle == ShootingStyle.alternating) {
        int nextSeri = (currentSeri % 4) + 1;
        print('DEBUG - Normal set seri değişiyor: $currentSeri -> $nextSeri');
        currentSeri = nextSeri;
        _updateShootingGroup();
      }
    });
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
    _timer?.cancel(); // Timer'ı iptal et
    setState(() {
      if (isMatchFinished) return;

      // Timer durumunu sıfırla
      isRunning = false;
      isPreparationPhase = true;
      remainingTime = widget.preparationTime;

      // Atış tamamlandı, sonraki atışa geç
      if (currentShotInSet < 2) {
        // Her atış sonunda grup değişimi yap
        if (widget.shootingStyle == ShootingStyle.rotating ||
            widget.shootingStyle == ShootingStyle.alternating) {
          int nextSeri = (currentSeri % 4) + 1;
          print('DEBUG - Seri değişiyor: $currentSeri -> $nextSeri');
          currentSeri = nextSeri;
          _updateShootingGroup();
        }
        currentShotInSet++;
        print(
            'DEBUG - Sonraki atışa geçildi: Set $currentSet, Shot $currentShotInSet, Seri $currentSeri, Grup $shootinggroup');
        return;
      }

      // Set tamamlandı
      currentShotInSet = 1;
      currentSet++;

      if (isPracticeRound && currentSet > widget.practiceRounds) {
        // Deneme atışları bitti, normal setlere geç
        isPracticeRound = false;
        currentSet = 1;
        currentSeri = 1;
        _updateShootingGroup();
        print(
            'DEBUG - Normal setlere geçildi: Set $currentSet, Shot $currentShotInSet, Seri $currentSeri, Grup $shootinggroup');
        return;
      }

      if (!isPracticeRound && currentSet > widget.matchRounds) {
        // Yarışma bitti
        isMatchFinished = true;
        print('DEBUG - Yarışma bitti!');
        return;
      }

      // Sonraki sete geç
      if (widget.shootingStyle == ShootingStyle.rotating ||
          widget.shootingStyle == ShootingStyle.alternating) {
        int nextSeri = (currentSeri % 4) + 1;
        print(
            'DEBUG - Set değişiminde seri değişiyor: $currentSeri -> $nextSeri');
        currentSeri = nextSeri;
        _updateShootingGroup();
      }
      print(
          'DEBUG - Sonraki sete geçildi: Set $currentSet, Shot $currentShotInSet, Seri $currentSeri, Grup $shootinggroup');
    });
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void continueTimer() {
    _startTimer();
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      remainingTime =
          isPreparationPhase ? widget.preparationTime : widget.shootingTime;
    });
  }

  @override
  void didUpdateWidget(ShootingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shootingStyle != widget.shootingStyle) {
      print('DEBUG - Shooting Style değişti: ${widget.shootingStyle}');
      _updateSeriList();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color timerColor = isPreparationPhase
        ? Colors.orange
        : (remainingTime <= widget.warningTime ? Colors.orange : Colors.green);

    String phaseText = isPreparationPhase
        ? ' '
        : (isPracticeRound
            ? 'Set $currentSet/${widget.practiceRounds}'
            : 'Set $currentSet/${widget.matchRounds}');

    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(
        title: const Text('Ottoman Archery Timer'),
        backgroundColor: Colors.blue.shade700,
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
                        onPreparationTimeChanged:
                            widget.onPreparationTimeChanged,
                        onShootingTimeChanged: widget.onShootingTimeChanged,
                        onWarningTimeChanged: widget.onWarningTimeChanged,
                        onPracticeRoundsChanged: widget.onPracticeRoundsChanged,
                        onMatchRoundsChanged: widget.onMatchRoundsChanged,
                        onShootingStyleChanged: widget.onShootingStyleChanged,
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
                    Icon(Icons.settings, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Ayarlar'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'final_shot',
                child: Row(
                  children: [
                    Icon(Icons.sports_score, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Final Atışı'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Sıfırla'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isMatchFinished) ...[
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Yarışma Tamamlandı!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
            ],
            if (!isMatchFinished) ...[
              Text(
                shootinggroup,
                style: const TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isRunning
                    ? (isPreparationPhase ? 'ATIŞ ÇİZGİSİNE' : 'ATIŞ SERBEST')
                    : 'BEKLE',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                remainingTime.toString(),
                style: TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.bold,
                  color: timerColor,
                ),
              ),
            ],
            const SizedBox(height: 32),
            if (!isMatchFinished) ...[
              Text(
                ' $phaseText  Atış $currentShotInSet / 2',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!isMatchFinished)
                  ElevatedButton(
                    onPressed: isMatchFinished
                        ? null
                        : (isRunning ? stopTimer : _startTimer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: Text(
                      isRunning ? 'DURDUR' : 'BAŞLAT',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isMatchFinished
                            ? Colors.grey.shade300
                            : Colors.white,
                      ),
                    ),
                  ),
                if (!isMatchFinished && isRunning)
                  ElevatedButton(
                    onPressed: _finishShot, //_onPhaseComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
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
    );
  }
}
