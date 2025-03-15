import 'package:flutter/material.dart';
import '../models/shooting_style.dart';

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
              }

              final shootTime = int.tryParse(_shootingTimeController.text);
              if (shootTime != null && shootTime > 0) {
                widget.onShootingTimeChanged(shootTime);
              }

              final warnTime = int.tryParse(_warningTimeController.text);
              if (warnTime != null && warnTime >= 10 && warnTime <= 60) {
                widget.onWarningTimeChanged(warnTime);
              }

              final practiceRounds = int.tryParse(
                _practiceRoundsController.text,
              );
              if (practiceRounds != null && practiceRounds >= 0) {
                widget.onPracticeRoundsChanged(practiceRounds);
              }

              final matchRounds = int.tryParse(_matchRoundsController.text);
              if (matchRounds != null && matchRounds >= 1) {
                widget.onMatchRoundsChanged(matchRounds);
              }

              widget.onShootingStyleChanged(_shootingStyle);
              Navigator.pop(context);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deneme Serisi Sayısı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _practiceRoundsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Deneme serisi sayısı (0 veya daha fazla)',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  onChanged: _updatePracticeRounds,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Hazırlık Süresi (saniye)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _preparationTimeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: '10-60 saniye arası',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  onChanged: _updatePreparationTime,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Atış Süresi (saniye)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _shootingTimeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Atış süresi (saniye)',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  onChanged: _updateShootingTime,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Uyarı Süresi (saniye)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _warningTimeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: '10-60 saniye arası',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  onChanged: _updateWarningTime,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Yarışma Serisi Sayısı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _matchRoundsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Yarışma serisi sayısı (1 veya daha fazla)',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  onChanged: _updateMatchRounds,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                title: const Text(
                  'ATIŞ STİLİ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  children: [
                    RadioListTile<ShootingStyle>(
                      title: const Text(
                        'STANDART',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Sadece AB grubu atıyor',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: ShootingStyle.standard,
                      groupValue: _shootingStyle,
                      onChanged: (ShootingStyle? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _shootingStyle = newValue;
                          });
                        }
                      },
                    ),
                    RadioListTile<ShootingStyle>(
                      title: const Text(
                        'DÖNÜŞÜMSÜZ',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Her sette: 1.atış AB, 2.atış CD',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: ShootingStyle.alternating,
                      groupValue: _shootingStyle,
                      onChanged: (ShootingStyle? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _shootingStyle = newValue;
                          });
                        }
                      },
                    ),
                    RadioListTile<ShootingStyle>(
                      title: const Text(
                        'DÖNÜŞÜMLÜ',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        '1.set: AB-CD, 2.set: CD-AB',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: ShootingStyle.rotating,
                      groupValue: _shootingStyle,
                      onChanged: (ShootingStyle? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _shootingStyle = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
