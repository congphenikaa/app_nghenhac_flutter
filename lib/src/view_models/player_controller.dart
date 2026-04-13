import 'dart:convert';
import 'dart:async';
import 'package:app_nghenhac/src/core/constants/app_urls.dart';
import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../services/image_color_service.dart';

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

  // CÁC BIẾN MỚI CHO TÍNH NĂNG
  var dominantColor = const Color(0xFF121212).obs;
  var playbackSpeed = 1.0.obs;
  var isTimerActive = false.obs;
  var pauseOnSongEnd = false.obs;
  var selectedSleepMinutes = (-1).obs;
  Timer? _sleepTimer;

  // Quản lý Playlist
  var currentSong = Rxn<SongModel>();
  var playlist = <SongModel>[].obs;
  var currentIndex = 0.obs;

  // Chế độ phát (Lắng nghe từ Native)
  var isShuffleMode = true.obs;
  var loopMode = LoopMode.all.obs;

  // Kích hoạt UI render lại danh sách chờ khi Shuffle/Loop thay đổi
  var queueTrigger = 0.obs;

  // Biến đếm lượt nghe
  Timer? _listenTimer;
  int _listenDuration = 0;
  bool _hasCountedView = false;

  // Lưu vết index trước đó để xử lý hẹn giờ tắt
  int? _lastIndex;

  @override
  void onInit() {
    super.onInit();

    // 1. Lắng nghe trạng thái Play/Pause
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    // 2. Lắng nghe chế độ Trộn bài (Chuẩn chuyên nghiệp: Lấy từ Native Engine)
    audioPlayer.shuffleModeEnabledStream.listen((enabled) {
      isShuffleMode.value = enabled;
      queueTrigger.value++; // Cập nhật lại danh sách chờ trên UI
    });

    // 3. Lắng nghe chế độ Lặp bài (Chuẩn chuyên nghiệp)
    audioPlayer.loopModeStream.listen((mode) {
      loopMode.value = mode;
    });

    // 4. Lắng nghe sự thay đổi Bài hát (Để đồng bộ khi chuyển bài tự động/Bluetooth)
    audioPlayer.currentIndexStream.listen((index) {
      if (index != null && playlist.isNotEmpty && index < playlist.length) {
        // Logic Hẹn giờ: Nếu đổi bài mà đang bật "Tắt sau khi hết bài"
        if (_lastIndex != null && _lastIndex != index && pauseOnSongEnd.value) {
          audioPlayer.pause();
          cancelSleepTimer();
        }
        _lastIndex = index;

        currentIndex.value = index;
        currentSong.value = playlist[index];
        updateMiniPlayerVisibility();
        updateDominantColor(playlist[index].imageUrl);

        // Reset logic đếm view cho bài hát mới
        _hasCountedView = false;
        _listenDuration = 0;
        _listenTimer?.cancel();
        _startPlayCountListener(playlist[index].id);
      }
    });

    // 5. Lắng nghe sự thay đổi của Hàng đợi
    audioPlayer.sequenceStateStream.listen((state) {
      queueTrigger.value++;
    });

    audioPlayer.positionStream.listen((position) => progress.value = position);
    audioPlayer.bufferedPositionStream.listen(
      (bufferedPosition) => buffered.value = bufferedPosition,
    );
    audioPlayer.durationStream.listen((duration) {
      if (duration != null) totalDuration.value = duration;
    });
  }

  // --- HÀM NÀY CHẠY SAU KHI ON_INIT HOÀN TẤT VÀ CONTROLLER ĐÃ SẴN SÀNG ---
  @override
  void onReady() {
    super.onReady();
    // Ép Native Engine bật Trộn bài và Lặp bài.
    // Việc gọi ở đây đảm bảo giao diện lập tức nhận lại tín hiệu 'True' và sáng đèn Xanh!
    audioPlayer.setShuffleModeEnabled(true);
    audioPlayer.setLoopMode(LoopMode.all);
  }

  // --- GETTER: Lấy danh sách chờ cực chuẩn từ Native AudioPlayer ---
  List<SongModel> get upcomingSongs {
    queueTrigger.value;
    if (playlist.isEmpty || audioPlayer.currentIndex == null) return [];

    // just_audio xử lý việc xáo trộn (shuffle) bên trong bằng cách tạo ra một mảng index ảo
    // Chúng ta chỉ cần lấy mảng ảo này ra để hiển thị đúng thứ tự bài hát tiếp theo
    final indices =
        audioPlayer.effectiveIndices ??
        List.generate(playlist.length, (i) => i);
    final currentIndexInEffective = indices.indexOf(audioPlayer.currentIndex!);

    if (currentIndexInEffective == -1) return [];

    List<SongModel> upcoming = [];
    for (int i = currentIndexInEffective + 1; i < indices.length; i++) {
      upcoming.add(playlist[indices[i]]);
    }
    return upcoming;
  }

  // --- HÀM PHÁT NHẠC ---
  Future<void> playSong(SongModel song, {List<SongModel>? newQueue}) async {
    try {
      bool isNewQueue = false;

      // Kiểm tra xem danh sách truyền vào có khác danh sách hiện tại không
      if (newQueue != null && newQueue.isNotEmpty) {
        if (playlist.length != newQueue.length) {
          isNewQueue = true;
        } else {
          for (int i = 0; i < playlist.length; i++) {
            if (playlist[i].id != newQueue[i].id) {
              isNewQueue = true;
              break;
            }
          }
        }
        if (isNewQueue) playlist.value = List.from(newQueue);
      } else if (playlist.isEmpty) {
        playlist.value = [song];
        isNewQueue = true;
      }

      int index = playlist.indexWhere((s) => s.id == song.id);
      if (index == -1) {
        playlist.add(song);
        index = playlist.length - 1;
        isNewQueue = true;
      }

      if (isNewQueue) {
        final audioSources = playlist
            .map(
              (s) => AudioSource.uri(
                Uri.parse(s.audioUrl),
                tag: MediaItem(
                  id: s.id,
                  album: s.album,
                  title: s.title,
                  artist: s.artist,
                  artUri: Uri.parse(s.imageUrl),
                ),
              ),
            )
            .toList();

        final concatenatingAudioSource = ConcatenatingAudioSource(
          children: audioSources,
        );

        await audioPlayer.setAudioSource(
          concatenatingAudioSource,
          initialIndex: index,
          initialPosition: Duration.zero,
        );

        // Nếu đang bật trộn bài, yêu cầu engine xáo trộn danh sách mới này
        if (isShuffleMode.value) {
          await audioPlayer.shuffle();
        }
      } else {
        await audioPlayer.seek(Duration.zero, index: index);
      }

      audioPlayer.play();
    } catch (e) {
      debugPrint("Lỗi phát nhạc: $e");
    }
  }

  // --- ĐIỀU KHIỂN CHUẨN SPOTIFY ---
  void nextSong() {
    // Nếu có bài tiếp theo trong hàng đợi (đã tính cả việc Shuffle)
    if (audioPlayer.hasNext) {
      audioPlayer.seekToNext();
    } else if (loopMode.value == LoopMode.all) {
      // Nếu hết danh sách MÀ ĐANG BẬT LOOP ALL -> Quay lại bài đầu tiên
      audioPlayer.seek(
        Duration.zero,
        index: audioPlayer.effectiveIndices?.first ?? 0,
      );
    } else {
      // Nếu hết bài và không bật lặp -> Dừng nhạc (Chuẩn Spotify)
      audioPlayer.seek(Duration.zero);
      audioPlayer.pause();
    }
  }

  void previousSong() {
    // Nếu nhạc đã phát quá 5 giây -> Bấm Prev là hát lại từ đầu bài đó
    if (audioPlayer.position.inSeconds > 5) {
      audioPlayer.seek(Duration.zero);
    }
    // Nếu phát dưới 5 giây -> Lùi về bài trước đó
    else if (audioPlayer.hasPrevious) {
      audioPlayer.seekToPrevious();
    }
    // Nếu đang ở bài đầu tiên -> Chỉ lùi về giây thứ 0
    else {
      audioPlayer.seek(Duration.zero);
    }
  }

  // Cải tiến: Trộn lại (shuffle) để tạo một chuỗi ngẫu nhiên mới mỗi lần bật
  Future<void> toggleShuffle() async {
    final enable = !isShuffleMode.value;
    if (enable) {
      await audioPlayer.shuffle(); // Sinh ra thuật toán xáo trộn mới
    }
    await audioPlayer.setShuffleModeEnabled(enable);
  }

  // Cải tiến: Giao phó việc chuyển trạng thái cho Native Engine
  Future<void> cycleLoopMode() async {
    switch (audioPlayer.loopMode) {
      case LoopMode.off:
        await audioPlayer.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        await audioPlayer.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        await audioPlayer.setLoopMode(LoopMode.off);
        break;
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

  // --- CÁC HÀM TIỆN ÍCH ---
  Future<void> updateDominantColor(String imageUrl) async {
    dominantColor.value = await ImageColorService.getDominantColor(imageUrl);
  }

  void changeSpeed(double speed) {
    playbackSpeed.value = speed;
    audioPlayer.setSpeed(speed);
  }

  void setSleepTimer(int minutes) {
    cancelSleepTimer();
    isTimerActive.value = true;
    selectedSleepMinutes.value = minutes;

    if (minutes == 0) {
      pauseOnSongEnd.value = true;
      Get.snackbar(
        "Hẹn giờ tắt",
        "Sẽ dừng nhạc sau khi hết bài hát này",
        icon: const Icon(Icons.timer, color: Colors.white),
        backgroundColor: const Color(0xFF1C2E24),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Hẹn giờ tắt",
        "Sẽ dừng nhạc sau $minutes phút",
        icon: const Icon(Icons.timer, color: Colors.white),
        backgroundColor: const Color(0xFF1C2E24),
        colorText: Colors.white,
      );
      _sleepTimer = Timer(Duration(minutes: minutes), () {
        audioPlayer.pause();
        cancelSleepTimer();
      });
    }
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    pauseOnSongEnd.value = false;
    isTimerActive.value = false;
    selectedSleepMinutes.value = -1;
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
        debugPrint(
          "Trạng thái cộng view: ${jsonDecode(response.body)['message']}",
        );
      }
    } catch (e) {
      debugPrint("Lỗi kết nối tăng view: $e");
    }
  }

  void updateMiniPlayerVisibility() {
    miniPlayerHeight.value = (currentSong.value != null) ? 80.0 : 0.0;
  }

  @override
  void onClose() {
    _listenTimer?.cancel();
    _sleepTimer?.cancel();
    audioPlayer.dispose();
    super.onClose();
  }
}
