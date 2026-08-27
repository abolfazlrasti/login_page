import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_page/view/username.dart';

class OtpVerification extends StatefulWidget {
  final String phoneNumber;

  const OtpVerification({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerification> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerification> {
  static const Color darkBg = Color(0xFF090909);
  static const Color successGreen = Color(0xFF00E676);

  static const int _codeLength = 6;

  final List<TextEditingController> _controllers =
      List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes =
      List.generate(
    _codeLength,
    (_) => FocusNode(),
  );

  final List<bool> _successStates =
      List.generate(
    _codeLength,
    (_) => false,
  );

  bool _isButtonEnabled = false;
  bool _isVerifying = false;
  bool _isRequestingCode = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _requestNewCode();

      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  void _checkOtpCompletion() {
    final code = _controllers.map((c) => c.text).join();

    final isComplete = code.length == _codeLength;

    if (isComplete != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isComplete;
      });
    }
  }

  Future<void> _requestNewCode() async {
    if (_isRequestingCode || _isVerifying) {
      return;
    }

    setState(() {
      _isRequestingCode = true;
    });

    try {
      // ==========================================
      // TODO:
      // اینجا API واقعی ارسال OTP را قرار بده.
      //
      // مثال:
      // await authService.sendOtp(widget.phoneNumber);
      // ==========================================

      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      if (!mounted) return;

      _clearOtp();

      _focusNodes[0].requestFocus();
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingCode = false;
        });
      }
    }
  }

  void _clearOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }

    for (int i = 0; i < _successStates.length; i++) {
      _successStates[i] = false;
    }

    if (mounted) {
      setState(() {
        _isButtonEnabled = false;
      });
    }
  }

  Future<void> _verifyCode() async {
    if (!_isButtonEnabled || _isVerifying) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isVerifying = true;
    });

    // ------------------------------------------
    // سبز شدن تک تک اعداد
    // ------------------------------------------

    for (int i = 0; i < _codeLength; i++) {
      await Future.delayed(
        const Duration(milliseconds: 180),
      );

      if (!mounted) return;

      setState(() {
        _successStates[i] = true;
      });
    }

    // مکث برای دیده شدن حالت موفق
    await Future.delayed(
      const Duration(milliseconds: 350),
    );

    if (!mounted) return;

    _openUsernameScreen();
  }

  void _openUsernameScreen() {
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
          return const UsernameInputScreen();
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

  void _handleBack() {
    if (_isVerifying || _isRequestingCode) {
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,

      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: _handleBack,
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              const Text(
                'Enter 6-digit\ncode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 15,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Code sent to ',
                    ),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(
                      text: '.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: List.generate(
                  _codeLength,
                  (index) {
                    final isSuccess =
                        _successStates[index];

                    return SizedBox(
                      width: 48,
                      height: 60,
                      child: TextField(
                        controller:
                            _controllers[index],
                        focusNode:
                            _focusNodes[index],
                        enabled: !_isVerifying &&
                            !_isRequestingCode,
                        keyboardType:
                            TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,

                        style: TextStyle(
                          color: isSuccess
                              ? successGreen
                              : Colors.white,
                          fontSize: 26,
                          fontWeight:
                              FontWeight.w800,
                        ),

                        cursorColor: Colors.white,

                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly,
                        ],

                        decoration:
                            InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white
                              .withOpacity(0.05),
                          contentPadding:
                              EdgeInsets.zero,

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                            borderSide:
                                BorderSide.none,
                          ),

                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                            borderSide:
                                BorderSide(
                              color: isSuccess
                                  ? successGreen
                                  : Colors.white,
                              width: 1.5,
                            ),
                          ),

                          enabledBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                            borderSide:
                                BorderSide(
                              color: isSuccess
                                  ? successGreen
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                        ),

                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            if (index <
                                _codeLength - 1) {
                              _focusNodes[
                                index + 1
                              ].requestFocus();
                            } else {
                              _focusNodes[index]
                                  .unfocus();
                            }
                          } else if (index > 0) {
                            _focusNodes[
                              index - 1
                            ].requestFocus();
                          }

                          _checkOtpCompletion();
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              TextButton(
                onPressed:
                    _isRequestingCode ||
                            _isVerifying
                        ? null
                        : _requestNewCode,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                child: AnimatedSwitcher(
                  duration:
                      const Duration(milliseconds: 180),
                  child: _isRequestingCode
                      ? const Text(
                          'Sending new code...',
                          key: ValueKey('sending'),
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        )
                      : const Text(
                          'Didn’t receive a code?',
                          key: ValueKey('resend'),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _isButtonEnabled &&
                              !_isVerifying &&
                              !_isRequestingCode
                          ? _verifyCode
                          : null,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.white,
                    disabledBackgroundColor:
                        Colors.white
                            .withOpacity(0.12),
                    foregroundColor: darkBg,
                    disabledForegroundColor:
                        Colors.white38,
                    elevation:
                        _isButtonEnabled &&
                                !_isVerifying
                            ? 6
                            : 0,
                    shadowColor:
                        Colors.white
                            .withOpacity(0.3),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        28,
                      ),
                    ),
                  ),

                  child: AnimatedSwitcher(
                    duration:
                        const Duration(milliseconds: 200),
                    child: _isVerifying
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 22,
                            height: 22,
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
                            'Verify',
                            key: ValueKey('verify'),
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