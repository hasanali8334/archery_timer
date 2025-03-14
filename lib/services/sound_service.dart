import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _whistlePlayer = AudioPlayer();

  Future<void> playBeep() async {
    await _audioPlayer.play(AssetSource('sounds/beep.wav'));
  }

  Future<void> playLongBeep() async {
    await _audioPlayer.play(AssetSource('sounds/beep.wav'));
  }

  Future<void> playWarningBeep() async {
    await _audioPlayer.play(AssetSource('sounds/beep.wav'));
  }

  Future<void> playWhistle() async {
    await _whistlePlayer.stop();
    await _whistlePlayer.setReleaseMode(ReleaseMode.release);
    await _whistlePlayer.play(AssetSource('sounds/whistle.wav'));
  }

  void dispose() {
    _audioPlayer.dispose();
    _whistlePlayer.dispose();
  }
}
