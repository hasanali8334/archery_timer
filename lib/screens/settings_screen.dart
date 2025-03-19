import 'package:flutter/material.dart';
import '../models/shooting_style.dart';
import '../models/settings.dart';
import '../services/sound_service.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Function(int) onPreparationTimeChanged;
  final Function(int) onShootingTimeChanged;
  final Function(int) onWarningTimeChanged;
  final Function(int) onPracticeRoundsChanged;
  final Function(int) onMatchRoundsChanged;
  final Function(ShootingStyle) onShootingStyleChanged;
  final int preparationTime;
  final int shootingTime;
  final int warningTime;
  final int practiceRounds;
  final int matchRounds;
  final ShootingStyle shootingStyle;

  const SettingsScreen({
    super.key,
    required this.onPreparationTimeChanged,
    required this.onShootingTimeChanged,
    required this.onWarningTimeChanged,
    required this.onPracticeRoundsChanged,
    required this.onMatchRoundsChanged,
    required this.onShootingStyleChanged,
    required this.preparationTime,
    required this.shootingTime,
    required this.warningTime,
    required this.practiceRounds,
    required this.matchRounds,
    required this.shootingStyle,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _preparationTimeController;
  late TextEditingController _shootingTimeController;
  late TextEditingController _warningTimeController;
  late TextEditingController _practiceRoundsController;
  late TextEditingController _matchRoundsController;
  late ShootingStyle _shootingStyle;

  @override
  void initState() {
    super.initState();
    _preparationTimeController = TextEditingController(
      text: widget.preparationTime.toString(),
    );
    _shootingTimeController = TextEditingController(
      text: widget.shootingTime.toString(),
    );
    _warningTimeController = TextEditingController(
      text: widget.warningTime.toString(),
    );
    _practiceRoundsController = TextEditingController(
      text: widget.practiceRounds.toString(),
    );
    _matchRoundsController = TextEditingController(
      text: widget.matchRounds.toString(),
    );
    _shootingStyle = widget.shootingStyle;
  }

  @override
  void dispose() {
    _preparationTimeController.dispose();
    _shootingTimeController.dispose();
    _warningTimeController.dispose();
    _practiceRoundsController.dispose();
    _matchRoundsController.dispose();
    super.dispose();
  }

  void _updatePreparationTime(String value) {
    final time = int.tryParse(value);
    if (time != null && time > 0) {
      setState(() {
        _preparationTimeController.text = time.toString();
      });
    }
  }

  void _updateShootingTime(String value) {
    final time = int.tryParse(value);
    if (time != null && time > 0) {
      setState(() {
        _shootingTimeController.text = time.toString();
      });
    }
  }

  void _updateWarningTime(String value) {
    final time = int.tryParse(value);
    if (time != null && time > 0) {
      setState(() {
        _warningTimeController.text = time.toString();
      });
    }
  }

  void _updatePracticeRounds(String value) {
    final rounds = int.tryParse(value);
    if (rounds != null && rounds >= 0) {
      setState(() {
        _practiceRoundsController.text = rounds.toString();
      });
    }
  }

  void _updateMatchRounds(String value) {
    final rounds = int.tryParse(value);
    if (rounds != null && rounds >= 1) {
      setState(() {
        _matchRoundsController.text = rounds.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // Değerleri kaydet
              final prepTime = int.tryParse(_preparationTimeController.text);
              if (prepTime != null && prepTime >= 10 && prepTime <= 60) {
                widget.onPreparationTimeChanged(prepTime);
                print('DEBUG - Hazırlık süresi güncellendi: $prepTime');
              }

              final shootTime = int.tryParse(_shootingTimeController.text);
              if (shootTime != null && shootTime > 0) {
                widget.onShootingTimeChanged(shootTime);
                print('DEBUG - Atış süresi güncellendi: $shootTime');
              }

              final warnTime = int.tryParse(_warningTimeController.text);
              if (warnTime != null && warnTime >= 10 && warnTime <= 60) {
                widget.onWarningTimeChanged(warnTime);
                print('DEBUG - Uyarı süresi güncellendi: $warnTime');
              }

              final practiceRounds = int.tryParse(
                _practiceRoundsController.text,
              );
              if (practiceRounds != null && practiceRounds >= 0) {
                widget.onPracticeRoundsChanged(practiceRounds);
                print(
                    'DEBUG - Deneme atış sayısı güncellendi: $practiceRounds');
              }

              final matchRounds = int.tryParse(_matchRoundsController.text);
              if (matchRounds != null && matchRounds >= 1) {
                widget.onMatchRoundsChanged(matchRounds);
                print('DEBUG - Yarışma atış sayısı güncellendi: $matchRounds');
              }

              widget.onShootingStyleChanged(_shootingStyle);
              print('DEBUG - Atış stili güncellendi: $_shootingStyle');
              // Welcome ekranına git
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => WelcomeScreen(
                    settings: Settings(
                      preparationTime: prepTime ?? widget.preparationTime,
                      shootingTime: shootTime ?? widget.shootingTime,
                      warningTime: warnTime ?? widget.warningTime,
                      practiceRounds: practiceRounds ?? widget.practiceRounds,
                      matchRounds: matchRounds ?? widget.matchRounds,
                      shootingStyle: _shootingStyle,
                    ),
                    soundService: SoundService(),
                    onPreparationTimeChanged: widget.onPreparationTimeChanged,
                    onShootingTimeChanged: widget.onShootingTimeChanged,
                    onWarningTimeChanged: widget.onWarningTimeChanged,
                    onPracticeRoundsChanged: widget.onPracticeRoundsChanged,
                    onMatchRoundsChanged: widget.onMatchRoundsChanged,
                    onShootingStyleChanged: widget.onShootingStyleChanged,
                  ),
                ),
              );
            },
            child: const Text(
              'KAYDET',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blue.shade700,
      body: Form(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deneme Atış Sayısı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _practiceRoundsController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Deneme Atış Sayısı',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _updatePracticeRounds,
              ),
              const SizedBox(height: 24),
              const Text(
                'Hazırlık Süresi (sn)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _preparationTimeController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Hazırlık Süresi (sn)',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _updatePreparationTime,
              ),
              const SizedBox(height: 24),
              const Text(
                'Atış Süresi (sn)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _shootingTimeController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Atış Süresi (sn)',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _updateShootingTime,
              ),
              const SizedBox(height: 24),
              const Text(
                'Uyarı Süresi (sn)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _warningTimeController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Uyarı Süresi (sn)',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _updateWarningTime,
              ),
              const SizedBox(height: 24),
              const Text(
                'Yarışma Atış Sayısı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _matchRoundsController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Yarışma Atış Sayısı',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _updateMatchRounds,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<ShootingStyle>(
                    value: _shootingStyle,
                    isExpanded: true,
                    dropdownColor: Colors.blue.shade700,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    underline: Container(),
                    items: [
                      DropdownMenuItem(
                        value: ShootingStyle.standard,
                        child: Text(
                          'Standart (AB)',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ShootingStyle.alternating,
                        child: Text(
                          'Dönüşümsüz (AB-CD-AB-CD)',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ShootingStyle.rotating,
                        child: Text(
                          'Dönüşümlü (AB-CD-CD-AB)',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onChanged: (ShootingStyle? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _shootingStyle = newValue;
                        });
                      }
                    },
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
