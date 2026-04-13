KẾ HOẠCH TÁI CẤU TRÚC 09: WRAPPER, MINIPLAYER & DETAIL SCREENS (BẢN CHI TIẾT CẤP ĐỘ FILE)

NGUYÊN TẮC THỰC THI CHO AI:

Tuyệt đối giữ nguyên logic của GetX (Get.put, Get.find, Obx). KHÔNG tự ý thay đổi State Management.

Chỉ thực hiện việc tạo thư mục, di chuyển file và cập nhật lại đường dẫn import bị hỏng.

Đổi tên file MiniPlayer.dart tuân thủ chuẩn snake_case của ngôn ngữ Dart.

BƯỚC 1: XỬ LÝ MAIN WRAPPER VÀ MINIPLAYER

Tạo thư mục mới: lib/src/views/main/ và lib/src/widgets/common/ (nếu chưa tồn tại).

Đổi tên và di chuyển MiniPlayer:

Nguồn: lib/src/views/MiniPlayer.dart

Đích: lib/src/widgets/common/mini_player.dart

Nhiệm vụ Import:

Sửa import player_screen.dart thành đường dẫn đúng (VD: import '../../views/player/player_screen.dart').

Sửa import ../view_models/player_controller.dart thành ../../view_models/player_controller.dart.

Di chuyển MainWrapper:

Nguồn: lib/src/views/main_wrapper.dart

Đích: lib/src/views/main/main_wrapper.dart

Nhiệm vụ Import:

Đổi import 'package:app_nghenhac/src/views/MiniPlayer.dart'; -> import 'package:app_nghenhac/src/widgets/common/mini_player.dart';

Cập nhật đường dẫn tới HomeScreen, SearchScreen, LibraryScreen, PremiumScreen theo cấu trúc thư mục mới.

BƯỚC 2: QUY HOẠCH CÁC MÀN HÌNH CHI TIẾT (DETAILS)

Thực hiện chuyển các file sau vào thư mục tương ứng và cập nhật lại import tương đối (../ thành ../../ cho models, configs, view_models):

Artist Detail:

Nguồn: lib/src/views/artist_detail_screen.dart

Đích: lib/src/views/artist/artist_detail_screen.dart

Album Detail:

Nguồn: lib/src/views/album_detail_screen.dart

Đích: lib/src/views/album/album_detail_screen.dart

Category Detail:

Nguồn: lib/src/views/category_detail_screen.dart

Đích: lib/src/views/category/category_detail_screen.dart

BƯỚC 3: QUY HOẠCH PREMIUM SCREEN

Tạo thư mục: lib/src/views/premium/

Di chuyển file:

Nguồn: lib/src/views/premium_screen.dart

Đích: lib/src/views/premium/premium_screen.dart

BƯỚC 4: RÀ SOÁT IMPORT TOÀN DỰ ÁN (QUAN TRỌNG)

AI hãy tự động chạy quét (scan) toàn bộ thư mục lib/src/ để sửa các chuỗi import cũ:

Quét các file có import MiniPlayer.dart và sửa thành mini_player.dart.

Chạy lệnh flutter analyze ngầm (nếu công cụ hỗ trợ) để đảm bảo không có màn hình nào bị lỗi gạch chân đỏ do sai đường dẫn file.