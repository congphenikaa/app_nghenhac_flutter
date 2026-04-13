KẾ HOẠCH TÁI CẤU TRÚC 08: SERVICES & UTILITIES

Mục tiêu: Gỡ bỏ các Logic nghiệp vụ phần cứng khỏi Giao diện và Controller.

BƯỚC 1: TẠO SHARE SERVICE

Tạo lib/src/services/share_service.dart.

Chuyển hàm _shareSongAndImage từ ShareMenuSheet sang đây. Đổi tên thành ShareService.shareSongToStory.

Nhận tham số SongModel và linkUrl.

BƯỚC 2: TẠO IMAGE COLOR SERVICE

Tạo lib/src/services/image_color_service.dart.

Tạo static Future<Color> getDominantColor(String imageUrl).

Cắt logic PaletteGenerator từ PlayerController dán vào đây.

BƯỚC 3: UTILITIES

Tạo lib/src/utils/format_utils.dart.

Thêm hàm static String formatDuration(Duration duration).

Cập nhật ProgressBar sử dụng hàm này (nếu tự build label).