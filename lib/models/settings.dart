import 'shooting_style.dart';

/// Settings sınıfını oluşturdum:
/// 1. preparationTime: Hazırlık süresi
/// 2. shootingTime: Atış süresi
/// 3. warningTime: Uyarı süresi
/// 4. practiceRounds: Deneme atışı sayısı
/// 5. matchRounds: Yarışma seti sayısı
/// 6. shootingStyle: Atış stili
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
