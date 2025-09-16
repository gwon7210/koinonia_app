import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 사용자 정보 (임시 데이터)
  String _introduction =
      '안녕하세요! 하나님의 사랑 안에서 함께 성장할 수 있는 분을 찾고 있어요. 신앙 안에서 서로를 격려하며 함께 걸어갈 동반자를 만나고 싶습니다.';
  String _idealType =
      '신앙이 깊고 진실한 분이면 좋겠어요. 서로의 꿈을 응원해주고 함께 기도할 수 있는 분을 만나고 싶습니다.';
  String _mbti = 'ENFJ';

  // 수정 모드 상태
  bool _isEditing = false;

  // 텍스트 컨트롤러
  late TextEditingController _introductionController;
  late TextEditingController _idealTypeController;
  late TextEditingController _mbtiController;

  @override
  void initState() {
    super.initState();
    _introductionController = TextEditingController(text: _introduction);
    _idealTypeController = TextEditingController(text: _idealType);
    _mbtiController = TextEditingController(text: _mbti);
  }

  @override
  void dispose() {
    _introductionController.dispose();
    _idealTypeController.dispose();
    _mbtiController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // 수정 모드 종료 시 원래 값으로 되돌리기
        _introductionController.text = _introduction;
        _idealTypeController.text = _idealType;
        _mbtiController.text = _mbti;
      }
    });
  }

  void _saveChanges() {
    setState(() {
      _introduction = _introductionController.text;
      _idealType = _idealTypeController.text;
      _mbti = _mbtiController.text;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('프로필이 저장되었습니다!'),
        backgroundColor: Color(0xFF87CEEB),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Text(
                    '프로필',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  // 수정/저장 버튼
                  if (_isEditing) ...[
                    TextButton(
                      onPressed: _toggleEditMode,
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF87CEEB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else
                    IconButton(
                      onPressed: _toggleEditMode,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF87CEEB),
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),

            // 프로필 정보
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프로필 헤더
                    _buildProfileHeader(),
                    const SizedBox(height: 32),

                    // 자기소개
                    _buildEditableSection(
                      title: '자기소개',
                      icon: Icons.person_outline,
                      controller: _introductionController,
                      isMultiline: true,
                    ),
                    const SizedBox(height: 24),

                    // MBTI
                    _buildEditableSection(
                      title: 'MBTI',
                      icon: Icons.psychology_outlined,
                      controller: _mbtiController,
                      isMultiline: false,
                    ),
                    const SizedBox(height: 24),

                    // 이상형
                    _buildEditableSection(
                      title: '이상형',
                      icon: Icons.favorite_outline,
                      controller: _idealTypeController,
                      isMultiline: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: const Color(0xFF87CEEB).withOpacity(0.2),
            ),
            child: const Icon(Icons.person, color: Color(0xFF87CEEB), size: 40),
          ),
          const SizedBox(width: 20),

          // 기본 정보
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '내 프로필',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '개척교회 청년',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableSection({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required bool isMultiline,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              _isEditing
                  ? const Color(0xFF87CEEB).withOpacity(0.3)
                  : Colors.grey.withOpacity(0.15),
          width: 1,
        ),
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
              const Spacer(),
              if (_isEditing)
                Icon(Icons.edit, size: 16, color: Colors.grey[600]),
            ],
          ),
          const SizedBox(height: 16),

          // 내용 (수정 가능/읽기 전용)
          if (_isEditing)
            TextField(
              controller: controller,
              maxLines: isMultiline ? 4 : 1,
              decoration: InputDecoration(
                hintText: '${title}을 입력해주세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF87CEEB),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF87CEEB),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            )
          else
            Text(
              controller.text,
              style: TextStyle(
                fontSize: isMultiline ? 15 : 18,
                color: Colors.black87,
                height: isMultiline ? 1.6 : 1.2,
                fontWeight: isMultiline ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
