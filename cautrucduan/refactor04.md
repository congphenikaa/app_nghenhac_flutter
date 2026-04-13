KẾ HOẠCH TÁI CẤU TRÚC 04: NAMED ROUTES & BINDINGS

Mục tiêu: Áp dụng quản lý Route tập trung của GetX, tự động hóa tiêm (inject) Controller qua Bindings.

BƯỚC 1: TẠO ROUTE

Tạo thư mục: lib/src/core/routes/

Tạo app_routes.dart: Khai báo hằng số String cho route (VD: static const HOME = '/home';).

Tạo app_pages.dart: Danh sách GetPage(...) ánh xạ Route với View và Binding.

BƯỚC 2: TẠO BINDINGS

Tạo thư mục: lib/src/bindings/

Đổi tên app_binding.dart thành main_binding.dart (hoặc giữ nguyên) chứa PlayerController, AuthController.

Tạo HomeBinding, LibraryBinding, SearchBinding để Get.lazyPut các controller tương ứng.

BƯỚC 3: CẬP NHẬT ĐIỀU HƯỚNG VÀ MAIN

Sửa main.dart: Dùng initialRoute và getPages: AppPages.pages.

Thay thế toàn bộ Get.to(() => Screen()) bằng Get.toNamed(...). Cập nhật truyền argument cho các màn Detail.