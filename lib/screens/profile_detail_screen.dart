import 'package:flutter/material.dart';
import '../models/profile.dart';

class ProfileDetailScreen extends StatelessWidget {
  final Profile profile;

  const ProfileDetailScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '${profile.name}님의 프로필',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              // 홈 화면으로 돌아가기 (모든 화면을 팝하고 홈으로)
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text(
              '취소',
              style: TextStyle(
                color: Color(0xFF87CEEB),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 스크롤 가능한 컨텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 프로필 헤더
                  _buildProfileHeader(),
                  const SizedBox(height: 32),

                  // 상세 자기소개
                  _buildSection(
                    title: '자기소개',
                    icon: Icons.person_outline,
                    content: profile.detailedIntroduction ?? '',
                  ),
                  const SizedBox(height: 32),

                  // MBTI
                  _buildSection(
                    title: 'MBTI',
                    icon: Icons.psychology_outlined,
                    content: profile.mbti ?? '',
                    isShort: true,
                  ),
                  const SizedBox(height: 32),

                  // 이상형
                  _buildSection(
                    title: '이상형',
                    icon: Icons.favorite_outline,
                    content: profile.idealType ?? '',
                  ),
                  const SizedBox(height: 20),

                  if ((profile.faithConfession ?? '').isNotEmpty) ...[
                    _buildSection(
                      title: '신앙고백',
                      icon: Icons.church_outlined,
                      content: profile.faithConfession!,
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),

          // 고정된 하단 버튼
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(child: _buildActionButton(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF87CEEB).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF87CEEB).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 프로필 이미지
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: const Color(0xFF87CEEB).withOpacity(0.2),
            ),
            child: const Icon(Icons.person, size: 50, color: Color(0xFF87CEEB)),
          ),
          const SizedBox(width: 20),

          // 기본 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _buildBasicInfoLine(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // 취미 태그들
                if (profile.hobbies.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        profile.hobbies.map((hobby) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF87CEEB).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              hobby,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF87CEEB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
    bool isShort = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF87CEEB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF87CEEB)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 내용
          if (content.isNotEmpty)
            Text(
              content,
              style: TextStyle(
                fontSize: isShort ? 20 : 15,
                color: Colors.black87,
                height: 1.6,
                fontWeight: isShort ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  String _buildBasicInfoLine() {
    final parts = <String>[];
    if (profile.age.isNotEmpty && profile.age != '-') {
      parts.add(profile.age);
    }
    if (profile.occupation.isNotEmpty) {
      parts.add(profile.occupation);
    }
    if (parts.isEmpty) {
      return '-';
    }
    return parts.join(' • ');
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // TODO: 연락처 교환 또는 메시지 보내기 기능
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${profile.name}님에게 관심을 표현했습니다!'),
              backgroundColor: const Color(0xFF87CEEB),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF87CEEB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 24),
            SizedBox(width: 12),
            Text(
              '연락처 교환 신청하기',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
