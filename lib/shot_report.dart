import 'package:flutter/material.dart';

class ShotTime {
  final int shotNumber;
  final String archer;
  final int duration;

  ShotTime(this.shotNumber, this.archer, this.duration);
}

class ShotReportScreen extends StatelessWidget {
  final List<ShotTime> shotTimes;
  final String leftArcherName;
  final String rightArcherName;

  const ShotReportScreen({
    super.key, 
    required this.shotTimes,
    required this.leftArcherName,
    required this.rightArcherName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atış Raporu'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    leftArcherName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    rightArcherName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: (shotTimes.length / 2).ceil(),
              itemBuilder: (context, index) {
                final shotIndex = index * 2;
                final leftShot = shotTimes[shotIndex];
                final rightShot = shotIndex + 1 < shotTimes.length 
                    ? shotTimes[shotIndex + 1] 
                    : null;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${leftShot.shotNumber}. Atış',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Süre: ${leftShot.duration} sn'),
                            ],
                          ),
                        ),
                        if (rightShot != null) ...[
                          const VerticalDivider(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${rightShot.shotNumber}. Atış',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Süre: ${rightShot.duration} sn'),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'Ortalama Süre',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_calculateAverage(shotTimes, leftArcherName)} sn',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Ortalama Süre',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_calculateAverage(shotTimes, rightArcherName)} sn',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateAverage(List<ShotTime> times, String archerName) {
    final archerTimes = times.where((shot) => shot.archer == archerName);
    if (archerTimes.isEmpty) return 0;
    
    final total = archerTimes.fold(0, (sum, shot) => sum + shot.duration);
    return (total / archerTimes.length).toStringAsFixed(1).toString().contains('.')
        ? double.parse((total / archerTimes.length).toStringAsFixed(1))
        : total / archerTimes.length;
  }
}
