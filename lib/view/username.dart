import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_page/view/profile.dart';

class UsernameInputScreen extends StatefulWidget {
  const UsernameInputScreen({super.key});

  @override
  State<UsernameInputScreen> createState() =>
      _UsernameInputScreenState();
}

class _UsernameInputScreenState extends State<UsernameInputScreen> {
  static const Color darkBg = Color(0xFF090909);

  static const int _minUsernameLength = 3;
  static const int _maxUsernameLength = 32;

  final TextEditingController _usernameController =
      TextEditingController();

  final FocusNode _usernameFocusNode = FocusNode();

  bool _isButtonEnabled = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _usernameController.addListener(_validateUsername);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _usernameFocusNode.requestFocus();
      }
    });
  }

  void _validateUsername() {
    final text = _usernameController.text.trim();

    final isValid =
        text.length >= _minUsernameLength &&
        text.length <= _maxUsernameLength;

    if (isValid != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isValid;
      });
    }
  }

  void _continue() {
    if (!_isButtonEnabled || _isSaving) {
      return;
    }

    final username = _usernameController.text.trim();

    if (username.length < _minUsernameLength ||
        username.length > _maxUsernameLength) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    debugPrint('Submitted Username: @$username');

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 420),
        reverseTransitionDuration:
            const Duration(milliseconds: 360),

        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const ProfileSetupScreen();
        },

        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          final slide = Tween<Offset>(
            begin: const Offset(0.025, 0),
            end: Offset.zero,
          ).animate(curve);

          final fade = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(
                0.0,
                0.85,
                curve: Curves.easeOut,
              ),
            ),
          );

          final scale = Tween<double>(
            begin: 0.985,
            end: 1.0,
          ).animate(curve);

          return SlideTransition(
            position: slide,
            child: FadeTransition(
              opacity: fade,
              child: ScaleTransition(
                scale: scale,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  void _skip() {
    if (_isSaving) {
      return;
    }

    FocusScope.of(context).unfocus();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 420),
        reverseTransitionDuration:
            const Duration(milliseconds: 360),

        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const ProfileSetupScreen();
        },

        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          final slide = Tween<Offset>(
            begin: const Offset(0.025, 0),
            end: Offset.zero,
          ).animate(curve);

          final fade = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(
                0.0,
                0.85,
                curve: Curves.easeOut,
              ),
            ),
          );

          final scale = Tween<double>(
            begin: 0.985,
            end: 1.0,
          ).animate(curve);

          return SlideTransition(
            position: slide,
            child: FadeTransition(
              opacity: fade,
              child: ScaleTransition(
                scale: scale,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: _isSaving ? null : _skip,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
                'Enter your username',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 40),

              // Username input
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  const Text(
                    '@',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: TextField(
                      controller: _usernameController,
                      focusNode: _usernameFocusNode,

                      autofocus: false,

                      textInputAction:
                          TextInputAction.done,

                      onSubmitted: (_) {
                        if (_isButtonEnabled) {
                          _continue();
                        }
                      },

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),

                      cursorColor: Colors.white,
                      cursorWidth: 2,

                      maxLength: _maxUsernameLength,

                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9_.]'),
                        ),
                        LengthLimitingTextInputFormatter(
                          _maxUsernameLength,
                        ),
                      ],

                      decoration: InputDecoration(
                        hintText: 'username',

                        hintStyle: TextStyle(
                          color:
                              Colors.white.withOpacity(0.18),
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                        ),

                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,

                        contentPadding: EdgeInsets.zero,

                        counterText: '',
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Continue
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _isButtonEnabled && !_isSaving
                          ? _continue
                          : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,

                    disabledBackgroundColor:
                        Colors.white.withOpacity(0.12),

                    foregroundColor: darkBg,

                    disabledForegroundColor:
                        Colors.white38,

                    elevation:
                        _isButtonEnabled && !_isSaving
                            ? 6
                            : 0,

                    shadowColor:
                        Colors.white.withOpacity(0.3),

                    shape: RoundedRectangleBorder(
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
                            'Continue',
                            key: ValueKey('continue'),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}