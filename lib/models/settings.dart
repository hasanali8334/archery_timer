import '../enums/shooting_style.dart';

class Settings {
  final int preparationTime;
  final int shootingTime;
  final int warningTime;
  final int practiceRounds;
  final int matchRounds;
  final ShootingStyle shootingStyle;

  Settings({
    required this.preparationTime,
    required this.shootingTime,
    required this.warningTime,
    required this.practiceRounds,
    required this.matchRounds,
    required this.shootingStyle,
  });
}
