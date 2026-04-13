KẾ HOẠCH TÁI CẤU TRÚC 02: PLAYER SCREEN UI DECOMPOSITION

Mục tiêu: Chia nhỏ file player_screen.dart thành các component nhỏ hơn.

BƯỚC 1: QUY HOẠCH THƯ MỤC

Tạo thư mục: lib/src/views/player/

Di chuyển player_screen.dart vào thư mục này.

Tạo thư mục con: lib/src/views/player/widgets/

BƯỚC 2: TÁCH WIDGET TỪ PLAYER SCREEN

Tạo 3 file trong thư mục widgets/:

player_header.dart (Class: PlayerHeader): Chứa AppBar (nút back, text "ĐANG PHÁT", nút 3 chấm).

player_artwork.dart (Class: PlayerArtwork): Chứa khối GestureDetector vuốt chuyển bài và ảnh bìa.

player_controls.dart (Class: PlayerControls): Chứa Thông tin bài hát, ProgressBar, Hàng nút điều khiển (Play/Pause, Prev, Next...), và Hàng nút tính năng (Speed, Share, Queue, Timer).

BƯỚC 3: LẮP RÁP LẠI PLAYER SCREEN

Cập nhật player_screen.dart chỉ còn là một Scaffold với hình nền Gradient, chứa Column gọi 3 widget vừa tạo. Truyền PlayerController vào các Widget này.