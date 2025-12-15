import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';

class PlayerController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();

  // Các biến để UI lắng nghe (Dùng .obs của GetX)
  var isPlaying = false.obs;
  var progress = Duration.zero.obs;
  var buffered = Duration.zero.obs;
  var totalDuration = Duration.zero.obs;

  // Lưu bài hát đang phát
  var currentSong = Rxn<SongModel>();

  @override
  void onInit() {
    super.onInit();

    // Lắng nghe trạng thái phát (Play/Pause/Loading)
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    // Lắng nghe thời gian chạy của bài hát
    audioPlayer.positionStream.listen((position) {
      progress.value = position;
    });

    // Lắng nghe thời gian đã tải (buffer)
    audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      buffered.value = bufferedPosition;
    });

    // Lắng nghe tổng thời lượng bài hát
    audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        totalDuration.value = duration;
      }
    });
  }

  // Hàm phát nhạc từ URL
  Future<void> playSong(SongModel song) async {
    try {
      currentSong.value = song; // Cập nhật bài hát hiện tại

      // Reset trạng thái cũ
      progress.value = Duration.zero;

      // Đặt đường dẫn nhạc
      await audioPlayer.setUrl(song.audioUrl);

      // Bắt đầu phát
      audioPlayer.play();
    } catch (e) {
      print("Lỗi phát nhạc: $e");
    }
  }

  // Hàm Play/Pause
  void togglePlay() {
    if (isPlaying.value) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
  }

  // Hàm tua nhạc (Seek)
  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  @override
  void onClose() {
    audioPlayer.dispose(); // Giải phóng bộ nhớ khi tắt app
    super.onClose();
  }
}
