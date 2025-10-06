import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
    String? faithConfession,
    List<String>? hobbies,
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
    if (faithConfession != null) {
      body['faithConfession'] = faithConfession;
    }
    if (hobbies != null) {
      body['hobbies'] = hobbies;
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

  static Future<UserProfile> uploadProfilePhoto({
    required List<int> bytes,
    required String fileName,
    String? mimeType,
  }) async {
    final uri = Uri.parse('${AuthService.baseUrl}$_profilePath/photo/upload');

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fileName,
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
    );

    final response = await ApiClient.postMultipart(
      uri,
      headers: _buildHeaders(includeJsonContentType: false),
      files: [multipartFile],
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return UserProfile.fromJson(decoded);
      }

      throw Exception('Unexpected profile response format: ${response.body}');
    }

    throw Exception(
      'Failed to upload profile photo (${response.statusCode}): ${response.body}',
    );
  }

  static Future<UserProfile> updateSelfIntroduction(String selfIntroduction) {
    return _patchProfile(
      '/users/profile/self-introduction',
      {'selfIntroduction': selfIntroduction},
    );
  }

  static Future<UserProfile> updateMbit(String mbit) {
    return _patchProfile(
      '/users/profile/mbit',
      {'mbit': mbit},
    );
  }

  static Future<UserProfile> updateIdealType(String idealType) {
    return _patchProfile(
      '/users/profile/ideal-type',
      {'idealType': idealType},
    );
  }

  static Future<UserProfile> updateFaithConfession(String faithConfession) {
    return _patchProfile(
      '/users/profile/faith-confession',
      {'faithConfession': faithConfession},
    );
  }

  static Future<UserProfile> updateHobbies(List<String> hobbies) {
    return _patchProfile(
      '/users/profile/hobbies',
      {'hobbies': hobbies},
    );
  }

  static Future<UserProfile> _patchProfile(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse('${AuthService.baseUrl}$endpoint');
    final response = await ApiClient.patch(
      uri,
      headers: _buildHeaders(),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return UserProfile.fromJson(decoded);
      }

      throw Exception('Unexpected profile response format: ${response.body}');
    }

    throw Exception(
      'Failed to update profile (${response.statusCode}): ${response.body}',
    );
  }

  static Map<String, String> _buildHeaders({bool includeJsonContentType = true}) {
    final headers = <String, String>{};
    if (includeJsonContentType) {
      headers['Content-Type'] = 'application/json';
    }
    final token = AuthService.currentLoginResponse?.accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
