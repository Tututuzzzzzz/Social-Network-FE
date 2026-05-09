import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/cache/secure_local_storage.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../routes/app_route_path.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/usecase_params.dart';
import '../bloc/profile/profile_bloc.dart';
import '../widgets/profile_empty_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, this.userId});

  final String? userId;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();

  ProfileEntity? _profile;
  String _targetUserId = '';
  bool _didFillForm = false;
  bool _isResolvingUser = true;
  bool _isMissingSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveAndLoadProfile();
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _resolveAndLoadProfile() async {
    if (!mounted) return;

    setState(() {
      _isResolvingUser = true;
      _isMissingSession = false;
    });

    final routeUserId = widget.userId?.trim() ?? '';
    final storageUserId = routeUserId.isEmpty
        ? (await getIt<SecureLocalStorage>().load(key: 'user_id')).trim()
        : '';
    final targetUserId = routeUserId.isNotEmpty ? routeUserId : storageUserId;

    if (!mounted) return;

    if (targetUserId.isEmpty) {
      setState(() {
        _isResolvingUser = false;
        _isMissingSession = true;
      });
      return;
    }

    setState(() {
      _targetUserId = targetUserId;
      _isResolvingUser = false;
    });

    context.read<ProfileBloc>().add(
      ProfileGetEvent(ProfileParams(userId: targetUserId)),
    );
  }

  void _fillForm(ProfileEntity profile) {
    if (_didFillForm) {
      return;
    }

    _profile = profile;
    _displayNameController.text = profile.displayName?.trim() ?? '';
    _bioController.text = profile.bio?.trim() ?? '';
    _phoneController.text = profile.phone?.trim() ?? '';
    _didFillForm = true;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profile = _profile;
    final displayName = _displayNameController.text.trim();
    final bio = _bioController.text.trim();
    final phone = _phoneController.text.trim();

    final initialDisplayName = profile?.displayName?.trim() ?? '';
    final initialBio = profile?.bio?.trim() ?? '';
    final initialPhone = profile?.phone?.trim();

    final nextDisplayName = displayName == initialDisplayName
        ? null
        : displayName;
    final nextBio = bio == initialBio ? null : bio;
    String? nextPhone;
    if (initialPhone != null) {
      nextPhone = phone == initialPhone ? null : phone;
    } else if (phone.isNotEmpty) {
      nextPhone = phone;
    }

    if (nextDisplayName == null && nextBio == null && nextPhone == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.profileNoChanges)));
      return;
    }

    context.read<ProfileBloc>().add(
      ProfileUpdateEvent(
        UpdateProfileParams(
          displayName: nextDisplayName,
          bio: nextBio,
          phone: nextPhone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoadedState) {
          setState(() => _fillForm(state.profile));
          return;
        }

        if (state is ProfileActionSuccessState) {
          context.pop(true);
          return;
        }

        if (state is ProfileActionFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message.isEmpty
                    ? context.l10n.profileUpdateFailed
                    : state.message,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is ProfileActionLoadingState;

        return Scaffold(
          backgroundColor: const Color(0xFFF3F7F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFF31B991),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              context.l10n.editProfileTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
          ),
          body: _buildBody(state, isSubmitting),
        );
      },
    );
  }

  Widget _buildBody(ProfileState state, bool isSubmitting) {
    if (_isResolvingUser ||
        (!_didFillForm &&
            (state is ProfileInitialState || state is ProfileLoadingState))) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.6),
        ),
      );
    }

    if (_isMissingSession) {
      return ProfileEmptyState(
        icon: Icons.lock_outline_rounded,
        title: context.l10n.sessionExpiredRelogin,
        message: context.l10n.login,
      );
    }

    if (state is ProfileFailureState && !_didFillForm) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfileEmptyState(
                icon: Icons.error_outline_rounded,
                title: context.l10n.profileLoadFailed,
                message: state.message,
              ),
              const SizedBox(height: 18),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF25A97A),
                  foregroundColor: Colors.white,
                ),
                onPressed: _targetUserId.isEmpty
                    ? _resolveAndLoadProfile
                    : () => context.read<ProfileBloc>().add(
                        ProfileGetEvent(ProfileParams(userId: _targetUserId)),
                      ),
                child: Text(context.l10n.retryAction),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              _EditProfileField(
                controller: _displayNameController,
                label: context.l10n.displayNameLabel,
                icon: Icons.badge_outlined,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return context.l10n.pleaseEnterDisplayName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _EditProfileField(
                controller: _bioController,
                label: context.l10n.bioLabel,
                icon: Icons.notes_rounded,
                minLines: 3,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 14),
              _EditProfileField(
                controller: _phoneController,
                label: context.l10n.phoneLabel,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => isSubmitting ? null : _submit(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF25A97A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFD7E0DC),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  context.l10n.confirmAction,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        if (context.canPop()) {
                          context.pop(false);
                          return;
                        }
                        context.go(AppRoutes.profile.path);
                      },
                child: Text(context.l10n.cancel),
              ),
            ],
          ),
        ),
        if (isSubmitting)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.12),
              child: const Center(
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EditProfileField extends StatelessWidget {
  const _EditProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE3E8E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF25A97A), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.4),
        ),
      ),
    );
  }
}
