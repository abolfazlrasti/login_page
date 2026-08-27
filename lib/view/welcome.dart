import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_page/view/number.dart';

class WelcomeApp extends StatelessWidget {
  const WelcomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090909),
      ),

      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // رنگ‌های اصلی
  static const Color darkBg = Color(0xFF090909);
  static const Color subtitleGrey = Color(0xFF888888);

  // ساخت Route با انیمیشن Fade + Slide
  Route<void> _createSmoothRoute(Widget page) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 360),

    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      return page;
    },

    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      final primaryCurve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final slide = Tween<Offset>(
        begin: const Offset(0.025, 0),
        end: Offset.zero,
      ).animate(primaryCurve);

      final fade = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(
            0.0,
            0.8,
            curve: Curves.easeOut,
          ),
        ),
      );

      final scale = Tween<double>(
        begin: 0.985,
        end: 1.0,
      ).animate(primaryCurve);

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
  );
}

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // -------------------------
        // Status Bar
        // -------------------------
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,

        // -------------------------
        // Navigation Bar
        // -------------------------
        systemNavigationBarColor: darkBg,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),

      child: Scaffold(
        backgroundColor: darkBg,

        body: Stack(
          children: [
            // -------------------------
            // پس‌زمینه مینیمال بالا
            // -------------------------
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.015),
                ),
              ),
            ),

            // -------------------------
            // پس‌زمینه مینیمال پایین
            // -------------------------
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.01),
                ),
              ),
            ),

            // -------------------------
            // محتوای اصلی
            // -------------------------
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 24.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // -------------------------
                    // Header
                    // -------------------------
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(
                        'WELCOME',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ),

                    // -------------------------
                    // متن اصلی
                    // -------------------------
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 480,
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Welcome to Telegram.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.18,
                              letterSpacing: -0.5,
                            ),
                          ),

                          SizedBox(height: 18),

                          Text(
                            'A fast, secure, and seamless experience to connect with friends and communities worldwide.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: subtitleGrey,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // -------------------------
                    // دکمه Get Started
                    // -------------------------
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 40.0,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Semantics(
                          button: true,
                          label: 'Get started',
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                _createSmoothRoute(
                                  const LoginPage(),
                                ),
                              );
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: darkBg,

                              elevation: 4,

                              shadowColor:
                                  Colors.white.withOpacity(0.2),

                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(28),
                              ),

                              tapTargetSize:
                                  MaterialTapTargetSize.padded,
                            ),

                            child: const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Get started',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),

                                SizedBox(width: 10),

                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
}