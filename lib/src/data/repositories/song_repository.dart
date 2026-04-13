import 'package:http/http.dart' as http;
import '../../core/constants/app_urls.dart';

class SongRepository {
  Future<http.Response> fetchTrendingTop() {
    return http.get(Uri.parse(AppUrls.topTrending));
  }

  Future<http.Response> fetchSongsByCategory(String categoryId) {
    return http.get(Uri.parse('${AppUrls.songByCategory}/$categoryId'));
  }

  Future<http.Response> searchGlobal(String query) {
    final encodedQuery = Uri.encodeComponent(query);
    return http.get(Uri.parse('${AppUrls.searchSong}?query=$encodedQuery'));
  }
}
