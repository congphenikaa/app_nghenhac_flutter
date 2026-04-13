import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../core/constants/app_urls.dart';

class PlaylistRepository {
  Future<http.Response> fetchMyPlaylists(String userId) {
    return http.post(
      Uri.parse(AppUrls.playlistUserList),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
  }

  Future<http.Response> createPlaylist({
    required String name,
    required String desc,
    required String userId,
    File? imageFile,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppUrls.playlistCreate),
    );
    request.fields['name'] = name;
    request.fields['desc'] = desc;
    request.fields['userId'] = userId;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> updatePlaylist({
    required String playlistId,
    required String name,
    required String desc,
    File? imageFile,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppUrls.baseUrl}/api/playlist/update'),
    );
    request.fields['playlistId'] = playlistId;
    request.fields['name'] = name;
    request.fields['desc'] = desc;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> addSongToPlaylist(String playlistId, String songId) {
    return http.post(
      Uri.parse(AppUrls.playlistAddSong),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'playlistId': playlistId, 'songId': songId}),
    );
  }

  Future<http.Response> removeSongFromPlaylist(String playlistId, String songId) {
    return http.post(
      Uri.parse(AppUrls.playlistRemoveSong),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'playlistId': playlistId, 'songId': songId}),
    );
  }

  Future<http.Response> removePlaylist(String playlistId) {
    return http.post(
      Uri.parse(AppUrls.playlistRemove),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'playlistId': playlistId}),
    );
  }
}
