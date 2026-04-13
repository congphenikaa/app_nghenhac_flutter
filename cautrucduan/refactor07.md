KẾ HOẠCH TÁI CẤU TRÚC 07: AUTH & PROFILE WIDGET EXTRACTION

Mục tiêu: Quy hoạch màn hình Đăng nhập, Hồ sơ, tách các widget dùng chung (TextField, Button).

BƯỚC 1: QUY HOẠCH THƯ MỤC

Tạo lib/src/views/profile/ và chuyển profile_screen.dart, edit_profile_screen.dart vào.

Chuyển login_screen.dart, register_screen.dart vào lib/src/views/auth/.

Tạo lib/src/widgets/common/.

BƯỚC 2: TẠO COMMON WIDGETS

custom_text_field.dart: Trích xuất input từ màn hình Auth.

social_login_button.dart: Nút mạng xã hội.

BƯỚC 3: TÁCH WIDGET TỪ PROFILE

profile_header.dart: Khối hiển thị Avatar, Email, Tên.

profile_menu_item.dart: Trích xuất hàm build menu button.

BƯỚC 4: CẬP NHẬT EDIT PROFILE

Sử dụng CustomTextField. Tách khối avatar_picker_widget.dart.