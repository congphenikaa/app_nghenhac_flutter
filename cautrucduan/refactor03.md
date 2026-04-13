KẾ HOẠCH TÁI CẤU TRÚC 03: HOME SCREEN UI DECOMPOSITION

Mục tiêu: Tách các Widget nội bộ trong home_screen.dart thành các file riêng biệt.

BƯỚC 1: QUY HOẠCH THƯ MỤC

Tạo thư mục: lib/src/views/home/

Di chuyển home_screen.dart vào thư mục này.

Tạo thư mục con: lib/src/views/home/widgets/

BƯỚC 2: TÁCH WIDGET TỪ HOME SCREEN

Tạo các file trong widgets/:

home_drawer.dart: Hàm _buildDrawer.

home_header.dart: Hàm _buildHeader.

category_filter_chips.dart: Hàm _buildFilterChips.

quick_access_grid.dart: Hàm _buildQuickAccessGrid.

new_releases_list.dart: Hàm _buildNewReleasesList.

popular_artists_list.dart: Hàm _buildPopularArtists.

top_mixes_list.dart: Hàm _buildTopMixes.

trending_chart_list.dart: Hàm _buildTopChartsList.

song_list_item.dart: Hàm _buildSongItem.

BƯỚC 3: LẮP RÁP LẠI HOME SCREEN

Sửa home_screen.dart gọi các Widget class này trong hàm build và _buildDashboardBody.