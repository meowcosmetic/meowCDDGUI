import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../constants/app_config.dart';
import '../dummy_data/dummy_users.dart';
import '../models/user_session.dart';
import '../models/policy_service.dart';
import '../utils/responsive_utils.dart';
import 'policy_view.dart';
import 'register_view.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  static const String _kGuestMode = 'guest_mode_enabled';
  static const String _kGuestPolicyAccepted = 'guest_policy_accepted';
  static const String _kCurrentUser = 'current_user';
  bool _isLoading = true;
  bool _isGuest = false;
  bool _guestPolicyAccepted = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    // Initialize global session
    await UserSession.initFromPrefs();
    final isGuest = prefs.getBool(_kGuestMode) ?? false;
    final accepted = prefs.getBool(_kGuestPolicyAccepted) ?? false;
    final userToken = prefs.getString('user_token');

    setState(() {
      _isGuest = isGuest;
      _guestPolicyAccepted = accepted;
      _isLoading = false;
    });

    // Nếu user đã đăng nhập, kiểm tra có cần hiển thị policy không
    if (userToken != null && userToken.isNotEmpty) {
      if (!mounted) return;

      if (AppConfig.showPolicyScreen) {
        // Kiểm tra xem user đã đọc policy chưa
        final shouldShowPolicy = await PolicyService.shouldShowPolicyScreen();
        if (shouldShowPolicy) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PolicyView()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainAppView()),
          );
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainAppView()),
        );
      }
    }
  }

  Future<void> _setGuestMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kGuestMode, value);
    setState(() {
      _isGuest = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Allow disabling login and/or policy via config
    if (!AppConfig.showLoginScreen) {
      if (!AppConfig.showPolicyScreen) {
        return const MainAppView();
      }
      // Skip login, go directly to policy flow
      return const PolicyView();
    }
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If guest and already accepted policy previously, go straight to main app
    if (_isGuest && _guestPolicyAccepted) {
      return const MainAppView();
    }

    // If guest but not accepted yet, go to policy page
    if (_isGuest && !_guestPolicyAccepted) {
      return const PolicyView();
    }

    // Default: login or continue as guest screen
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveBuilder(
        builder: (context, layoutType) {
          // Desktop layout with 2 columns
          if (ResponsiveUtils.isDesktop(context) || ResponsiveUtils.isLargeDesktop(context)) {
            return Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Left side - Information section
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: ResponsiveUtils.getResponsivePadding(context),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                              // Logo and title
              Row(
                children: [
                  Container(
                                    padding: ResponsiveUtils.getResponsiveCardPadding(context),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 12),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.psychology,
                                      color: AppColors.white,
                                      size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 32),
                                    ),
                                  ),
                                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 16)),
                                  ResponsiveText(
                                    'The Happiness Journey',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ],
                              ),
                              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 32)),
                              
                              // Welcome message
                              ResponsiveText(
                                'Chào mừng!',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 16)),
                              
                              // Description
                              ResponsiveText(
                                'Đăng nhập để đồng bộ dữ liệu giữa các thiết bị, hoặc tiếp tục với chế độ Khách.',
                                fontSize: 16,
                                color: AppColors.white.withValues(alpha: 0.9),
                              ),
                              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 24)),
                              
                              // Features list
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFeatureItem(context, 'Hỗ trợ trẻ tự kỷ', Icons.favorite),
                                  _buildFeatureItem(context, 'Đánh giá phát triển', Icons.assessment),
                                  _buildFeatureItem(context, 'Tài liệu chuyên môn', Icons.library_books),
                                  _buildFeatureItem(context, 'Cộng đồng hỗ trợ', Icons.people),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Right side - Login form
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: ResponsiveUtils.getResponsivePadding(context),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Login form
                              ResponsiveContainer(
                                color: AppColors.white,
                                borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                child: Column(
                                  children: [
                                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 32)),
                                    
                                    // Form title
                                    ResponsiveText(
                                      'Đăng nhập',
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 8)),
                                    
                                    ResponsiveText(
                                      'Chọn phương thức đăng nhập',
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 32)),
                                    
                                    // Login buttons
                                    ResponsiveButton(
                                      text: 'Đăng nhập',
                                      icon: Icons.login,
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.white,
                                      onPressed: () {
                                        Navigator.of(context).pushNamed('/login');
                                      },
                                    ),
                                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 12)),
                                    
                                    ResponsiveButton(
                                      text: 'Đăng ký',
                                      icon: Icons.person_add_alt_1,
                                      foregroundColor: AppColors.primary,
                                      isOutlined: true,
                                      onPressed: () {
                                        Navigator.of(context).pushNamed('/register');
                                      },
                                    ),
                                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 12)),
                                    
                                    ResponsiveButton(
                                      text: 'Tiếp tục với Khách',
                                      icon: Icons.person_outline,
                                      foregroundColor: AppColors.primary,
                                      isOutlined: true,
                                      onPressed: () async {
                                        // Quick action: save dummy dev user for testing in debug/dev mode
                                        final prefs = await SharedPreferences.getInstance();
                                        await prefs.setString(
                                          _kCurrentUser,
                                          dummyDevUser.toJsonString(),
                                        );
                                        // Không tạo dummy customer_id - để văng ra lỗi khi không có sub
                                        await _setGuestMode(true);
                                        if (!mounted) return;
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(builder: (_) => const PolicyView()),
                                        );
                                      },
                                    ),
                                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 32)),
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
                // Bottom blue section
                Container(
                  height: 60,
                  width: double.infinity,
                    decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Center(
                    child: ResponsiveText(
                      'Hỗ trợ trẻ tự kỷ - Hành trình hạnh phúc',
                      fontSize: 14,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            );
          }
          
          // Mobile/Tablet layout (original)
          return SafeArea(
            child: Center(
              child: ResponsiveContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 24)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: ResponsiveUtils.getResponsiveCardPadding(context),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 12),
                            ),
                          ),
                          child: Icon(
                            Icons.psychology,
                            color: AppColors.primary,
                            size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 28),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 12)),
                        ResponsiveText(
                    'The Happiness Journey',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                  ),
                ],
              ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 32)),
                    ResponsiveText(
                'Chào mừng!',
                      textAlign: TextAlign.center,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 8)),
                    ResponsiveText(
                'Đăng nhập để đồng bộ dữ liệu giữa các thiết bị, hoặc tiếp tục với chế độ Khách.',
                      textAlign: TextAlign.center,
                      fontSize: 14,
                      color: AppColors.textSecondary,
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
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 12)),
                    ResponsiveButton(
                      text: 'Đăng ký',
                      icon: Icons.person_add_alt_1,
                      foregroundColor: AppColors.primary,
                      isOutlined: true,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/register');
                  },
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 12)),
                    ResponsiveButton(
                      text: 'Tiếp tục với Khách',
                      icon: Icons.person_outline,
                      foregroundColor: AppColors.primary,
                      isOutlined: true,
                  onPressed: () async {
                    // Quick action: save dummy dev user for testing in debug/dev mode
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(
                      _kCurrentUser,
                      dummyDevUser.toJsonString(),
                    );
                    // Không tạo dummy customer_id - để văng ra lỗi khi không có sub
                    await _setGuestMode(true);
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const PolicyView()),
                    );
                  },
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 24)),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 12)),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.white.withValues(alpha: 0.9),
            size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 20),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 12)),
          ResponsiveText(
            text,
            fontSize: 16,
            color: AppColors.white.withValues(alpha: 0.9),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithStoredUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCurrentUser);
    if (raw == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có tài khoản. Vui lòng Đăng ký trước.'),
        ),
      );
      return;
    }
    if (!mounted) return;
    if (AppConfig.showPolicyScreen) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const PolicyView()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainAppView()));
    }
  }
}
