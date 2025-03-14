import 'package:flutter/material.dart';

class ShotReportScreen extends StatelessWidget {
  final List<int> leftArcherTimes;
  final List<int> rightArcherTimes;

  const ShotReportScreen({
    Key? key,
    required this.leftArcherTimes,
    required this.rightArcherTimes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atış Raporu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildArcherReport('1. YARIŞMACI', leftArcherTimes),
            const SizedBox(height: 20),
            _buildArcherReport('2. YARIŞMACI', rightArcherTimes),
          ],
        ),
      ),
    );
  }

  Widget _buildArcherReport(String archerName, List<int> times) {
    if (times.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                archerName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Henüz atış yapılmamış'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              archerName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: times.length,
              itemBuilder: (context, index) {
                final duration = times[index];
                final minutes = duration ~/ 60;
                final seconds = duration % 60;
                final timeText = minutes > 0 
                    ? '$minutes dk ${seconds.toString().padLeft(2, '0')} sn'
                    : '$seconds sn';
                
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(timeText),
                );
              },
            ),
            const Divider(),
            _buildStatistics(times),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(List<int> times) {
    final average = times.reduce((a, b) => a + b) / times.length;
    final fastest = times.reduce((a, b) => a < b ? a : b);
    final slowest = times.reduce((a, b) => a > b ? a : b);

    String formatDuration(int seconds) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return minutes > 0 
          ? '$minutes dk ${remainingSeconds.toString().padLeft(2, '0')} sn'
          : '$remainingSeconds sn';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İstatistikler:',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Ortalama Süre: ${formatDuration(average.round())}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'En Hızlı Atış: ${formatDuration(fastest)}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'En Yavaş Atış: ${formatDuration(slowest)}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
