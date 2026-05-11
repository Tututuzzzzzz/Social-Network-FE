import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../configs/injector/injector_conf.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/theme/app_colors.dart';
import '../../../../core/utils/failure_converter.dart';
import '../../../../routes/app_route_path.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../../profile/domain/usecases/usecase_params.dart';
import '../../../profile/presentation/bloc/profile/profile_bloc.dart';
import '../../domain/entities/post_media_entity.dart';
import '../../domain/entities/post_media_upload_file.dart';
import '../../domain/usecases/usecase_params.dart';
import '../../domain/usecases/upload_post_media_usecase.dart';
import '../bloc/post/post_bloc.dart';
import '../widgets/create_post_screen/create_post_bottom_tools.dart';
import '../widgets/create_post_screen/create_post_composer_body.dart';
import '../widgets/create_post_screen/create_post_header.dart';
import '../widgets/create_post_screen/create_post_image_options_sheet.dart';
import '../widgets/create_post_screen/create_post_identity_resolver.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final CreatePostIdentityResolver _identityResolver =
      const CreatePostIdentityResolver();
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<XFile> _selectedImages = const [];
  ProfileEntity? _currentProfile;
  String _cachedDisplayName = '';
  String _cachedAvatarUrl = '';
  bool _isPickingImages = false;
  bool _isSubmitting = false;

  bool get _canSubmit {
    return _captionController.text.trim().isNotEmpty ||
        _selectedImages.isNotEmpty;
  }

  String get _displayName {
    final profileName = _currentProfile?.displayName?.trim() ?? '';
    if (profileName.isNotEmpty) {
      return profileName;
    }

    final profileUsername = _currentProfile?.username?.trim() ?? '';
    if (profileUsername.isNotEmpty) {
      return profileUsername;
    }

    if (_cachedDisplayName.trim().isNotEmpty) {
      return _cachedDisplayName.trim();
    }

    return '';
  }

  String get _avatarUrl {
    final profileAvatar = _currentProfile?.avatarUrl?.trim() ?? '';
    if (profileAvatar.isNotEmpty) {
      return profileAvatar;
    }

    return _cachedAvatarUrl.trim();
  }

  @override
  void initState() {
    super.initState();
    _primeIdentityFromAuthState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUserProfile();
    });
  }

  void _primeIdentityFromAuthState() {
    final identity = _identityResolver.fromAuthState(
      context.read<AuthBloc>().state,
    );
    _applyIdentity(identity);
  }

  Future<void> _loadCurrentUserProfile() async {
    final identity = await _identityResolver.loadInitialIdentity();
    if (!mounted) {
      return;
    }

    if (identity.hasDisplayData) {
      setState(() => _applyIdentity(identity));
    }

    if (identity.userId.isEmpty) {
      return;
    }

    context.read<ProfileBloc>().add(
      ProfileGetEvent(ProfileParams(userId: identity.userId)),
    );
  }

  void _applyIdentity(CreatePostIdentitySnapshot identity) {
    if (identity.profile != null) {
      _currentProfile = identity.profile;
    }
    if (identity.displayName.trim().isNotEmpty) {
      _cachedDisplayName = identity.displayName.trim();
    }
    if (identity.avatarUrl.trim().isNotEmpty) {
      _cachedAvatarUrl = identity.avatarUrl.trim();
    }
  }

  Future<void> _pickFromGallery() async {
    final l10n = context.l10n;
    if (_isPickingImages) return;

    setState(() => _isPickingImages = true);
    try {
      final images = await _picker.pickMultiImage(
        imageQuality: 90,
        maxWidth: 1920,
      );

      if (images.isEmpty || !mounted) {
        return;
      }

      setState(() {
        _selectedImages = _selectedImages.isEmpty
            ? images
            : <XFile>[..._selectedImages, ...images];
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.createPostCannotPickGallery)));
    } finally {
      if (mounted) {
        setState(() => _isPickingImages = false);
      }
    }
  }

  Future<void> _pickFromCamera() async {
    final l10n = context.l10n;
    if (_isPickingImages) return;

    setState(() => _isPickingImages = true);
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1920,
      );

      if (image == null || !mounted) {
        return;
      }

      setState(() {
        _selectedImages = <XFile>[..._selectedImages, image];
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.createPostCannotOpenCamera)));
    } finally {
      if (mounted) {
        setState(() => _isPickingImages = false);
      }
    }
  }

  Future<void> _replaceImageAt(int index) async {
    final l10n = context.l10n;
    if (_isPickingImages || index < 0 || index >= _selectedImages.length) {
      return;
    }

    setState(() => _isPickingImages = true);
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1920,
      );

      if (image == null || !mounted) {
        return;
      }

      setState(() {
        _selectedImages = List<XFile>.from(_selectedImages)..[index] = image;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.createPostCannotPickGallery)));
    } finally {
      if (mounted) {
        setState(() => _isPickingImages = false);
      }
    }
  }

  void _removeImageAt(int index) {
    if (index < 0 || index >= _selectedImages.length) {
      return;
    }

    setState(() {
      _selectedImages = List<XFile>.from(_selectedImages)..removeAt(index);
    });
  }

  Future<void> _showImageOptions(int index) async {
    if (index < 0 || index >= _selectedImages.length) {
      return;
    }

    final action = await showCreatePostImageOptionsSheet(context);
    if (!mounted || action == null) {
      return;
    }

    if (action == CreatePostImageEditAction.replace) {
      await _replaceImageAt(index);
      return;
    }

    _removeImageAt(index);
  }

  void _showTemplateSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.templateSoon)));
  }

  Future<void> _submitPost() async {
    if (_isSubmitting || !_canSubmit) {
      return;
    }

    final content = _captionController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      final uploadedMedia = await _uploadSelectedImages();

      if (!mounted) return;

      if (uploadedMedia == null) {
        setState(() => _isSubmitting = false);
        return;
      }

      context.read<PostBloc>().add(
        PostCreateEvent(
          CreatePostParams(
            content: content.isEmpty ? null : content,
            media: uploadedMedia,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.createPostCannotPickGallery)),
      );
    }
  }

  Future<List<PostMediaEntity>?> _uploadSelectedImages() async {
    if (_selectedImages.isEmpty) {
      return const [];
    }

    final files = <PostMediaUploadFile>[];

    for (final image in _selectedImages) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        files.add(PostMediaUploadFile(name: image.name, bytes: bytes));
      } else {
        files.add(PostMediaUploadFile(name: image.name, path: image.path));
      }
    }

    final useCase = getIt<UploadPostMediaUseCase>();
    final result = await useCase.call(UploadPostMediaParams(files: files));

    if (!mounted) return null;

    return result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mapFailureToMessage(failure))));
        return null;
      },
      (media) => media,
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = _selectedImages.isNotEmpty;
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final hasTypedContent = _captionController.text.trim().isNotEmpty;
    final showBottomTools = hasImages || keyboardVisible || hasTypedContent;

    return MultiBlocListener(
      listeners: [
        BlocListener<PostBloc, PostState>(
          listener: (context, state) {
            if (!_isSubmitting) return;

            if (state is PostActionFailureState) {
              setState(() => _isSubmitting = false);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is PostLoadedState) {
              setState(() => _isSubmitting = false);
              context.go(AppRoutes.home.path);
            }
          },
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoadedState && mounted) {
              setState(() => _currentProfile = state.profile);
            }
          },
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: AppColors.of(context).scaffold,
                systemNavigationBarColor: AppColors.of(context).scaffold,
                systemNavigationBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: AppColors.of(context).scaffold,
                systemNavigationBarColor: AppColors.of(context).scaffold,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
        child: Scaffold(
          backgroundColor: AppColors.of(context).scaffold,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                CreatePostHeader(
                  displayName: _displayName,
                  avatarUrl: _avatarUrl,
                  isSubmitting: _isSubmitting,
                  canSubmit: _canSubmit,
                  onClose: () => context.go(AppRoutes.home.path),
                  onSubmit: _submitPost,
                ),
                Expanded(
                  child: CreatePostComposerBody(
                    captionController: _captionController,
                    selectedImages: _selectedImages,
                    showEmptyActions: !showBottomTools,
                    isPickingImages: _isPickingImages,
                    onCaptionChanged: (_) => setState(() {}),
                    onPickFromGallery: _pickFromGallery,
                    onPickFromCamera: _pickFromCamera,
                    onTemplate: _showTemplateSoon,
                    onEditImage: _showImageOptions,
                  ),
                ),
                if (showBottomTools)
                  CreatePostBottomTools(
                    isPickingImages: _isPickingImages,
                    onPickFromGallery: _pickFromGallery,
                    onPickFromCamera: _pickFromCamera,
                    onTemplate: _showTemplateSoon,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
