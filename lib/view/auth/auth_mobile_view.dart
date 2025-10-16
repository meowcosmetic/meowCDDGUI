import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../dummy_data/dummy_users.dart';
import '../../utils/responsive_utils.dart';
import '../policy_view.dart';
import 'auth_base.dart';

class AuthMobileView extends AuthBase {
  const AuthMobileView({super.key});

  @override
  State<AuthMobileView> createState() => _AuthMobileViewState();
}

class _AuthMobileViewState extends AuthBaseState<AuthMobileView> {
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
          // Mobile/Tablet layout
          return SafeArea(
            child: Center(
              child: ResponsiveContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        baseSpacing: 24,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            baseSpacing: 12,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            'The Happiness Journey',
                            style: GoogleFonts.fredoka(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                baseFontSize: 20,
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
                      textAlign: TextAlign.center,
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
                      textAlign: TextAlign.center,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        baseFontSize: 14,
                      ),
                      color: AppColors.textSecondary,
                    ),

                    // App image
                    Center(
                      child: FractionallySizedBox(
                        widthFactor:
                            0.8, // chiếm 80% chiều rộng màn hình cho mobile
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

                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        baseSpacing: 24,
                      ),
                    ),

                    const Spacer(),
                    ResponsiveButton(
                      text: 'Đăng nhập',
                      icon: Icons.login,
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        baseSpacing: 12,
                      ),
                    ),
                    ResponsiveButton(
                      text: 'Đăng ký',
                      icon: Icons.person_add_alt_1,
                      foregroundColor: AppColors.primary,
                      isOutlined: true,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/register');
                      },
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        baseSpacing: 12,
                      ),
                    ),
                    ResponsiveButton(
                      text: 'Khám phá ngay?',
                      icon: Icons.person_outline,
                      foregroundColor: AppColors.primary,
                      isOutlined: true,
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                          AuthBaseState.kCurrentUser,
                          dummyDevUser.toJsonString(),
                        );
                        await setGuestMode(true);
                        if (!context.mounted) return;
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const PolicyView()),
                        );
                      },
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        baseSpacing: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

