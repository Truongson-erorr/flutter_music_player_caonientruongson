import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_music_player_caonientruongson/models/playback_state_model.dart';

void main() {
  // Nhóm test cho class PlaybackUiState
  group('PlaybackUiState', () {
    
    // Test 1: Kiểm tra constructor
    test('Constructor sets values correctly', () {
      // Tạo một đối tượng PlaybackUiState với các giá trị cụ thể
      final state = PlaybackUiState(
        position: Duration(seconds: 10),
        duration: Duration(seconds: 100),
        isPlaying: true,
      );

      // Kiểm tra xem các giá trị được gán đúng không
      expect(state.position, Duration(seconds: 10)); 
      expect(state.duration, Duration(seconds: 100)); 
      expect(state.isPlaying, true); 
    });

    // Test 2: Kiểm tra getter progress
    test('progress returns correct fraction', () {
      final state = PlaybackUiState(
        position: Duration(seconds: 25),
        duration: Duration(seconds: 100),
        isPlaying: true,
      );

      // progress = position / duration = 25/100 = 0.25
      expect(state.progress, 0.25);
    });

    // Test 3: Kiểm tra progress khi duration = 0
    test('progress is 0 if duration is zero', () {
      final state = PlaybackUiState(
        position: Duration(seconds: 10),
        duration: Duration.zero,
        isPlaying: false,
      );

      // Nếu duration = 0, progress phải trả về 0
      expect(state.progress, 0.0);
    });
  });
}
