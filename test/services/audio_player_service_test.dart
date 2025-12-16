import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_music_player_caonientruongson/models/playback_state_model.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<String> _playlist = [];
  int _currentIndex = 0;

  String? get currentSong => _playlist.isEmpty ? null : _playlist[_currentIndex];

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;

  Duration get currentPosition => _audioPlayer.position;
  Duration get currentDuration => _audioPlayer.duration ?? Duration.zero;
  bool get isPlaying => _audioPlayer.playing;

  Stream<PlaybackUiState> get playbackStateStream {
    return Rx.combineLatest3<Duration, Duration?, bool, PlaybackUiState>(
      positionStream,
      durationStream,
      playingStream,
      (position, duration, isPlaying) => PlaybackUiState(
        position: position,
        duration: duration ?? Duration.zero,
        isPlaying: isPlaying,
      ),
    );
  }

  Future<void> loadAudio(String filePath) async {
    try {
      await _audioPlayer.setFilePath(filePath);
    } catch (e) {
      throw Exception('Error loading audio: $e');
    }
  }

  Future<void> play() async => await _audioPlayer.play();
  Future<void> pause() async => await _audioPlayer.pause();
  Future<void> stop() async => await _audioPlayer.stop();
  Future<void> seek(Duration position) async => await _audioPlayer.seek(position);
  Future<void> setVolume(double volume) async => await _audioPlayer.setVolume(volume);
  Future<void> setSpeed(double speed) async => await _audioPlayer.setSpeed(speed);
  Future<void> setLoopMode(LoopMode loopMode) async => await _audioPlayer.setLoopMode(loopMode);

  Future<void> setPlaylist(List<String> songs) async {
    _playlist = List.from(songs);
    _currentIndex = 0;
    if (_playlist.isNotEmpty) {
      await loadAudio(_playlist[_currentIndex]);
    }
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    await loadAudio(_playlist[_currentIndex]);
    await play();
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    await loadAudio(_playlist[_currentIndex]);
    await play();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
