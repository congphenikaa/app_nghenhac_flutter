KẾ HOẠCH TÁI CẤU TRÚC 10: CORE CONSTANTS & MODELS REFINEMENT

Mục tiêu: Chuẩn hóa lại vị trí của các file cấu hình URL và rà soát lại các file Models để đảm bảo code an toàn (null-safety) và dễ bảo trì.

BƯỚC 1: QUY HOẠCH CORE NETWORK CONSTANTS

Cấu hình API URL là thành phần cốt lõi của ứng dụng (Core). Việc để ở thư mục configs/ là ổn, nhưng đưa vào core/constants/ sẽ chuẩn mực hơn theo Clean Architecture.

Tạo thư mục: lib/src/core/constants/

Di chuyển file app_urls.dart:

Nguồn: lib/src/configs/app_urls.dart

Đích: lib/src/core/constants/app_urls.dart

Cập nhật lại class AppUrls: Đổi các trường static const String liên quan đến màu sắc, kích thước (nếu có sau này) ra một file app_colors.dart riêng biệt. Hiện tại app_urls.dart chỉ chứa URL.

Nhiệm vụ bắt buộc: AI phải chạy công cụ tìm kiếm và sửa lại toàn bộ đường dẫn import '../../configs/app_urls.dart' thành import '../../core/constants/app_urls.dart' trong tất cả các Repository và Controller.

BƯỚC 2: RÀ SOÁT LẠI THƯ MỤC MODELS

Cấu trúc lib/src/models/ của bạn đã RẤT CHUẨN. AI không cần di chuyển bất kỳ file nào trong thư mục này. Tuy nhiên, AI cần thực hiện rà soát mã nguồn (Code Review) bên trong các file Model:

Kiểm tra Null-Safety: Đảm bảo tất cả các file (album_model.dart, artist_model.dart, category_model.dart, playlist_model.dart, song_model.dart, user_model.dart) đều xử lý an toàn với toán tử ?? khi parse từ JSON. (Hiện tại bạn đã làm rất tốt việc này, AI chỉ cần verify lại).

Kiểm tra kiểu dữ liệu List: Đảm bảo các mảng (List) được parse an toàn bằng hàm phụ trợ (như bạn đã làm trong playlist_model.dart và user_model.dart).

BƯỚC 3: DỌN DẸP THƯ MỤC RÁC

Nếu thư mục lib/src/configs/ trở nên trống rỗng sau Bước 1, AI hãy xóa thư mục configs đi để giữ dự án gọn gàng.