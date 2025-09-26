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
  static const Color _backgroundColor = Color(0xFFF2F2F7);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _primaryColor = Color(0xFF0A84FF);
  static const Color _iconBackgroundColor = Color(0xFFE5E5EA);
  static const Color _labelColor = Color(0xFF1C1C1E);
  static const Color _secondaryTextColor = Color(0xFF8E8E93);
  static const Color _dividerColor = Color(0xFFE5E5EA);

  UserProfile? _profile;
  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  String? _error;
  Uint8List? _localProfileImageBytes;

  static const List<String> _mbtiOptions = [
    'ISTJ', 'ISFJ', 'INFJ', 'INTJ',
    'ISTP', 'ISFP', 'INFP', 'INTP',
    'ESTP', 'ESFP', 'ENFP', 'ENTP',
    'ESTJ', 'ESFJ', 'ENFJ', 'ENTJ',
  ];

  bool _editingSelfIntroduction = false;
  bool _savingSelfIntroduction = false;
  bool _editingIdealType = false;
  bool _savingIdealType = false;
  bool _editingFaithConfession = false;
  bool _savingFaithConfession = false;
  bool _editingMbit = false;
  bool _savingMbit = false;
  String? _mbitEditingValue;

  late TextEditingController _introductionController;
  late TextEditingController _idealTypeController;
  late TextEditingController _mbitController;
  late TextEditingController _faithConfessionController;

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
    _faithConfessionController = TextEditingController();
    _mbitEditingValue = null;
    _loadProfile();
  }

  @override
  void dispose() {
    _introductionController.dispose();
    _idealTypeController.dispose();
    _mbitController.dispose();
    _faithConfessionController.dispose();
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
        _localProfileImageBytes = null;
        _resetEditingStates();
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
    final normalizedMbit = _normalizeMbit(profile?.mbit);
    _mbitController.text = normalizedMbit ?? profile?.mbit ?? '';
    _faithConfessionController.text = profile?.faithConfession ?? '';
  }

  void _syncControllersAfterUpdate(UserProfile profile) {
    if (!_editingSelfIntroduction) {
      _introductionController.text = profile.selfIntroduction ?? '';
    }
    if (!_editingIdealType) {
      _idealTypeController.text = profile.idealType ?? '';
    }
    if (!_editingFaithConfession) {
      _faithConfessionController.text = profile.faithConfession ?? '';
    }
    if (!_editingMbit) {
      final normalizedMbit = _normalizeMbit(profile.mbit);
      _mbitController.text = normalizedMbit ?? profile.mbit ?? '';
    }
  }

  void _resetEditingStates() {
    _editingSelfIntroduction = false;
    _savingSelfIntroduction = false;
    _editingIdealType = false;
    _savingIdealType = false;
    _editingFaithConfession = false;
    _savingFaithConfession = false;
    _editingMbit = false;
    _savingMbit = false;
    _mbitEditingValue = null;
  }

  void _startEditingSelfIntroduction() {
    setState(() {
      _editingSelfIntroduction = true;
      _introductionController.text = _profile?.selfIntroduction ?? '';
    });
  }

  void _cancelEditingSelfIntroduction() {
    setState(() {
      _editingSelfIntroduction = false;
      _introductionController.text = _profile?.selfIntroduction ?? '';
    });
  }

  Future<void> _saveSelfIntroduction() async {
    if (_savingSelfIntroduction) return;
    setState(() {
      _savingSelfIntroduction = true;
    });

    try {
      final updated = await ProfileService.updateSelfIntroduction(
        _introductionController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _profile = updated;
        _localProfileImageBytes = null;
        _editingSelfIntroduction = false;
      });
      _syncControllersAfterUpdate(updated);
      _showSnackBar('자기소개가 업데이트되었습니다!');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('자기소개 업데이트에 실패했습니다: $error', isError: true);
    } finally {
      if (!mounted) return;
      setState(() {
        _savingSelfIntroduction = false;
      });
    }
  }

  void _startEditingIdealType() {
    setState(() {
      _editingIdealType = true;
      _idealTypeController.text = _profile?.idealType ?? '';
    });
  }

  void _cancelEditingIdealType() {
    setState(() {
      _editingIdealType = false;
      _idealTypeController.text = _profile?.idealType ?? '';
    });
  }

  Future<void> _saveIdealType() async {
    if (_savingIdealType) return;
    setState(() {
      _savingIdealType = true;
    });

    try {
      final updated = await ProfileService.updateIdealType(
        _idealTypeController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _profile = updated;
        _localProfileImageBytes = null;
        _editingIdealType = false;
      });
      _syncControllersAfterUpdate(updated);
      _showSnackBar('이상형이 업데이트되었습니다!');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('이상형 업데이트에 실패했습니다: $error', isError: true);
    } finally {
      if (!mounted) return;
      setState(() {
        _savingIdealType = false;
      });
    }
  }

  void _startEditingFaithConfession() {
    setState(() {
      _editingFaithConfession = true;
      _faithConfessionController.text = _profile?.faithConfession ?? '';
    });
  }

  void _cancelEditingFaithConfession() {
    setState(() {
      _editingFaithConfession = false;
      _faithConfessionController.text = _profile?.faithConfession ?? '';
    });
  }

  Future<void> _saveFaithConfession() async {
    if (_savingFaithConfession) return;
    setState(() {
      _savingFaithConfession = true;
    });

    try {
      final updated = await ProfileService.updateFaithConfession(
        _faithConfessionController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _profile = updated;
        _localProfileImageBytes = null;
        _editingFaithConfession = false;
      });
      _syncControllersAfterUpdate(updated);
      _showSnackBar('신앙 고백이 업데이트되었습니다!');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('신앙 고백 업데이트에 실패했습니다: $error', isError: true);
    } finally {
      if (!mounted) return;
      setState(() {
        _savingFaithConfession = false;
      });
    }
  }

  void _startEditingMbit() {
    setState(() {
      _editingMbit = true;
      _mbitEditingValue = _normalizeMbit(_profile?.mbit);
    });
  }

  void _cancelEditingMbit() {
    setState(() {
      _editingMbit = false;
      _mbitEditingValue = _normalizeMbit(_profile?.mbit);
      _mbitController.text = _profile?.mbit ?? '';
    });
  }

  Future<void> _saveMbit() async {
    if (_savingMbit) return;
    final selected = _mbitEditingValue;
    if (selected == null || selected.isEmpty) {
      _showSnackBar('MBTI를 선택해주세요.', isError: true);
      return;
    }
    setState(() {
      _savingMbit = true;
    });

    try {
      final updated = await ProfileService.updateMbit(selected);

      if (!mounted) return;

      setState(() {
        _profile = updated;
        _localProfileImageBytes = null;
        _editingMbit = false;
        _mbitEditingValue = null;
      });
      _syncControllersAfterUpdate(updated);
      _showSnackBar('MBTI가 업데이트되었습니다!');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('MBTI 업데이트에 실패했습니다: $error', isError: true);
    } finally {
      if (!mounted) return;
      setState(() {
        _savingMbit = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    if (_isUploadingPhoto || _isLoading) {
      return;
    }

    final user = AuthService.currentUser;
    if (user == null) {
      _showSnackBar('로그인 정보가 없어 프로필 사진을 변경할 수 없습니다.', isError: true);
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

      _syncControllersAfterUpdate(profile);

      _showSnackBar('프로필 사진이 업데이트되었습니다!');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('프로필 사진을 변경하지 못했습니다: $error', isError: true);
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

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : _primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    } else if (_error != null) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadProfile,
              style: FilledButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
              children: const [
                Text(
                  '프로필',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                Spacer(),
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
                  _buildNarrativeSectionGroup(),
                  const SizedBox(height: 24),
                  _buildEditableSection(
                    title: 'MBTI',
                    icon: Icons.psychology_outlined,
                    controller: _mbitController,
                    isMultiline: false,
                    isEditing: _editingMbit,
                    isSaving: _savingMbit,
                    onEdit: _startEditingMbit,
                    onCancel: _cancelEditingMbit,
                    onSave: _saveMbit,
                    editingChild: _buildMbitEditor(),
                    viewChild: _buildMbitView(),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(child: content),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
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
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _labelColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AuthService.currentUser?.kakaoId ?? '로그인 정보를 확인할 수 없어요',
                  style: const TextStyle(
                    fontSize: 15,
                    color: _secondaryTextColor,
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
      avatarContent = Image.memory(_localProfileImageBytes!, fit: BoxFit.cover);
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
              color: _iconBackgroundColor,
            ),
          ),
          ClipRRect(
            borderRadius: borderRadius,
            child: SizedBox(width: 80, height: 80, child: avatarContent),
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
                color: _isUploadingPhoto ? Colors.grey : _primaryColor,
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
      child: Icon(Icons.person, color: _secondaryTextColor, size: 32),
    );
  }

  String? _normalizeMbit(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toUpperCase();
    return _mbtiOptions.contains(normalized) ? normalized : null;
  }

  Widget _buildMbitEditor() {
    final selected = _mbitEditingValue;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _mbtiOptions
          .map(
            (value) => ChoiceChip(
              label: Text(value),
              selected: value == selected,
              onSelected:
                  _savingMbit
                      ? null
                      : (isSelected) {
                          if (!isSelected) return;
                          setState(() {
                            _mbitEditingValue = value;
                            _mbitController.text = value;
                          });
                        },
              selectedColor: _primaryColor,
              backgroundColor: _iconBackgroundColor,
              labelStyle: TextStyle(
                color: value == selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildMbitView() {
    final normalized = _normalizeMbit(_profile?.mbit ?? _mbitController.text);
    if (normalized == null) {
      return const Text(
        '등록된 정보가 없습니다.',
        style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w400),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(
          normalized,
          style: const TextStyle(
            color: Color(0xFF0F4C75),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: _primaryColor.withOpacity(0.18),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }

  Widget _buildEditableSection({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required bool isMultiline,
    required bool isEditing,
    required bool isSaving,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
    required Future<void> Function() onSave,
    Widget? editingChild,
    Widget? viewChild,
    bool useCard = true,
    EdgeInsetsGeometry? padding,
  }) {
    final hasContent = controller.text.trim().isNotEmpty;
    final resolvedPadding = padding ??
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16);

    Widget editor = editingChild ??
        TextField(
          controller: controller,
          maxLines: isMultiline ? 5 : 1,
          decoration: InputDecoration(
            hintText: '${title}을 입력해주세요',
            filled: true,
            fillColor: _backgroundColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        );

    final body = Padding(
      padding: resolvedPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _iconBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: _primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _labelColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    isEditing
                        ? editor
                        : (viewChild ??
                            Text(
                              hasContent
                                  ? controller.text
                                  : '등록된 정보가 없습니다.',
                              style: TextStyle(
                                fontSize: isMultiline ? 15 : 16,
                                color: hasContent
                                    ? _labelColor
                                    : _secondaryTextColor,
                                height: isMultiline ? 1.6 : 1.3,
                                fontWeight: hasContent
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            )),
                  ],
                ),
              ),
              if (!isEditing)
                IconButton(
                  onPressed: (_isLoading || isSaving) ? null : onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    color:
                        (_isLoading || isSaving) ? _secondaryTextColor : _primaryColor,
                    size: 18,
                  ),
                ),
            ],
          ),
          if (isEditing) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                TextButton(
                  onPressed: isSaving ? null : onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: _secondaryTextColor,
                  ),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          await onSave();
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('저장'),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (!useCard) {
      return body;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: body,
    );
  }

  Widget _buildNarrativeSectionGroup() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 6),
            child: Text(
              '서술형 답변',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _secondaryTextColor,
                letterSpacing: -0.2,
              ),
            ),
          ),
          _buildEditableSection(
            title: '자기소개',
            icon: Icons.person_outline,
            controller: _introductionController,
            isMultiline: true,
            isEditing: _editingSelfIntroduction,
            isSaving: _savingSelfIntroduction,
            onEdit: _startEditingSelfIntroduction,
            onCancel: _cancelEditingSelfIntroduction,
            onSave: _saveSelfIntroduction,
            useCard: false,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          _buildSectionDivider(),
          _buildEditableSection(
            title: '신앙 고백',
            icon: Icons.menu_book_outlined,
            controller: _faithConfessionController,
            isMultiline: true,
            isEditing: _editingFaithConfession,
            isSaving: _savingFaithConfession,
            onEdit: _startEditingFaithConfession,
            onCancel: _cancelEditingFaithConfession,
            onSave: _saveFaithConfession,
            useCard: false,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          _buildSectionDivider(),
          _buildEditableSection(
            title: '이상형',
            icon: Icons.favorite_outline,
            controller: _idealTypeController,
            isMultiline: true,
            isEditing: _editingIdealType,
            isSaving: _savingIdealType,
            onEdit: _startEditingIdealType,
            onCancel: _cancelEditingIdealType,
            onSave: _saveIdealType,
            useCard: false,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider() {
    return const Divider(height: 1, thickness: 1, color: _dividerColor);
  }
}
