import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _error;
  Uint8List? _localProfileImageBytes;

  late TextEditingController _introductionController;
  late TextEditingController _idealTypeController;
  late TextEditingController _mbitController;

  String? get _profileImageUrl {
    final path = _profile?.profileImagePath;
    if (path == null || path.isEmpty) {
      return null;
    }
    return AuthService.resolveAssetUrl(path);
  }

  @override
  void initState() {
    super.initState();
    _introductionController = TextEditingController();
    _idealTypeController = TextEditingController();
    _mbitController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _introductionController.dispose();
    _idealTypeController.dispose();
    _mbitController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = AuthService.currentUser;
    if (user == null) {
      setState(() {
        _error = '로그인 정보가 없습니다.';
        _profile = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final fetched = await ProfileService.fetchProfile();
      if (!mounted) return;

      final nextProfile = fetched ?? UserProfile(userId: user.id);
      setState(() {
        _profile = nextProfile;
        _isEditing = false;
        _localProfileImageBytes = null;
      });
      _applyProfileToControllers(nextProfile);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '프로필을 불러오는 데 실패했습니다. 다시 시도해주세요.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyProfileToControllers(UserProfile? profile) {
    _introductionController.text = profile?.selfIntroduction ?? '';
    _idealTypeController.text = profile?.idealType ?? '';
    _mbitController.text = profile?.mbit ?? '';
  }

  void _toggleEditMode() {
    if (_isLoading || _isSaving) {
      return;
    }

    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _applyProfileToControllers(_profile);
      }
    });
  }

  Future<void> _saveChanges() async {
    final user = AuthService.currentUser;
    if (user == null || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final profile = await ProfileService.upsertProfile(
        selfIntroduction: _introductionController.text.trim(),
        mbit: _mbitController.text.trim(),
        idealType: _idealTypeController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isEditing = false;
        _localProfileImageBytes = null;
      });
      _applyProfileToControllers(profile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필이 저장되었습니다!'),
          backgroundColor: Color(0xFF87CEEB),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 저장에 실패했습니다: $error')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    if (_isUploadingPhoto || _isLoading) {
      return;
    }

    final user = AuthService.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 정보가 없어 프로필 사진을 변경할 수 없습니다.')),
        );
      }
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 85,
      );

      if (picked == null) {
        return;
      }

      final bytes = await picked.readAsBytes();
      if (!mounted) return;

      setState(() {
        _isUploadingPhoto = true;
        _localProfileImageBytes = bytes;
      });

      final profile = await ProfileService.uploadProfilePhoto(
        bytes: bytes,
        fileName: picked.name,
        mimeType: _inferMimeType(picked.name),
      );

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _localProfileImageBytes = null;
      });

      if (!_isEditing) {
        _applyProfileToControllers(profile);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필 사진이 업데이트되었습니다!'),
          backgroundColor: Color(0xFF87CEEB),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 사진을 변경하지 못했습니다: $error')),
      );
      setState(() {
        _localProfileImageBytes = null;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isUploadingPhoto = false;
      });
    }
  }

  String? _inferMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(color: Color(0xFF87CEEB)),
      );
    } else if (_error != null) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87CEEB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    } else {
      content = Column(
        children: [
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
                if (_isEditing)
                  Row(
                    children: [
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
                        onPressed: _isSaving ? null : _saveChanges,
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
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                '저장',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  )
                else
                  IconButton(
                    onPressed: _profile == null ? null : _toggleEditMode,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF87CEEB),
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 32),
                  _buildEditableSection(
                    title: '자기소개',
                    icon: Icons.person_outline,
                    controller: _introductionController,
                    isMultiline: true,
                  ),
                  const SizedBox(height: 24),
                  _buildEditableSection(
                    title: 'MBTI',
                    icon: Icons.psychology_outlined,
                    controller: _mbitController,
                    isMultiline: false,
                  ),
                  const SizedBox(height: 24),
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
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: content),
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
          _buildProfileImageAvatar(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '내 프로필',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AuthService.currentUser?.kakaoId ?? '로그인 정보를 확인할 수 없어요',
                  style: const TextStyle(
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

  Widget _buildProfileImageAvatar() {
    final borderRadius = BorderRadius.circular(40);
    Widget avatarContent;

    if (_localProfileImageBytes != null) {
      avatarContent = Image.memory(
        _localProfileImageBytes!,
        fit: BoxFit.cover,
      );
    } else {
      final imageUrl = _profileImageUrl;
      if (imageUrl != null) {
        avatarContent = Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
        );
      } else {
        avatarContent = _buildAvatarPlaceholder();
      }
    }

    return GestureDetector(
      onTap: _isUploadingPhoto ? null : _pickProfileImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: const Color(0xFF87CEEB).withOpacity(0.2),
            ),
          ),
          ClipRRect(
            borderRadius: borderRadius,
            child: SizedBox(
              width: 80,
              height: 80,
              child: avatarContent,
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                size: 16,
                color: _isUploadingPhoto
                    ? Colors.grey
                    : const Color(0xFF87CEEB),
              ),
            ),
          ),
          if (_isUploadingPhoto)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: Colors.black.withOpacity(0.35),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return const Center(
      child: Icon(
        Icons.person,
        color: Color(0xFF87CEEB),
        size: 40,
      ),
    );
  }

  Widget _buildEditableSection({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required bool isMultiline,
  }) {
    final hasContent = controller.text.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEditing
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
              hasContent ? controller.text : '등록된 정보가 없습니다.',
              style: TextStyle(
                fontSize: isMultiline ? 15 : 18,
                color: hasContent ? Colors.black87 : Colors.grey,
                height: isMultiline ? 1.6 : 1.2,
                fontWeight:
                    hasContent ? (isMultiline ? FontWeight.w400 : FontWeight.w600) : FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
