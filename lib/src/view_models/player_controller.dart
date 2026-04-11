import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../configs/app_urls.dart';

class PlayerController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();

  // Biến UI
  var isPlaying = false.obs;
  var progress = Duration.zero.obs;
  var buffered = Duration.zero.obs;
  var totalDuration = Duration.zero.obs;
  var miniPlayerHeight = 0.0.obs;
  var isPlayerScreenOpen = false.obs;
  // Thêm biến này để điều khiển việc ẩn/hiện MiniPlayer
  var hideMiniPlayer = false.obs;

  // Quản lý Playlist
  var currentSong = Rxn<SongModel>();
  var playlist = <SongModel>[].obs; // Danh sách bài hát đang chờ phát
  var currentIndex = 0.obs; // Vị trí bài hiện tại

  // Chế độ phát
  var isShuffleMode = false.obs;
  var loopMode = LoopMode.off.obs; // off, all, one

  // Biến đếm lượt nghe
  Timer? _listenTimer;
  int _listenDuration = 0; // Đếm số giây người dùng THỰC SỰ NGHE
  bool _hasCountedView = false; // Cờ đánh dấu đã cộng view cho bài này chưa

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
    if (loopMode.value == LoopMode.one) {
      // --- XỬ LÝ LẶP LẠI (REPEAT ONE) THỦ CÔNG ---
      audioPlayer.seek(Duration.zero);

      // BẮT BUỘC: Reset lại bộ đếm để tính view cho vòng lặp thứ 2
      _hasCountedView = false;
      _listenDuration = 0;
      _listenTimer?.cancel();

      // Bật lại đồng hồ bấm giờ 30s
      if (currentSong.value != null) {
        _startPlayCountListener(currentSong.value!.id);
      }

      audioPlayer.play();
    } else {
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

      // [UPDATE] Tạo AudioSource có gắn thẻ MediaItem để hiển thị Notification
      final audioSource = AudioSource.uri(
        Uri.parse(song.audioUrl),
        tag: MediaItem(
          // ID là bắt buộc và phải là unique string
          id: song.id,
          album: song.album,
          title: song.title,
          artist: song.artist,
          artUri: Uri.parse(song.imageUrl),
        ),
      );

      // Set Audio Source mới
      await audioPlayer.setAudioSource(audioSource);

      // Set lại chế độ lặp cho source mới
      _updateAudioLoopMode();

      // --- RESET BỘ ĐẾM KHI CHUYỂN BÀI MỚI ---
      _hasCountedView = false;
      _listenDuration = 0;
      _listenTimer?.cancel(); // Hủy đồng hồ bấm giờ của bài cũ

      audioPlayer.play();

      // Gọi hàm đếm lượt nghe
      _startPlayCountListener(song.id);
    } catch (e) {
      print("Lỗi phát nhạc: $e");
    }
  }

  void _startPlayCountListener(String songId) {
    // Dùng Timer chạy mỗi 1 giây để đếm thời gian nghe thực tế
    _listenTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // 1. Nếu đã đếm xong rồi thì tắt Timer luôn cho nhẹ máy
      if (_hasCountedView) {
        timer.cancel();
        return;
      }

      // 2. Chỉ tính thời gian khi bài hát ĐANG PHÁT (không pause, không buffering)
      if (audioPlayer.playing &&
          audioPlayer.processingState == ProcessingState.ready) {
        _listenDuration++;
      }

      // 3. Đạt đúng 30 giây NGHE THỰC TẾ thì mới gọi API
      if (_listenDuration >= 30) {
        _hasCountedView = true;
        _incrementPlayCountApi(songId);
        timer.cancel();
      }
    });
  }

  Future<void> _incrementPlayCountApi(String songId) async {
    try {
      final authController = Get.find<AuthController>();

      // Lấy User ID thật
      final String? userId = authController.currentUser.value?.id;

      final response = await http.post(
        Uri.parse(AppUrls.playSong),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': songId,
          'userId': userId, // Gửi đúng ID thật của User
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Trạng thái cộng view: ${data['message']}");
      } else {
        print("Lỗi server tăng view: ${response.body}");
      }
    } catch (e) {
      print("Lỗi kết nối tăng view: $e");
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
    // TẮT loop mặc định của just_audio để ta tự quản lý ở hàm _onSongComplete
    // Nhờ vậy Flutter mới biết được khoảnh khắc bài hát bắt đầu lặp lại để đếm view mới
    audioPlayer.setLoopMode(LoopMode.off);
  }

  void updateMiniPlayerVisibility() {
    miniPlayerHeight.value = (currentSong.value != null) ? 80.0 : 0.0;
  }

  @override
  void onClose() {
    _listenTimer?.cancel();
    audioPlayer.dispose();
    super.onClose();
  }
}
