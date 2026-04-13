KẾ HOẠCH TÁI CẤU TRÚC 05: LIBRARY & PLAYLIST UI DECOMPOSITION

Mục tiêu: Quy hoạch Thư viện và Chi tiết Playlist.

BƯỚC 1: QUY HOẠCH THƯ MỤC

Tạo thư mục: lib/src/views/library/

Di chuyển library_screen.dart, playlist_detail_screen.dart, add_edit_playlist_screen.dart, liked_songs_screen.dart vào đây.

Tạo thư mục con: lib/src/views/library/widgets/

BƯỚC 2: TÁCH WIDGET TỪ LIBRARY SCREEN

library_empty_state.dart: Trích xuất phần hiển thị khi danh sách trống.

playlist_list_item.dart: Trích xuất ListTile hiển thị Playlist kèm PopupMenuButton.

BƯỚC 3: TÁCH WIDGET TỪ PLAYLIST DETAIL

playlist_sliver_app_bar.dart: Trích xuất SliverAppBar.

playlist_song_item.dart: Trích xuất ListTile bài hát trong playlist.

BƯỚC 4: CẬP NHẬT LIKED SONGS

Dùng lại playlist_song_item.dart hoặc tạo liked_song_item.dart có nút Unlike. Cập nhật lại các import lỗi.