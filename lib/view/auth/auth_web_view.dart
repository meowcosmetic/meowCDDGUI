import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../dummy_data/dummy_users.dart';
import '../../utils/responsive_utils.dart';
import '../policy_view.dart';
import 'auth_base.dart';
import 'auth_mobile_view.dart';

class AuthWebView extends AuthBase {
  const AuthWebView({super.key});

  @override
  State<AuthWebView> createState() => _AuthWebViewState();
}

class _AuthWebViewState extends AuthBaseState<AuthWebView> {
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If guest and already accepted policy previously, go straight to main app
    if (isGuest && guestPolicyAccepted) {
      return const MainAppView();
    }

    // If guest but not accepted yet, go to policy page
    if (isGuest && !guestPolicyAccepted) {
      return const PolicyView();
    }

    // Default: login or continue as guest screen
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveBuilder(
        builder: (context, layoutType) {
          if (layoutType == ResponsiveLayoutType.desktop ||
              layoutType == ResponsiveLayoutType.largeDesktop) {
            // Desktop layout
            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                // constraints: const BoxConstraints(maxWidth: 1000),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(
                      context,
                      baseRadius: 16,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Left side - App info
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: ResponsiveUtils.getResponsivePadding(context),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo and title
                            Row(
                              children: [
                                Container(
                                  width: ResponsiveUtils.getResponsiveIconSize(
                                    context,
                                    baseSize: 60,
                                  ),
                                  height: ResponsiveUtils.getResponsiveIconSize(
                                    context,
                                    baseSize: 60,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveUtils.getResponsiveBorderRadius(
                                        context,
                                        baseRadius: 12,
                                      ),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveUtils.getResponsiveBorderRadius(
                                        context,
                                        baseRadius: 12,
                                      ),
                                    ),
                                    child: Image.asset(
                                      'lib/asset/new_logo_white_background.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: ResponsiveUtils.getResponsiveSpacing(
                                    context,
                                    baseSpacing: 16,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    'The Happiness Journey',
                                    style: GoogleFonts.fredoka(
                                      fontSize:
                                          ResponsiveUtils.getResponsiveFontSize(
                                            context,
                                            baseFontSize: 48,
                                          ),
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.visible,
                                    softWrap: true,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: ResponsiveUtils.getResponsiveSpacing(
                                context,
                                baseSpacing: 24,
                              ),
                            ),

                            ResponsiveText(
                              'Chào mừng!',
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                baseFontSize: 28,
                              ),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            SizedBox(
                              height: ResponsiveUtils.getResponsiveSpacing(
                                context,
                                baseSpacing: 16,
                              ),
                            ),

                            ResponsiveText(
                              'Ứng dụng hỗ trợ toàn diện cho trẻ tự kỷ và gia đình. Đánh giá phát triển, tài liệu chuyên môn và cộng đồng hỗ trợ.',
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                baseFontSize: 16,
                              ),
                              color: AppColors.textSecondary,
                            ),

                            // App image
                            Center(
                              child: FractionallySizedBox(
                                widthFactor:
                                    0.75, // chiếm 50% chiều rộng màn hình
                                child: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveUtils.getResponsiveBorderRadius(
                                          context,
                                          baseRadius: 16,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.shadow,
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveUtils.getResponsiveBorderRadius(
                                          context,
                                          baseRadius: 16,
                                        ),
                                      ),
                                      child: Image.asset(
                                        'lib/asset/auth_gate.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Divider
                    Container(width: 1, height: 400, color: AppColors.grey200),

                    // Right side - Login form
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getResponsiveBorderRadius(
                              context,
                              baseRadius: 16,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: AppColors.shadow.withOpacity(0.05),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Background pattern
                            Positioned.fill(
                              child: CustomPaint(
                                painter: DotsPatternPainter(
                                  color: AppColors.primary.withOpacity(0.03),
                                  dotRadius: 2.0,
                                  spacing: 20.0,
                                ),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: ResponsiveUtils.getResponsivePadding(
                                context,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Form title
                                  SizedBox(
                                    height:
                                        ResponsiveUtils.getResponsiveSpacing(
                                          context,
                                          baseSpacing: 32,
                                        ),
                                  ),

                                  // Tab bar
                                  TabBar(
                                    controller: tabController,
                                    isScrollable: true,
                                    indicatorColor: AppColors.primary,
                                    labelColor: AppColors.primary,
                                    unselectedLabelColor:
                                        AppColors.textSecondary,
                                    labelStyle: TextStyle(
                                      fontSize:
                                          ResponsiveUtils.getResponsiveFontSize(
                                            context,
                                            baseFontSize: 16,
                                          ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    unselectedLabelStyle: TextStyle(
                                      fontSize:
                                          ResponsiveUtils.getResponsiveFontSize(
                                            context,
                                            baseFontSize: 16,
                                          ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    tabs: const [
                                      Tab(text: 'Đăng nhập'),
                                      Tab(text: 'Đăng ký'),
                                    ],
                                  ),
                                  SizedBox(
                                    height:
                                        ResponsiveUtils.getResponsiveSpacing(
                                          context,
                                          baseSpacing: 24,
                                        ),
                                  ),

                                  // Tab content
                                  SizedBox(
                                    height: 550,
                                    child: TabBarView(
                                      controller: tabController,
                                      children: [
                                        // Login tab
                                        SingleChildScrollView(
                                          padding: const EdgeInsets.all(12),
                                          child: buildLoginForm(),
                                        ),
                                        // Register tab
                                        SingleChildScrollView(
                                          padding: const EdgeInsets.all(12),
                                          child: buildRegisterForm(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        ResponsiveUtils.getResponsiveSpacing(
                                          context,
                                          baseSpacing: 12,
                                        ),
                                  ),

                                  Center(
                                    child: TextButton(
                                      onPressed: () async {
                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        await prefs.setString(
                                          AuthBaseState.kCurrentUser,
                                          dummyDevUser.toJsonString(),
                                        );
                                        await setGuestMode(true);
                                        if (!context.mounted) return;
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) => const PolicyView(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Khám phá ngay?',
                                        style: TextStyle(
                                          fontSize:
                                              ResponsiveUtils.getResponsiveFontSize(
                                                context,
                                                baseFontSize: 16,
                                              ),
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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

          // Mobile/Tablet layout - fallback to mobile view
          return const AuthMobileView();
        },
      ),
    );
  }
}

class DotsPatternPainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double spacing;

  DotsPatternPainter({
    required this.color,
    required this.dotRadius,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rows = (size.height / spacing).ceil();
    final cols = (size.width / spacing).ceil();

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final x = col * spacing + spacing / 2;
        final y = row * spacing + spacing / 2;

        if (x <= size.width && y <= size.height) {
          canvas.drawCircle(Offset(x, y), dotRadius, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

