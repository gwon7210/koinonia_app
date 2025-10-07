import 'dart:convert';

import '../models/profile.dart';
import 'api_client.dart';
import 'auth_service.dart';

class UserSearchService {
  UserSearchService._();

  static const _searchPath = '/users/search';

  static Future<List<Profile>> fetchProfiles() async {
    final uri = Uri.parse('${AuthService.baseUrl}$_searchPath');
    final response = await ApiClient.get(uri, headers: _buildHeaders());

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(_mapSearchUserToProfile)
            .toList();
      }

      throw Exception('Unexpected search response format: ${response.body}');
    }

    throw Exception(
      'Failed to fetch search results (${response.statusCode}): ${response.body}',
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

  static Profile _mapSearchUserToProfile(Map<String, dynamic> json) {
    final profileJson =
        (json['profile'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final nickname = (profileJson['nickname'] as String?)?.trim();
    final introduction = (profileJson['selfIntroduction'] as String?)?.trim();
    final idealType = (profileJson['idealType'] as String?)?.trim();
    final faithConfession = (profileJson['faithConfession'] as String?)?.trim();
    final mbti = (profileJson['mbti'] as String?)?.trim();
    final imagePath = (profileJson['profileImagePath'] as String?)?.trim();
    final heightRaw = profileJson['height'];
    final hobbies =
        (profileJson['hobbies'] as List?)
            ?.whereType<String>()
            .map((hobby) => hobby.trim())
            .where((hobby) => hobby.isNotEmpty)
            .toList() ??
        const <String>[];

    final imageUrl =
        (imagePath != null && imagePath.isNotEmpty)
            ? AuthService.resolveAssetUrl(imagePath)
            : null;

    return Profile(
      id: (json['id'] as String?) ?? '',
      name: nickname?.isNotEmpty == true ? nickname! : '-',
      age: _extractBirthYear(json['birthDate'] as String?),
      occupation: '회사원',
      introduction: introduction?.isNotEmpty == true ? introduction : null,
      imageUrl: imageUrl,
      hobbies: hobbies,
      detailedIntroduction:
          introduction?.isNotEmpty == true ? introduction : null,
      mbti: mbti?.isNotEmpty == true ? mbti : null,
      idealType: idealType?.isNotEmpty == true ? idealType : null,
      faithConfession:
          faithConfession?.isNotEmpty == true ? faithConfession : null,
      height: _parseHeight(heightRaw),
    );
  }

  static String _extractBirthYear(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) {
      return '-';
    }

    try {
      return DateTime.parse(birthDate).year.toString();
    } catch (_) {
      return birthDate.length >= 4 ? birthDate.substring(0, 4) : '-';
    }
  }

  static String? _parseHeight(dynamic rawHeight) {
    if (rawHeight == null) {
      return null;
    }

    final value = rawHeight.toString().trim();
    if (value.isEmpty) {
      return null;
    }

    return value;
  }
}
