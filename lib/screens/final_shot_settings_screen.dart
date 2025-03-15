import 'package:flutter/material.dart';

class FinalShotSettingsScreen extends StatelessWidget {
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
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (shootingTime > 10) {
                      onShootingTimeChanged(shootingTime - 1);
                    }
                  },
                ),
                Text(
                  shootingTime.toString(),
                  style: const TextStyle(fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    onShootingTimeChanged(shootingTime + 1);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Atış Sayısı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (totalShots > 1) {
                      onTotalShotsChanged(totalShots - 1);
                    }
                  },
                ),
                Text(
                  totalShots.toString(),
                  style: const TextStyle(fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    onTotalShotsChanged(totalShots + 1);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
