import 'package:http/http.dart' as http;
import '../../core/constants/app_urls.dart';

class HomeRepository {
  Future<http.Response> fetchCategories() {
    return http.get(Uri.parse(AppUrls.listCategory));
  }

  Future<http.Response> fetchSongs() {
    return http.get(Uri.parse(AppUrls.listSong));
  }

  Future<http.Response> fetchAlbums() {
    return http.get(Uri.parse(AppUrls.listAlbum));
  }

  Future<http.Response> fetchArtists() {
    return http.get(Uri.parse(AppUrls.listArtist));
  }
}
