import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/cache/hive_local_storage.dart';
import '../../../../core/cache/secure_local_storage.dart';
import '../../../../core/utils/url_normalizer.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_avatar_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/usecase_params.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();

  final _imagePicker = ImagePicker();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPrivate = false;

  String _currentUserId = '';
  String _username = '';
  String _email = '';
  String _gender = 'Nam';
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() => _isLoading = true);

    final userId = await _resolveCurrentUserId();
    if (!mounted) return;

    if (userId.isEmpty) {
      setState(() => _isLoading = false);
      _showSnack('Không tìm thấy user_id đăng nhập');
      return;
    }

    _currentUserId = userId;
    await _loadCachedUserMeta();
    await _loadProfile();

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _loadCachedUserMeta() async {
    final localStorage = getIt<HiveLocalStorage>();
    final cachedUser = await localStorage.load(key: 'user', boxName: 'cache');

    if (cachedUser is Map) {
      final map = cachedUser.map((key, value) => MapEntry('$key', value));
      _username = (map['username'] ?? '').toString();
      _email = (map['email'] ?? '').toString();
      _phoneController.text = (map['phone'] ?? '').toString();
      final cachedGender = (map['gender'] ?? '').toString();
      if (cachedGender.trim().isNotEmpty) {
        _gender = cachedGender;
      }
    }
  }

  Future<void> _loadProfile() async {
    final useCase = getIt<GetProfileUseCase>();
    final result = await useCase.call(ProfileParams(userId: _currentUserId));

    if (!mounted) return;

    result.fold(
      (_) => _showSnack('Không tải được thông tin profile'),
      (profile) => _applyProfile(profile),
    );
  }

  void _applyProfile(ProfileEntity profile) {
    _displayNameController.text = profile.displayName ?? '';
    _bioController.text = profile.bio ?? '';
    _avatarUrl = _normalizeMediaUrl((profile.avatarUrl ?? '').trim());
    if ((profile.username ?? '').trim().isNotEmpty) {
      _username = profile.username!.trim();
    }
    setState(() {});
  }

  Future<void> _pickAndUploadAvatar() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (bytes.isEmpty) {
      _showSnack('Không đọc được ảnh');
      return;
    }

    setState(() => _isSaving = true);

    final useCase = getIt<UpdateAvatarUseCase>();
    final result = await useCase.call(
      UpdateAvatarParams(avatarBytes: bytes, fileName: image.name),
    );

    if (!mounted) return;

    result.fold((_) => _showSnack('Không thể cập nhật ảnh đại diện'), (
      _,
    ) async {
      _showSnack('Đã cập nhật ảnh đại diện');
      await _loadProfile();
    });

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final useCase = getIt<UpdateProfileUseCase>();
    final result = await useCase.call(
      UpdateProfileParams(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        phone: _phoneController.text.trim(),
      ),
    );

    if (!mounted) return;

    result.fold(
      (_) {
        _showSnack('Không thể cập nhật thông tin');
        setState(() => _isSaving = false);
      },
      (_) async {
        _showSnack('Cập nhật thông tin thành công');
        setState(() => _isSaving = false);
        Navigator.of(context).pop(true);
      },
    );
  }

  Future<String> _resolveCurrentUserId() async {
    final secureStorage = getIt<SecureLocalStorage>();
    final storedUserId = await secureStorage.load(key: 'user_id');
    final secureUserId = storedUserId.trim();
    if (secureUserId.isNotEmpty) {
      return secureUserId;
    }

    final localStorage = getIt<HiveLocalStorage>();
    final cachedUser = await localStorage.load(key: 'user', boxName: 'cache');
    if (cachedUser is Map) {
      final map = cachedUser.map((key, value) => MapEntry('$key', value));
      final userId = (map['_id'] ?? map['id'] ?? '').toString().trim();
      if (userId.isNotEmpty) {
        await secureStorage.save(key: 'user_id', value: userId);
        return userId;
      }
    }

    final accessToken = await secureStorage.load(key: 'access_token');
    final tokenUserId = _extractUserIdFromAccessToken(accessToken);
    if ((tokenUserId ?? '').isNotEmpty) {
      await secureStorage.save(key: 'user_id', value: tokenUserId!);
      return tokenUserId;
    }

    return '';
  }

  String? _extractUserIdFromAccessToken(String? accessToken) {
    final token = (accessToken ?? '').trim();
    if (token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;

      final payloadBase64 = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(payloadBase64));
      final decoded = jsonDecode(payload);

      if (decoded is! Map<String, dynamic>) return null;

      final value = decoded['userId'] ?? decoded['sub'] ?? decoded['_id'];
      final userId = (value ?? '').toString().trim();
      return userId.isEmpty ? null : userId;
    } catch (_) {
      return null;
    }
  }

  String _normalizeMediaUrl(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return '';

    final apiUri = Uri.parse(ApiConstants.baseUrl);
    var normalized = raw;

    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      final origin =
          '${apiUri.scheme}://${apiUri.host}${apiUri.hasPort ? ':${apiUri.port}' : ''}';
      normalized = raw.startsWith('/') ? '$origin$raw' : '$origin/$raw';
    }

    return normalizeClientNetworkUrl(normalized);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F3F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Chỉnh sửa trang cá nhân',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            style: TextButton.styleFrom(
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'Xong',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 36),
            children: [
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _avatarUrl.isNotEmpty
                          ? NetworkImage(_avatarUrl)
                          : null,
                      child: _avatarUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 52,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _isSaving ? null : _pickAndUploadAvatar,
                      child: const Text(
                        'Chỉnh sửa ảnh hoặc avatar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              _ProfileInputTile(
                label: 'Tên',
                controller: _displayNameController,
              ),
              _ProfileReadOnlyTile(label: 'Tên người dùng', value: _username),
              const _ProfileReadOnlyTile(
                label: 'Liên kết',
                value: 'Thêm liên kết',
              ),
              _ProfileInputTile(label: 'Tiểu sử', controller: _bioController),
              const SizedBox(height: 8),
              const Divider(height: 1),
              SwitchListTile.adaptive(
                value: _isPrivate,
                onChanged: _isSaving
                    ? null
                    : (v) => setState(() => _isPrivate = v),
                title: const Text(
                  'Tài khoản riêng tư',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                ),
              ),
              const _SectionTitle('Thông tin cá nhân'),
              _ProfileReadOnlyTile(label: 'Email', value: _email),
              _ProfileInputTile(
                label: 'Điện thoại',
                controller: _phoneController,
              ),
              _ProfileReadOnlyTile(label: 'Giới tính', value: _gender),
            ],
          ),
          if (_isSaving)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _ProfileInputTile extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _ProfileInputTile({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE6E6E8))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 95,
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: SizedBox(
              height: 35,
              child: TextField(
                controller: controller,
                style: const TextStyle(fontSize: 16),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF3F6FA),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileReadOnlyTile extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileReadOnlyTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 70,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE6E6E8))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 95,
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              style: TextStyle(
                fontSize: 16,
                color: value.trim().isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
