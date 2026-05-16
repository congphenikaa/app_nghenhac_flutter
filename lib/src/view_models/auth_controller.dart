import 'package:app_nghenhac/src/core/routes/app_pages.dart';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Khởi tạo GoogleSignIn với Web Client ID
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '374977006209-caohon1dvfgposucb7to4rjnqvb1fi23.apps.googleusercontent.com',
  );

  var isLoading = false.obs;

  // Biến lưu trữ thông tin User hiện tại (Quan trọng)
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  // Kiểm tra xem user đã đăng nhập chưa khi mở app
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');

    if (token != null && token.isNotEmpty && userId != null) {
      // Quan trọng: Khi mở lại app, token còn nhưng currentUser = null
      // Nên ta phải fetch lại thông tin user từ server
      await fetchUserProfile(userId, token);
      Get.offAllNamed(AppRoutes.MAIN);
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  // --- HÀM MỚI: LẤY THÔNG TIN USER TỪ SERVER ---
  Future<void> fetchUserProfile(String userId, String token) async {
    try {
      // Gọi API lấy chi tiết user (cần backend hỗ trợ API này)
      final response = await _authRepository.fetchUserProfile(userId, token);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Tùy backend trả về { success: true, user: {} } hay trả về trực tiếp {}
        if (data['user'] != null) {
          currentUser.value = UserModel.fromJson(data['user']);
        } else {
          currentUser.value = UserModel.fromJson(data);
        }
        print("Đã load lại thông tin user: ${currentUser.value?.username}");
      }
    } catch (e) {
      print("Lỗi tải thông tin user: $e");
      // Không logout ở đây, để user vẫn vào được app (offline mode chẳng hạn)
    }
  }

  // Hàm Đăng Nhập
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final response = await _authRepository.login(email, password);

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        // 1. Lưu token
        String token = "";
        if (data['token'] != null) {
          await prefs.setString('token', data['token']);
        }

        // 2. Lưu User ID & Cập nhật currentUser
        if (data['user'] != null) {
          String userId = data['user']['_id'] ?? "";

          if (userId.isNotEmpty) {
            await prefs.setString('userId', userId);

            // [FIX ĐỒNG BỘ]: Thay vì dùng ngay data['user'] (thường thiếu like/follow),
            // ta gọi fetchUserProfile để lấy dữ liệu đầy đủ từ server.
            await fetchUserProfile(userId, token);
          } else {
            // Fallback nếu không có ID
            currentUser.value = UserModel.fromJson(data['user']);
          }
        }

        Get.offAllNamed(AppRoutes.MAIN);
        Get.snackbar("Thành công", "Chào mừng quay trở lại!");
      } else {
        Get.snackbar("Lỗi", data['message'] ?? "Đăng nhập thất bại");
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể kết nối server");
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Hàm Đăng Ký
  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;

      final response = await _authRepository.register(name, email, password);

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        String? token = data['token'];
        if (token == null && data['user'] != null) {
          token =
              data['user']['token']; // Fallback nếu backend trả token trong user object
        }
        if (token != null) await prefs.setString('token', token);

        if (data['user'] != null) {
          String userId = data['user']['_id'] ?? "";
          if (userId.isNotEmpty) {
            await prefs.setString('userId', userId);

            // [FIX ĐỒNG BỘ]: Gọi fetchUserProfile ngay sau khi đăng ký thành công
            if (token != null) {
              await fetchUserProfile(userId, token);
            } else {
              currentUser.value = UserModel.fromJson(data['user']);
            }
          }
        }

        Get.offAllNamed(AppRoutes.MAIN);
        Get.snackbar("Thành công", "Tạo tài khoản thành công!");
      } else {
        Get.snackbar(
          "Đăng ký thất bại",
          data['message'] ?? "Lỗi không xác định",
        );
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể kết nối server");
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== GOOGLE LOGIN ====================
  Future<void> loginWithGoogle({bool forceAccountPicker = false}) async {
    try {
      isLoading.value = true;

      // Nếu muốn buộc chọn tài khoản khác → đăng xuất trước
      if (forceAccountPicker) {
        await _googleSignIn.signOut();
        // await _googleSignIn.disconnect(); // Dùng cái này nếu muốn xóa hoàn toàn
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        isLoading.value = false;
        return; // Người dùng hủy
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        Get.snackbar("Lỗi", "Không lấy được ID Token từ Google");
        isLoading.value = false;
        return;
      }

      final response = await _authRepository.loginWithGoogle(idToken);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('userId', data['user']['_id']);

        await fetchUserProfile(data['user']['_id'], data['token']);
        Get.offAllNamed(AppRoutes.MAIN);
        Get.snackbar("Thành công", "Đăng nhập Google thành công");
      } else {
        Get.snackbar("Lỗi", data['message'] ?? "Đăng nhập thất bại");
      }
    } catch (e) {
      print("Google Login Error: $e");
      Get.snackbar("Lỗi", "Không thể đăng nhập bằng Google");
    } finally {
      isLoading.value = false;
    }
  }

  // Hàm Đăng Xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');

    // Xóa dữ liệu user trong bộ nhớ RAM
    currentUser.value = null;

    Get.offAllNamed(AppRoutes.LOGIN);
  }

  // --- THÍCH / BỎ THÍCH BÀI HÁT ---
  Future<void> toggleLikeSong(String songId) async {
    if (currentUser.value == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // 1. CẬP NHẬT UI NGAY LẬP TỨC (Optimistic UI Update)
    // Để người dùng thấy tim đỏ ngay, không cần đợi server trả về
    final isLiked = currentUser.value!.likedSongIds.contains(songId);
    if (isLiked) {
      currentUser.value!.likedSongIds.remove(songId);
    } else {
      currentUser.value!.likedSongIds.add(songId);
    }
    currentUser
        .refresh(); // Báo cho GetX biết dữ liệu đã thay đổi để vẽ lại UI (Profile, Player)

    // 2. GỌI SERVER
    try {
      final response = await _authRepository.toggleLikeSong(songId, token);

      if (response.statusCode != 200) {
        // Nếu lỗi, hoàn tác lại UI
        if (isLiked) {
          currentUser.value!.likedSongIds.add(songId);
        } else {
          currentUser.value!.likedSongIds.remove(songId);
        }
        currentUser.refresh();
        Get.snackbar("Lỗi", "Không thể thích bài hát này");
      }
    } catch (e) {
      print("Lỗi like song: $e");
    }
  }

  // --- HÀM MỚI: FOLLOW / UNFOLLOW NGHỆ SĨ ---
  Future<void> toggleFollowArtist(String artistId) async {
    if (currentUser.value == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // 1. CẬP NHẬT UI NGAY LẬP TỨC
    final isFollowing = currentUser.value!.followedArtistIds.contains(artistId);
    if (isFollowing) {
      currentUser.value!.followedArtistIds.remove(artistId);
    } else {
      currentUser.value!.followedArtistIds.add(artistId);
    }
    currentUser.refresh(); // Update Profile count ngay lập tức

    // 2. GỌI SERVER
    try {
      final response = await _authRepository.toggleFollowArtist(
        artistId,
        token,
      );

      if (response.statusCode != 200) {
        // Hoàn tác nếu lỗi
        if (isFollowing) {
          currentUser.value!.followedArtistIds.add(artistId);
        } else {
          currentUser.value!.followedArtistIds.remove(artistId);
        }
        currentUser.refresh();
        Get.snackbar("Lỗi", "Không thể theo dõi nghệ sĩ này");
      }
    } catch (e) {
      print("Lỗi follow artist: $e");
    }
  }

  // --- HÀM CẬP NHẬT HỒ SƠ (Dùng Multipart để gửi file) ---
  Future<bool> updateProfile({
    String? name,
    String? gender,
    File? imageFile,
  }) async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return false;

      final response = await _authRepository.updateProfile(
        name: name,
        gender: gender,
        imageFile: imageFile,
        token: token,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (data['user'] != null) {
          currentUser.value = UserModel.fromJson(data['user']);
          currentUser.refresh();
        }
        // Controller tự hiện thông báo thành công
        Get.snackbar("Thành công", "Đã cập nhật hồ sơ");
        return true;
      } else {
        Get.snackbar("Lỗi", data['message'] ?? "Cập nhật thất bại");
        return false;
      }
    } catch (e) {
      print("Update error: $e");
      Get.snackbar("Lỗi", "Không thể kết nối server");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
