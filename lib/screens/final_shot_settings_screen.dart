import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FinalShotSettingsScreen extends StatefulWidget {
  final int shootingTime;
  final int totalShots;
  final Function(int) onShootingTimeChanged;
  final Function(int) onTotalShotsChanged;

  const FinalShotSettingsScreen({
    super.key,
    required this.shootingTime,
    required this.totalShots,
    required this.onShootingTimeChanged,
    required this.onTotalShotsChanged,
  });

  @override
  State<FinalShotSettingsScreen> createState() => _FinalShotSettingsScreenState();
}

class _FinalShotSettingsScreenState extends State<FinalShotSettingsScreen> {
  late TextEditingController _shootingTimeController;
  late TextEditingController _totalShotsController;

  @override
  void initState() {
    super.initState();
    _shootingTimeController = TextEditingController(text: widget.shootingTime.toString());
    _totalShotsController = TextEditingController(text: widget.totalShots.toString());
  }

  @override
  void dispose() {
    _shootingTimeController.dispose();
    _totalShotsController.dispose();
    super.dispose();
  }

  void _updateShootingTime(String value) {
    if (value.isEmpty) return;
    final newValue = int.tryParse(value);
    if (newValue != null && newValue >= 10) {
      widget.onShootingTimeChanged(newValue);
    }
  }

  void _updateTotalShots(String value) {
    if (value.isEmpty) return;
    final newValue = int.tryParse(value);
    if (newValue != null && newValue >= 1) {
      widget.onTotalShotsChanged(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Final Atışı Ayarları'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Atış Süresi (saniye)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _shootingTimeController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Atış süresi',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _updateShootingTime,
            ),
            const SizedBox(height: 24),
            const Text(
              'Atış Sayısı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _totalShotsController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Atış sayısı',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _updateTotalShots,
            ),
          ],
        ),
      ),
    );
  }
}
