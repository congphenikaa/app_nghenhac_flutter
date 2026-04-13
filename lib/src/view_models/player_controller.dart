import 'dart:convert';
import 'dart:async';
import 'package:app_nghenhac/src/core/constants/app_urls.dart';
import 'package:app_nghenhac/src/services/image_color_service.dart';
import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import 'package:just_audio_background/just_audio_background.dart';

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

  // Chế độ phát
  var isShuffleMode = false.obs;
  var loopMode = LoopMode.off.obs;

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

    // 2. Lắng nghe sự thay đổi Bài hát (Để đồng bộ khi bấm Next/Prev từ màn hình khóa)
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

    // 3. Lắng nghe sự thay đổi của Hàng đợi (để update danh sách UI)
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

  // --- GETTER: Lấy danh sách chờ cực chuẩn từ Native AudioPlayer ---
  List<SongModel> get upcomingSongs {
    queueTrigger.value; // Lắng nghe thay đổi
    if (playlist.isEmpty || audioPlayer.currentIndex == null) return [];

    // effectiveIndices chứa danh sách Index đã được Shuffle của just_audio
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

  // --- HÀM PHÁT NHẠC MỚI (Dùng ConcatenatingAudioSource) ---
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

      // NẾU LÀ DANH SÁCH MỚI -> Xây dựng lại ConcatenatingAudioSource
      if (isNewQueue) {
        final audioSources = playlist
            .map(
              (s) => AudioSource.uri(
                Uri.parse(s.audioUrl),
                // THẺ NÀY GIÚP HIỂN THỊ ẢNH VÀ THÔNG TIN LÊN MÀN HÌNH KHÓA/THANH THÔNG BÁO
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
      } else {
        // NẾU LÀ DANH SÁCH CŨ -> Chỉ cần Seek đến vị trí index (Rất nhanh, không bị khựng)
        await audioPlayer.seek(Duration.zero, index: index);
      }

      audioPlayer.play();
    } catch (e) {
      debugPrint("Lỗi phát nhạc: $e");
    }
  }

  void nextSong() {
    if (audioPlayer.hasNext) {
      audioPlayer.seekToNext();
    } else if (loopMode.value == LoopMode.all) {
      audioPlayer.seek(Duration.zero, index: 0);
    }
  }

  void previousSong() {
    if (audioPlayer.position.inSeconds > 5) {
      audioPlayer.seek(Duration.zero);
    } else if (audioPlayer.hasPrevious) {
      audioPlayer.seekToPrevious();
    } else {
      audioPlayer.seek(Duration.zero);
    }
  }

  void toggleShuffle() async {
    isShuffleMode.value = !isShuffleMode.value;
    await audioPlayer.setShuffleModeEnabled(isShuffleMode.value);
    if (isShuffleMode.value) {
      await audioPlayer.shuffle();
    }
  }

  void cycleLoopMode() async {
    switch (loopMode.value) {
      case LoopMode.off:
        loopMode.value = LoopMode.all;
        await audioPlayer.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        loopMode.value = LoopMode.one;
        await audioPlayer.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        loopMode.value = LoopMode.off;
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

  // --- CÁC HÀM TIỆN ÍCH VÀ API (Giữ nguyên) ---
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
