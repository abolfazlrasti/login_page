import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const Color darkBg = Color(0xFF090909);

  final TextEditingController _nameController =
      TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();

  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;

  bool _isButtonEnabled = false;
  bool _isSaving = false;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_validateForm);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _nameFocusNode.requestFocus();
      }
    });
  }

  void _validateForm() {
    final text = _nameController.text.trim();

    final isValid = text.length >= 2;

    if (isValid != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isValid;
      });
    }
  }

  Future<bool> _requestPhotosPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.photos.request();

      if (status.isGranted || status.isLimited) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        if (mounted) {
          _showMessage(
            'Photo access is disabled. Enable it from Settings.',
          );
        }

        await openAppSettings();
      }

      return false;
    }

    return true;
  }

  Future<void> _pickImage() async {
    if (_isPickingImage || _isSaving) {
      return;
    }

    setState(() {
      _isPickingImage = true;
    });

    try {
      final hasPermission = await _requestPhotosPermission();

      if (!hasPermission) {
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (!mounted) return;

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to select the photo. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _saveProfile() {
    if (!_isButtonEnabled || _isSaving) {
      return;
    }

    final name = _nameController.text.trim();
    final image = _selectedImage;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    debugPrint('Name: $name');
    debugPrint('ImagePath: ${image?.path}');

    // TODO:
    // اطلاعات پروفایل را اینجا در API یا Database ذخیره کن.
    //
    // بعد از موفقیت:
    //
    // Navigator.of(context).pushReplacement(...);

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });
    });
  }

  void _skip() {
    if (_isSaving || _isPickingImage) {
      return;
    }

    FocusScope.of(context).unfocus();

    // TODO:
    // مسیر صفحه بعد از Skip را اینجا قرار بده.
    //
    // مثال:
    //
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(
    //     builder: (_) => const HomeScreen(),
    //   ),
    // );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: darkBg,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: darkBg,
        resizeToAvoidBottomInset: true,

        appBar: AppBar(
          backgroundColor: darkBg,
          elevation: 0,

          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: _isSaving
                ? null
                : () => Navigator.of(context).pop(),
          ),

          actions: [
            TextButton(
              onPressed:
                  _isSaving || _isPickingImage
                      ? null
                      : _skip,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                const Text(
                  'Enter your name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 32),

                // آواتار
                Center(
                  child: Semantics(
                    button: true,
                    label: _selectedImage == null
                        ? 'Add profile photo'
                        : 'Change profile photo',
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor:
                            Colors.white.withOpacity(0.08),
                        backgroundImage:
                            _selectedImage != null
                                ? FileImage(
                                    _selectedImage!,
                                  )
                                : null,
                        child: _selectedImage == null
                            ? AnimatedSwitcher(
                                duration:
                                    const Duration(
                                  milliseconds: 180,
                                ),
                                child: _isPickingImage
                                    ? const SizedBox(
                                        key: ValueKey(
                                          'loading',
                                        ),
                                        width: 28,
                                        height: 28,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<
                                                  Color>(
                                            Colors.white54,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        key: ValueKey(
                                          'camera',
                                        ),
                                        Icons
                                            .add_a_photo_outlined,
                                        size: 42,
                                        color:
                                            Colors.white54,
                                      ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // نام + آیکون کنار متن
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white54,
                        size: 28,
                      ),

                      const SizedBox(width: 8),

                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context)
                                  .size
                                  .width -
                              110,
                        ),
                        child: IntrinsicWidth(
                          child: TextField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,

                            textAlign: TextAlign.left,

                            textInputAction:
                                TextInputAction.done,

                            onSubmitted: (_) {
                              if (_isButtonEnabled) {
                                _saveProfile();
                              }
                            },

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),

                            cursorColor: Colors.white,
                            cursorWidth: 2,

                            textCapitalization:
                                TextCapitalization.words,

                            inputFormatters: [
                              LengthLimitingTextInputFormatter(
                                50,
                              ),
                            ],

                            decoration: InputDecoration(
                              hintText: 'Name',

                              hintStyle: TextStyle(
                                color: Colors.white
                                    .withOpacity(0.25),
                                fontSize: 26,
                                fontWeight:
                                    FontWeight.w500,
                              ),

                              border: InputBorder.none,
                              enabledBorder:
                                  InputBorder.none,
                              focusedBorder:
                                  InputBorder.none,

                              contentPadding:
                                  EdgeInsets.zero,

                              counterText: '',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Save
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        _isButtonEnabled && !_isSaving
                            ? _saveProfile
                            : null,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,

                      disabledBackgroundColor:
                          Colors.white
                              .withOpacity(0.12),

                      foregroundColor: darkBg,

                      disabledForegroundColor:
                          Colors.white38,

                      elevation:
                          _isButtonEnabled && !_isSaving
                              ? 4
                              : 0,

                      shadowColor:
                          Colors.white
                              .withOpacity(0.3),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(28),
                      ),
                    ),

                    child: AnimatedSwitcher(
                      duration:
                          const Duration(milliseconds: 180),
                      child: _isSaving
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 21,
                              height: 21,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor:
                                    AlwaysStoppedAnimation<
                                        Color>(
                                  darkBg,
                                ),
                              ),
                            )
                          : const Text(
                              'Save',
                              key: ValueKey('save'),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}