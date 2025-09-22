import 'dart:convert';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../models/user.dart' as app_models;
import 'api_client.dart';

class AuthService {
  static const String baseUrl =
      'http://192.168.0.187:3000/api'; // 실제 API 서버 URL로 변경 필요

  static app_models.LoginResponse? _currentLoginResponse;
  static app_models.LoginResponse? get currentLoginResponse =>
      _currentLoginResponse;
  static app_models.User? get currentUser => _currentLoginResponse?.user;

  static Future<app_models.LoginResponse?> loginWithKakao() async {
    print('[AUTH] 카카오 로그인 시작');

    try {
      print('[AUTH] 카카오톡 로그인 시도 중...');
      // 카카오 로그인 실행
      OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
      print('[AUTH] 카카오톡 로그인 성공! 액세스 토큰 길이: ${token.accessToken.length}');
      print('[AUTH] 액세스 토큰: ${token.accessToken.substring(0, 20)}...');

      final url = '$baseUrl/auth/kakao';
      print('[AUTH] 서버 요청 URL: $url');
      print('[AUTH] 서버에 액세스 토큰 전송 중...');

      // 서버에 액세스 토큰 전송
      final response = await ApiClient.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accessToken': token.accessToken}),
      );

      print('[AUTH] 서버 응답 상태 코드: ${response.statusCode}');
      print('[AUTH] 서버 응답 헤더: ${response.headers}');
      print('[AUTH] 서버 응답 본문: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[AUTH] 로그인 성공! JSON 파싱 시도 중...');
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('[AUTH] JSON 파싱 성공: $data');

        final loginResponse = app_models.LoginResponse.fromJson(data);
        _currentLoginResponse = loginResponse;
        print(
          '[AUTH] LoginResponse 객체 생성 성공: isNewUser=${loginResponse.isNewUser}',
        );
        return loginResponse;
      } else {
        print('[AUTH] 로그인 실패: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (error, stackTrace) {
      print('[AUTH] 카카오 로그인 오류: $error');
      print('[AUTH] 스택 트레이스: $stackTrace');
      return null;
    }
  }

  static Future<app_models.LoginResponse?> loginWithKakaoTest({
    required String kakaoId,
    String? gender,
    String? birthDate,
    String? phoneNumber,
    String? nickname,
  }) async {
    print('[AUTH] 테스트 카카오 로그인 시작');

    try {
      final url = '$baseUrl/auth/kakao/test';
      print('[AUTH] 테스트 서버 요청 URL: $url');

      // 요청 데이터 구성
      final Map<String, dynamic> requestData = {'kakaoId': kakaoId};

      if (gender != null) requestData['gender'] = gender;
      if (birthDate != null) requestData['birthDate'] = birthDate;
      if (phoneNumber != null) requestData['phoneNumber'] = phoneNumber;
      if (nickname != null) requestData['nickname'] = nickname;

      print('[AUTH] 테스트 서버에 데이터 전송 중: $requestData');

      // 서버에 테스트 데이터 전송
      final response = await ApiClient.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print('[AUTH] 테스트 서버 응답 상태 코드: ${response.statusCode}');
      print('[AUTH] 테스트 서버 응답 헤더: ${response.headers}');
      print('[AUTH] 테스트 서버 응답 본문: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[AUTH] 테스트 로그인 성공! JSON 파싱 시도 중...');
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('[AUTH] JSON 파싱 성공: $data');

        final loginResponse = app_models.LoginResponse.fromJson(data);
        _currentLoginResponse = loginResponse;
        print(
          '[AUTH] LoginResponse 객체 생성 성공: isNewUser=${loginResponse.isNewUser}',
        );
        return loginResponse;
      } else {
        print('[AUTH] 테스트 로그인 실패: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (error, stackTrace) {
      print('[AUTH] 테스트 카카오 로그인 오류: $error');
      print('[AUTH] 스택 트레이스: $stackTrace');
      return null;
    }
  }
}
