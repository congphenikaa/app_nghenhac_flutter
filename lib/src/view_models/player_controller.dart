import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:palette_generator/palette_generator.dart';
import '../configs/app_urls.dart';

class PlayerController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();

  // Biến UI cơ bản
  var isPlaying = false.obs;
  var progress = Duration.zero.obs;
  var buffered = Duration.zero.obs;
  var totalDuration = Duration.zero.obs;
  var miniPlayerHeight = 0.0.obs;
  var isPlayerScreenOpen = false.obs;
  var hideMiniPlayer = false.obs;

  // --- CÁC BIẾN MỚI CHO TÍNH NĂNG NHÓM 1 ---
  var dominantColor = const Color(0xFF121212).obs; // Đổi màu nền
  var playbackSpeed = 1.0.obs; // Chỉnh tốc độ phát
  var isTimerActive = false.obs; // Theo dõi trạng thái bật/tắt hẹn giờ
  var pauseOnSongEnd = false.obs; // Hẹn giờ: Hết bài thì tắt
  Timer? _sleepTimer; // Bộ đếm lùi
  var selectedSleepMinutes = (-1).obs; // Số phút hẹn giờ, -1 = chưa chọn

  // Khóa chống dội sự kiện (Debounce) cho just_audio
  bool _isProcessingCompletion = false;

  // Quản lý Playlist
  var currentSong = Rxn<SongModel>();
  var playlist = <SongModel>[].obs;
  var currentIndex = 0.obs;

  // --- CÁC BIẾN QUẢN LÝ SHUFFLE CHUẨN ---
  var shuffledIndices = <int>[].obs;
  var currentShuffleIndex = 0.obs;

  // --- NÂNG CẤP: DANH SÁCH CHỜ CHUẨN SPOTIFY ---
  List<SongModel> get upcomingSongs {
    if (playlist.isEmpty) return [];

    final isShuffle = isShuffleMode.value;
    final cIndex = currentIndex.value;
    final isLoopAll =
        loopMode.value == LoopMode.all; // Kiểm tra có bật lặp không

    List<SongModel> upcoming = [];

    // Số lượng bài hiển thị tối đa trong Queue để tránh lag UI nếu playlist quá dài (ví dụ: 1000 bài)
    const int maxQueueDisplay = 30;

    if (isShuffle) {
      // 1. Lấy phần còn lại của danh sách đang trộn
      for (
        int i = currentShuffleIndex.value + 1;
        i < shuffledIndices.length;
        i++
      ) {
        upcoming.add(playlist[shuffledIndices[i]]);
        if (upcoming.length >= maxQueueDisplay) return upcoming;
      }

      // 2. NẾU BẬT LẶP LẠI -> Cuốn chiếu các bài đã nghe lên phía sau
      if (isLoopAll) {
        for (int i = 0; i <= currentShuffleIndex.value; i++) {
          upcoming.add(playlist[shuffledIndices[i]]);
          if (upcoming.length >= maxQueueDisplay) return upcoming;
        }
      }
    } else {
      // 1. Lấy phần còn lại của danh sách gốc
      for (int i = cIndex + 1; i < playlist.length; i++) {
        upcoming.add(playlist[i]);
        if (upcoming.length >= maxQueueDisplay) return upcoming;
      }

      // 2. NẾU BẬT LẶP LẠI -> Cuốn chiếu từ đầu playlist
      if (isLoopAll) {
        for (int i = 0; i <= cIndex; i++) {
          upcoming.add(playlist[i]);
          if (upcoming.length >= maxQueueDisplay) return upcoming;
        }
      }
    }

    return upcoming;
  }

  // Chế độ phát
  var isShuffleMode = false.obs;
  var loopMode = LoopMode.off.obs;

  // Biến đếm lượt nghe
  Timer? _listenTimer;
  int _listenDuration = 0;
  bool _hasCountedView = false;

  @override
  void onInit() {
    super.onInit();
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _onSongComplete();
      }
    });

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

  // --- TÍNH NĂNG 1: TRÍCH XUẤT MÀU NỀN TỪ ẢNH BÌA ---
  Future<void> updateDominantColor(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    try {
      final PaletteGenerator generator =
          await PaletteGenerator.fromImageProvider(
            CachedNetworkImageProvider(imageUrl),
          );
      // Lấy màu chủ đạo, nếu không lấy được dùng màu mặc định
      dominantColor.value =
          generator.dominantColor?.color ?? const Color(0xFF121212);
    } catch (e) {
      dominantColor.value = const Color(0xFF121212);
    }
  }

  // --- TÍNH NĂNG 4: THAY ĐỔI TỐC ĐỘ PHÁT ---
  void changeSpeed(double speed) {
    playbackSpeed.value = speed;
    audioPlayer.setSpeed(speed);
  }

  // --- TÍNH NĂNG 2: HẸN GIỜ TẮT NHẠC ---
  void setSleepTimer(int minutes) {
    cancelSleepTimer(); // Xóa timer cũ nếu có
    isTimerActive.value = true;
    selectedSleepMinutes.value = minutes; // Đồng bộ UI Menu

    if (minutes == 0) {
      pauseOnSongEnd.value = true;
      Get.snackbar(
        "Hẹn giờ tắt",
        "Sẽ dừng nhạc và thông báo sau khi hết bài hát này",
        icon: const Icon(Icons.timer, color: Colors.white),
        backgroundColor: const Color(0xFF1C2E24),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Hẹn giờ tắt",
        "Sẽ dừng nhạc và thông báo sau $minutes phút",
        icon: const Icon(Icons.timer, color: Colors.white),
        backgroundColor: const Color(0xFF1C2E24),
        colorText: Colors.white,
      );

      // Khởi tạo đếm lùi
      _sleepTimer = Timer(Duration(minutes: minutes), () {
        _triggerTimerStop(); // Hết phút -> Gọi popup thông báo và tắt nhạc
      });
    }
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    pauseOnSongEnd.value = false;
    isTimerActive.value = false;
    selectedSleepMinutes.value = -1; // Reset UI Menu về trạng thái chưa chọn
  }

  // --- HÀM XỬ LÝ KHI HẾT THỜI GIAN HOẶC HẾT BÀI ---
  Future<void> _triggerTimerStop() async {
    // 1. Dừng nhạc
    await audioPlayer.pause();

    // 2. FIX BUG MẤT KIỂM SOÁT: Đưa con trỏ nhạc về 0 để ép just_audio xóa trạng thái "completed"
    await audioPlayer.seek(Duration.zero);

    // 3. Reset các biến UI (đưa bộ đếm về -1)
    cancelSleepTimer();

    // 4. Hiển thị Popup thông báo ở giữa màn hình
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
            Icon(Icons.timer_off, color: Color(0xFF30e87a), size: 48),
            SizedBox(height: 12),
            Text(
              "Đã tắt nhạc",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          "Đã hết thời gian hẹn giờ.\nỨng dụng đã tự động dừng phát nhạc.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF30e87a),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () {
              if (Get.isDialogOpen == true) Get.back(); // Đóng popup
            },
            child: const Text(
              "Đóng",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      barrierDismissible: false, // Bắt buộc người dùng phải bấm nút Đóng
    );
  }

  // CẬP NHẬT KHI KẾT THÚC BÀI HÁT (Kiểm tra Hẹn giờ)
  void _onSongComplete() async {
    // 1. NẾU ĐANG XỬ LÝ RỒI THÌ CHẶN LUÔN, KHÔNG CHO CHẠY LẦN 2
    if (_isProcessingCompletion) return;

    // Khóa lại
    _isProcessingCompletion = true;

    // 2. Chạy logic
    if (pauseOnSongEnd.value == true) {
      await _triggerTimerStop(); // Phải có await
    } else if (loopMode.value == LoopMode.one) {
      await audioPlayer.seek(Duration.zero);
      _hasCountedView = false;
      _listenDuration = 0;
      _listenTimer?.cancel();
      if (currentSong.value != null) {
        _startPlayCountListener(currentSong.value!.id);
      }
      audioPlayer.play();
    } else {
      nextSong();
    }

    // 3. MỞ KHÓA SAU 500 MỖI NGHÌN GIÂY (0.5s)
    // Khoảng thời gian này đủ để các tín hiệu "ảo" của just_audio trôi qua hết
    Future.delayed(const Duration(milliseconds: 500), () {
      _isProcessingCompletion = false;
    });
  }

  Future<void> playSong(SongModel song, {List<SongModel>? newQueue}) async {
    try {
      if (pauseOnSongEnd.value == true) {
        cancelSleepTimer();
        Get.snackbar(
          "Đã hủy hẹn giờ",
          "Hẹn giờ tắt nhạc bị hủy do bạn đổi bài mới.",
          colorText: Colors.white,
          backgroundColor: const Color(0xFF1C2E24),
          duration: const Duration(seconds: 2),
        );
      }

      bool isPlaylistChanged = false;

      if (newQueue != null && newQueue.isNotEmpty) {
        playlist.value = newQueue;
        isPlaylistChanged = true;
      } else if (playlist.isEmpty) {
        playlist.value = [song];
        isPlaylistChanged = true;
      }

      int index = playlist.indexWhere((s) => s.id == song.id);
      if (index != -1) {
        currentIndex.value = index;
      } else {
        playlist.add(song);
        currentIndex.value = playlist.length - 1;
        isPlaylistChanged = true;
      }

      // XỬ LÝ LOGIC SHUFFLE CHUẨN KHI GỌI TỪ OBSERVABLE
      if (isShuffleMode.value) {
        if (isPlaylistChanged || shuffledIndices.length != playlist.length) {
          shuffledIndices.value = List.generate(playlist.length, (i) => i);
          shuffledIndices.shuffle();
          shuffledIndices.remove(currentIndex.value);
          shuffledIndices.insert(0, currentIndex.value);
          currentShuffleIndex.value = 0;
        } else {
          int sIndex = shuffledIndices.indexOf(currentIndex.value);
          if (sIndex != -1) {
            currentShuffleIndex.value = sIndex;
          }
        }
      }

      currentSong.value = song;
      updateMiniPlayerVisibility();
      updateDominantColor(song.imageUrl);

      final audioSource = AudioSource.uri(
        Uri.parse(song.audioUrl),
        tag: MediaItem(
          id: song.id,
          album: song.album,
          title: song.title,
          artist: song.artist,
          artUri: Uri.parse(song.imageUrl),
        ),
      );

      await audioPlayer.setAudioSource(audioSource);
      _updateAudioLoopMode();

      _hasCountedView = false;
      _listenDuration = 0;
      _listenTimer?.cancel();
      audioPlayer.play();
      _startPlayCountListener(song.id);
    } catch (e) {
      debugPrint("Lỗi phát nhạc: $e");
    }
  }

  void _startPlayCountListener(String songId) {
    _listenTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_hasCountedView) {
        timer.cancel();
        return;
      }
      if (audioPlayer.playing &&
          audioPlayer.processingState == ProcessingState.ready) {
        _listenDuration++;
      }
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
      final String? userId = authController.currentUser.value?.id;

      final response = await http.post(
        Uri.parse(AppUrls.playSong),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': songId, 'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Trạng thái cộng view: ${data['message']}");
      }
    } catch (e) {
      debugPrint("Lỗi kết nối tăng view: $e");
    }
  }

  void togglePlay() {
    if (isPlaying.value) {
      audioPlayer.pause();
      // Nếu tự tắt nhạc mà đang hẹn giờ thời gian (không phải dạng hết bài), hủy luôn
      if (isTimerActive.value && selectedSleepMinutes.value > 0) {
        cancelSleepTimer();
        Get.snackbar(
          "Đã hủy hẹn giờ",
          "Bộ đếm giờ được tắt vì bạn đã dừng nhạc.",
          colorText: Colors.white,
          backgroundColor: const Color(0xFF1C2E24),
        );
      }
    } else {
      audioPlayer.play();
    }
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  // --- TÍNH NĂNG 3: CHUYỂN BÀI MƯỢT MÀ VÀ SHUFFLE CHUẨN K BỊ LẶP ---
  void nextSong() {
    if (playlist.isEmpty) return;

    int nextIndex;
    if (isShuffleMode.value) {
      if (playlist.length > 1) {
        currentShuffleIndex.value++;
        if (currentShuffleIndex.value >= shuffledIndices.length) {
          if (loopMode.value == LoopMode.all) {
            // --- BẢN NÂNG CẤP CHỐNG TRÙNG BÀI ---
            int lastPlayedIndex =
                shuffledIndices.last; // Lưu lại bài vừa hát xong

            shuffledIndices.shuffle(); // Trộn danh sách mới

            // Nếu xui xẻo bài đầu tiên của list mới trùng với bài vừa hát xong
            if (shuffledIndices.first == lastPlayedIndex) {
              // Tráo đổi vị trí bài 1 và bài 2
              int temp = shuffledIndices[0];
              shuffledIndices[0] = shuffledIndices[1];
              shuffledIndices[1] = temp;
            }

            currentShuffleIndex.value = 0;
            nextIndex = shuffledIndices[currentShuffleIndex.value];
            // ------------------------------------
          } else {
            currentShuffleIndex.value--; // Trả lại index cũ
            audioPlayer.pause();
            audioPlayer.seek(Duration.zero);
            return;
          }
        } else {
          nextIndex = shuffledIndices[currentShuffleIndex.value];
        }
      } else {
        nextIndex = 0;
      }
    } else {
      nextIndex = currentIndex.value + 1;
      if (nextIndex >= playlist.length) {
        if (loopMode.value == LoopMode.all) {
          nextIndex = 0;
        } else {
          audioPlayer.pause();
          audioPlayer.seek(Duration.zero);
          return;
        }
      }
    }

    playSong(playlist[nextIndex]);
  }

  void previousSong() {
    if (audioPlayer.position.inSeconds > 5) {
      audioPlayer.seek(Duration.zero);
      return;
    }
    if (playlist.isEmpty) return;

    int prevIndex;
    if (isShuffleMode.value) {
      if (playlist.length > 1) {
        currentShuffleIndex.value--;
        if (currentShuffleIndex.value < 0) {
          currentShuffleIndex.value = shuffledIndices.length - 1;
        }
        prevIndex = shuffledIndices[currentShuffleIndex.value];
      } else {
        prevIndex = 0;
      }
    } else {
      prevIndex = currentIndex.value - 1;
      if (prevIndex < 0) {
        prevIndex = playlist.length - 1;
      }
    }

    playSong(playlist[prevIndex]);
  }

  void toggleShuffle() {
    isShuffleMode.value = !isShuffleMode.value;
    if (isShuffleMode.value && playlist.isNotEmpty) {
      shuffledIndices.value = List.generate(playlist.length, (i) => i);
      shuffledIndices.shuffle();
      shuffledIndices.remove(currentIndex.value);
      shuffledIndices.insert(0, currentIndex.value);
      currentShuffleIndex.value = 0;
    }
  }

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

  void _updateAudioLoopMode() {
    audioPlayer.setLoopMode(LoopMode.off);
  }

  void updateMiniPlayerVisibility() {
    miniPlayerHeight.value = (currentSong.value != null) ? 80.0 : 0.0;
  }

  @override
  void onClose() {
    _listenTimer?.cancel();
    _sleepTimer?.cancel(); // Hủy Timer nếu app đóng
    audioPlayer.dispose();
    super.onClose();
  }
}
