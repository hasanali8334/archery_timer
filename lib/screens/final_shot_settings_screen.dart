import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FinalShotSettingsScreen extends StatefulWidget {
  final int shootingTime;
  final int totalShots;
  final String archer1Name;
  final String archer2Name;
  final Function(int) onShootingTimeChanged;
  final Function(int) onTotalShotsChanged;
  final Function(String) onArcher1NameChanged;
  final Function(String) onArcher2NameChanged;

  const FinalShotSettingsScreen({
    super.key,
    required this.shootingTime,
    required this.totalShots,
    required this.archer1Name,
    required this.archer2Name,
    required this.onShootingTimeChanged,
    required this.onTotalShotsChanged,
    required this.onArcher1NameChanged,
    required this.onArcher2NameChanged,
  });

  @override
  State<FinalShotSettingsScreen> createState() => _FinalShotSettingsScreenState();
}

class _FinalShotSettingsScreenState extends State<FinalShotSettingsScreen> {
  late TextEditingController _shootingTimeController;
  late TextEditingController _totalShotsController;
  late TextEditingController _archer1NameController;
  late TextEditingController _archer2NameController;
  int _tempShootingTime = 0;
  int _tempTotalShots = 0;
  String _tempArcher1Name = '';
  String _tempArcher2Name = '';

  @override
  void initState() {
    super.initState();
    _tempShootingTime = widget.shootingTime;
    _tempTotalShots = widget.totalShots;
    _tempArcher1Name = widget.archer1Name;
    _tempArcher2Name = widget.archer2Name;
    _shootingTimeController = TextEditingController(text: _tempShootingTime.toString());
    _totalShotsController = TextEditingController(text: _tempTotalShots.toString());
    _archer1NameController = TextEditingController(text: _tempArcher1Name);
    _archer2NameController = TextEditingController(text: _tempArcher2Name);
  }

  @override
  void dispose() {
    _shootingTimeController.dispose();
    _totalShotsController.dispose();
    _archer1NameController.dispose();
    _archer2NameController.dispose();
    super.dispose();
  }

  void _updateShootingTime(String value) {
    if (value.isEmpty) return;
    final newValue = int.tryParse(value);
    if (newValue != null && newValue >= 10) {
      setState(() {
        _tempShootingTime = newValue;
      });
    }
  }

  void _updateTotalShots(String value) {
    if (value.isEmpty) return;
    final newValue = int.tryParse(value);
    if (newValue != null && newValue >= 1) {
      setState(() {
        _tempTotalShots = newValue;
      });
    }
  }

  void _updateArcher1Name(String value) {
    setState(() {
      _tempArcher1Name = value;
    });
  }

  void _updateArcher2Name(String value) {
    setState(() {
      _tempArcher2Name = value;
    });
  }

  void _saveSettings() {
    widget.onShootingTimeChanged(_tempShootingTime);
    widget.onTotalShotsChanged(_tempTotalShots);
    widget.onArcher1NameChanged(_tempArcher1Name);
    widget.onArcher2NameChanged(_tempArcher2Name);
    Navigator.pop(context);
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
              '1. Yarışmacı Adı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _archer1NameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '1. Yarışmacı adını girin',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _updateArcher1Name,
            ),
            const SizedBox(height: 24),
            const Text(
              '2. Yarışmacı Adı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _archer2NameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '2. Yarışmacı adını girin',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _updateArcher2Name,
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'KAYDET',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
