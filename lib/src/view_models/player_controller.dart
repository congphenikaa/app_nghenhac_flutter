import 'dart:math';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';

class PlayerController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();

  // Biến UI
  var isPlaying = false.obs;
  var progress = Duration.zero.obs;
  var buffered = Duration.zero.obs;
  var totalDuration = Duration.zero.obs;
  var miniPlayerHeight = 0.0.obs;
  var isPlayerScreenOpen = false.obs;

  // Quản lý Playlist
  var currentSong = Rxn<SongModel>();
  var playlist = <SongModel>[].obs; // Danh sách bài hát đang chờ phát
  var currentIndex = 0.obs; // Vị trí bài hiện tại

  // Chế độ phát
  var isShuffleMode = false.obs;
  var loopMode = LoopMode.off.obs; // off, all, one

  @override
  void onInit() {
    super.onInit();

    // 1. Lắng nghe trạng thái phát
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;

      // Tự động chuyển bài khi hết bài
      if (state.processingState == ProcessingState.completed) {
        _onSongComplete();
      }
    });

    // 2. Lắng nghe tiến độ
    audioPlayer.positionStream.listen((position) {
      progress.value = position;
    });

    audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      buffered.value = bufferedPosition;
    });

    audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        totalDuration.value = duration;
      }
    });
  }

  // Xử lý khi bài hát kết thúc
  void _onSongComplete() {
    // Nếu đang Repeat One, Just_audio tự lo (nhờ setLoopMode)
    // Nếu không phải Repeat One, ta tự chuyển bài
    if (loopMode.value != LoopMode.one) {
      nextSong();
    }
  }

  // Hàm phát nhạc (Cập nhật để nhận Playlist)
  Future<void> playSong(SongModel song, {List<SongModel>? newQueue}) async {
    try {
      // Nếu có danh sách mới được truyền vào (ví dụ bấm từ Album/Playlist)
      if (newQueue != null && newQueue.isNotEmpty) {
        playlist.value = newQueue;
      } else if (playlist.isEmpty) {
        // Nếu chưa có playlist, tạo playlist 1 bài
        playlist.value = [song];
      }

      // Cập nhật index hiện tại
      int index = playlist.indexWhere((s) => s.id == song.id);
      if (index != -1) {
        currentIndex.value = index;
      } else {
        // Nếu bài hát không có trong playlist hiện tại, thêm vào cuối và phát
        playlist.add(song);
        currentIndex.value = playlist.length - 1;
      }

      currentSong.value = song;
      updateMiniPlayerVisibility();

      // Reset & Play
      // progress.value = Duration.zero; // Không cần thiết vì stream sẽ update
      await audioPlayer.setUrl(song.audioUrl);

      // Set lại chế độ lặp cho source mới
      _updateAudioLoopMode();

      audioPlayer.play();
    } catch (e) {
      print("Lỗi phát nhạc: $e");
    }
  }

  void togglePlay() {
    if (isPlaying.value) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  // --- LOGIC ĐIỀU KHIỂN NÂNG CAO ---

  // 1. Next Song
  void nextSong() {
    if (playlist.isEmpty) return;

    int nextIndex;

    if (isShuffleMode.value) {
      // Random bài khác bài hiện tại
      if (playlist.length > 1) {
        do {
          nextIndex = Random().nextInt(playlist.length);
        } while (nextIndex == currentIndex.value);
      } else {
        nextIndex = 0;
      }
    } else {
      // Tuần tự
      nextIndex = currentIndex.value + 1;
    }

    // Kiểm tra hết danh sách
    if (nextIndex >= playlist.length) {
      if (loopMode.value == LoopMode.all) {
        nextIndex = 0; // Quay lại đầu
      } else {
        // Dừng lại nếu không lặp
        audioPlayer.pause();
        audioPlayer.seek(Duration.zero);
        return;
      }
    }

    // Phát bài tiếp theo (giữ nguyên queue cũ)
    playSong(playlist[nextIndex]);
  }

  // 2. Previous Song
  void previousSong() {
    // Nếu đã nghe quá 5 giây -> Replay bài hiện tại
    if (audioPlayer.position.inSeconds > 5) {
      audioPlayer.seek(Duration.zero);
      return;
    }

    if (playlist.isEmpty) return;

    int prevIndex = currentIndex.value - 1;

    // Nếu đang ở bài đầu -> Quay về bài cuối (hoặc dừng tùy logic)
    if (prevIndex < 0) {
      prevIndex = playlist.length - 1;
    }

    playSong(playlist[prevIndex]);
  }

  // 3. Toggle Shuffle
  void toggleShuffle() {
    isShuffleMode.value = !isShuffleMode.value;
  }

  // 4. Toggle Repeat (Off -> All -> One -> Off)
  void cycleLoopMode() {
    switch (loopMode.value) {
      case LoopMode.off:
        loopMode.value = LoopMode.all;
        break;
      case LoopMode.all:
        loopMode.value = LoopMode.one;
        break;
      case LoopMode.one:
        loopMode.value = LoopMode.off;
        break;
    }
    _updateAudioLoopMode();
  }

  // Cập nhật setting cho AudioPlayer
  void _updateAudioLoopMode() {
    // Just_audio chỉ hỗ trợ loop one/off cho Single Source
    // Loop All ta xử lý thủ công ở hàm _onSongComplete
    if (loopMode.value == LoopMode.one) {
      audioPlayer.setLoopMode(LoopMode.one);
    } else {
      audioPlayer.setLoopMode(LoopMode.off);
    }
  }

  void updateMiniPlayerVisibility() {
    miniPlayerHeight.value = (currentSong.value != null) ? 80.0 : 0.0;
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
