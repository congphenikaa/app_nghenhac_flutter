KẾ HOẠCH TÁI CẤU TRÚC 06: SEARCH & CHARTS UI DECOMPOSITION

Mục tiêu: Dọn dẹp giao diện Tìm kiếm và Bảng xếp hạng.

BƯỚC 1: QUY HOẠCH THƯ MỤC

Tạo thư mục: lib/src/views/search/ và lib/src/views/charts/

Di chuyển search_screen.dart vào search/, top_charts_screen.dart vào charts/.

Tạo thư mục widgets/ bên trong mỗi thư mục.

BƯỚC 2: TÁCH WIDGET TỪ SEARCH

search_bar_widget.dart: TextField tìm kiếm.

search_category_grid.dart: GridView duyệt tìm.

search_results_list.dart: Kết quả tìm kiếm (Bài hát, Nghệ sĩ, Album).

BƯỚC 3: TÁCH WIDGET TỪ CHARTS

chart_header.dart: SliverAppBar Bảng xếp hạng.

chart_song_item.dart: ListTile kèm logic hiển thị màu sắc theo thứ hạng (rank).