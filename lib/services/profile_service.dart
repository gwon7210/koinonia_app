import 'dart:convert';
import '../models/user_profile.dart';
import 'auth_service.dart';
import 'api_client.dart';

class ProfileService {
  static const _profilePath = '/users/profile';

  static Future<UserProfile?> fetchProfile() async {
    final uri = Uri.parse('${AuthService.baseUrl}$_profilePath');
    final response = await ApiClient.get(
      uri,
      headers: _buildHeaders(),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body.trim() == 'null') {
        return null;
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded == null) {
        return null;
      }

      if (decoded is Map<String, dynamic>) {
        return UserProfile.fromJson(decoded);
      }

      throw Exception('Unexpected profile response format: ${response.body}');
    }

    throw Exception(
      'Failed to fetch profile (${response.statusCode}): ${response.body}',
    );
  }

  static Future<UserProfile> upsertProfile({
    String? selfIntroduction,
    String? mbit,
    String? idealType,
  }) async {
    final uri = Uri.parse('${AuthService.baseUrl}$_profilePath');
    final body = <String, dynamic>{};

    if (selfIntroduction != null) {
      body['selfIntroduction'] = selfIntroduction;
    }
    if (mbit != null) {
      body['mbit'] = mbit;
    }
    if (idealType != null) {
      body['idealType'] = idealType;
    }

    final response = await ApiClient.post(
      uri,
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return UserProfile.fromJson(decoded);
      }

      throw Exception('Unexpected profile response format: ${response.body}');
    }

    throw Exception(
      'Failed to save profile (${response.statusCode}): ${response.body}',
    );
  }

  static Map<String, String> _buildHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = AuthService.currentLoginResponse?.accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
