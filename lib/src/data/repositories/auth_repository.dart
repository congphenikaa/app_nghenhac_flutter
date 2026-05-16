import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../core/constants/app_urls.dart';

class AuthRepository {
  Future<http.Response> fetchUserProfile(String userId, String token) {
    return http.get(
      Uri.parse('${AppUrls.userDetail}/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> login(String email, String password) {
    return http.post(
      Uri.parse(AppUrls.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  Future<http.Response> register(String name, String email, String password) {
    return http.post(
      Uri.parse(AppUrls.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': name,
        'email': email,
        'password': password,
        'gender': 'other',
      }),
    );
  }

  Future<http.Response> loginWithGoogle(String idToken) {
    return http.post(
      Uri.parse(AppUrls.googleLogin),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );
  }

  Future<http.Response> toggleLikeSong(String songId, String? token) {
    return http.post(
      Uri.parse(AppUrls.toggleLike),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'songId': songId}),
    );
  }

  Future<http.Response> toggleFollowArtist(String artistId, String? token) {
    return http.post(
      Uri.parse(AppUrls.toggleFollow),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'artistId': artistId}),
    );
  }

  Future<http.Response> updateProfile({
    String? name,
    String? gender,
    File? imageFile,
    required String token,
  }) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse(AppUrls.updateProfile),
    );
    request.headers.addAll({'Authorization': 'Bearer $token'});

    if (name != null && name.isNotEmpty) request.fields['username'] = name;
    if (gender != null) request.fields['gender'] = gender;

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
}
