import 'dart:convert';
import 'package:app_nghenhac/src/core/constants/app_urls.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ArtistRequestRepository {
  Future<http.Response> submitRequest({
    required String artistName,
    required String bio,
    required String reason,
    List<String> genre = const [],
    Map<String, String> socialLinks = const {},
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return http.post(
      Uri.parse(AppUrls.artistRequestSubmit),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'artistName': artistName,
        'bio': bio,
        'reason': reason,
        'genre': genre,
        'socialLinks': socialLinks,
      }),
    );
  }

  Future<http.Response> getMyRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return http.get(
      Uri.parse(AppUrls.artistRequestMy),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> cancelRequest(String requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return http.delete(
      Uri.parse('${AppUrls.artistRequestBase}/$requestId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }
}
