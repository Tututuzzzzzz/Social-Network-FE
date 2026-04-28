import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../routes/app_route_path.dart';
import '../../../../widgets/app_shell_bottom_nav_bar.dart';
import '../../data/models/upload_media_response_model.dart';
import '../../domain/entities/post_media_entity.dart';
import '../../domain/usecases/usecase_params.dart';
import '../bloc/post/post_bloc.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final PageController _pageController = PageController();

  List<XFile> _selectedImages = const [];
  int _currentImageIndex = 0;
  int _currentNavIndex = 0;
  bool _isPickingImages = false;
  bool _isSubmitting = false;

  bool get _canSubmit {
    return _captionController.text.trim().isNotEmpty ||
        _selectedImages.isNotEmpty;
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
        _selectedImages = images;
        _currentImageIndex = 0;
      });
      _pageController.jumpToPage(0);
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
        _currentImageIndex = _selectedImages.length - 1;
      });
      _pageController.jumpToPage(_currentImageIndex);
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

  void _removeImageAt(int index) {
    if (index < 0 || index >= _selectedImages.length) {
      return;
    }

    final nextImages = List<XFile>.from(_selectedImages)..removeAt(index);

    setState(() {
      _selectedImages = nextImages;
      if (_selectedImages.isEmpty) {
        _currentImageIndex = 0;
      } else if (_currentImageIndex >= _selectedImages.length) {
        _currentImageIndex = _selectedImages.length - 1;
      }
    });

    if (_selectedImages.isNotEmpty) {
      _pageController.jumpToPage(_currentImageIndex);
    }
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

  Future<List<PostMediaEntity>> _uploadSelectedImages() async {
    if (_selectedImages.isEmpty) {
      return const [];
    }

    final dio = getIt<Dio>();
    final multipartFiles = <MultipartFile>[];

    for (final image in _selectedImages) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        multipartFiles.add(
          MultipartFile.fromBytes(
            bytes,
            filename: image.name,
            contentType: DioMediaType.parse('image/jpeg'),
          ),
        );
      } else {
        multipartFiles.add(
          await MultipartFile.fromFile(image.path, filename: image.name),
        );
      }
    }

    final formData = FormData.fromMap({
      'purpose': 'post',
      'files': multipartFiles,
    });

    final response = await dio.post(
      '/media/upload',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Upload media failed');
    }

    final payload = response.data;
    if (payload is! Map) {
      throw Exception('Invalid media payload');
    }

    final uploadResponse = UploadMediaResponseModel.fromJson(
      Map<String, dynamic>.from(payload),
    );

    return uploadResponse
        .toEntities()
        .where((item) => item.bucket.isNotEmpty && item.objectKey.isNotEmpty)
        .toList();
  }

  void _onBottomNavTap(int index) {
    if (index == _currentNavIndex) return;

    setState(() => _currentNavIndex = index);

    switch (index) {
      case 0:
        context.go(AppRoutes.home.path);
        break;
      case 1:
        context.go(AppRoutes.homeSearch.path);
        break;
      case 2:
        context.go(AppRoutes.chat.path);
        break;
      case 3:
        context.go(AppRoutes.profile.path);
        break;
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasImages = _selectedImages.isNotEmpty;

    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (!_isSubmitting) return;

        if (state is PostActionFailureState) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is PostLoadedState) {
          setState(() => _isSubmitting = false);
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            l10n.createPostTitle,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: (_isSubmitting || !_canSubmit) ? null : _submitPost,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      l10n.postAction,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMediaSection(hasImages),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _captionController,
                      minLines: 5,
                      maxLines: 10,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: l10n.captionHint,
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isPickingImages ? null : _pickFromGallery,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(l10n.libraryLabel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isPickingImages ? null : _pickFromCamera,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(l10n.cameraLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppShellBottomNavBar(
          selectedIndex: _currentNavIndex,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }

  Widget _buildMediaSection(bool hasImages) {
    if (!hasImages) {
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 220),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E7E7)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.collections_outlined,
              size: 46,
              color: Colors.black38,
            ),
            const SizedBox(height: 10),
            Text(
              context.l10n.addMediaForPost,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _isPickingImages ? null : _pickFromGallery,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(context.l10n.pickFromLibrary),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _selectedImages.length,
                  onPageChanged: (index) {
                    setState(() => _currentImageIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final image = _selectedImages[index];
                    if (kIsWeb) {
                      return Image.network(image.path, fit: BoxFit.cover);
                    }
                    return Image.file(File(image.path), fit: BoxFit.cover);
                  },
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () => _removeImageAt(_currentImageIndex),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                if (_selectedImages.length > 1)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_selectedImages.length, (index) {
                        final isActive = index == _currentImageIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: isActive ? 16 : 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + 1,
            separatorBuilder: (_, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return InkWell(
                  onTap: _isPickingImages ? null : _pickFromGallery,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E5E5)),
                    ),
                    child: const Icon(Icons.add, color: Colors.black54),
                  ),
                );
              }

              final image = _selectedImages[index];
              return GestureDetector(
                onTap: () {
                  setState(() => _currentImageIndex = index);
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                  );
                },
                child: Container(
                  width: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _currentImageIndex == index
                          ? Colors.black
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: kIsWeb
                        ? Image.network(image.path, fit: BoxFit.cover)
                        : Image.file(File(image.path), fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
