import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../constants/app_config.dart';
import '../dummy_data/dummy_users.dart';
import '../models/user_session.dart';
import '../models/policy_service.dart';
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
      body: SafeArea(
        child: kIsWeb 
          ? Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.psychology,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'The Happiness Journey',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Chào mừng!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đăng nhập để đồng bộ dữ liệu giữa các thiết bị, hoặc tiếp tục với chế độ Khách.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.login),
                          label: const Text('Đăng nhập'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/register');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text('Đăng ký'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
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
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.person_outline),
                          label: const Text('Tiếp tục với Khách'),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'The Happiness Journey',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Chào mừng!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đăng nhập để đồng bộ dữ liệu giữa các thiết bị, hoặc tiếp tục với chế độ Khách.',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.login),
                      label: const Text('Đăng nhập'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/register');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Đăng ký'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
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
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.person_outline),
                      label: const Text('Tiếp tục với Khách'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
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
