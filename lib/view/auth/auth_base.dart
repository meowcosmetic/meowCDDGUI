import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_config.dart';
import '../../dummy_data/dummy_users.dart';
import '../../models/user_session.dart';
import '../../models/policy_service.dart';
import '../../models/api_service.dart';
import '../../models/user.dart';
import '../../utils/responsive_utils.dart';
import '../policy_view.dart';
import '../register_view.dart';

abstract class AuthBase extends StatefulWidget {
  const AuthBase({super.key});
}

abstract class AuthBaseState<T extends AuthBase> extends State<T>
    with TickerProviderStateMixin {
  late TabController _tabController;
  static const String _kGuestMode = 'guest_mode_enabled';
  static const String _kGuestPolicyAccepted = 'guest_policy_accepted';
  static const String _kCurrentUser = 'current_user';
  
  // Getters for subclasses
  TabController get tabController => _tabController;
  bool _isLoading = true;
  bool _isGuest = false;
  bool _guestPolicyAccepted = false;
  
  // Getters for subclasses
  bool get isLoading => _isLoading;
  bool get isGuest => _isGuest;
  bool get guestPolicyAccepted => _guestPolicyAccepted;
  
  // Method getters for subclasses
  Future<void> setGuestMode(bool enabled) async => _setGuestMode(enabled);
  Widget buildLoginForm() => _buildLoginForm();
  Widget buildRegisterForm() => _buildRegisterForm();
  
  // Constants for subclasses
  static const String kCurrentUser = _kCurrentUser;

  // Form controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPhoneController = TextEditingController();
  final _registerYearController = TextEditingController();
  final _registerAvatarController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  // Form state
  bool _isLoginFormValid = false;
  bool _isRegisterFormValid = false;
  bool _isSubmitting = false;
  String _registerSex = 'other';
  String _registerSecondaryRole = 'PARENT';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add listeners for form validation
    _loginEmailController.addListener(_recomputeLoginFormValidity);
    _loginPasswordController.addListener(_recomputeLoginFormValidity);
    _registerNameController.addListener(_recomputeRegisterFormValidity);
    _registerEmailController.addListener(_recomputeRegisterFormValidity);
    _registerPhoneController.addListener(_recomputeRegisterFormValidity);
    _registerYearController.addListener(_recomputeRegisterFormValidity);
    _registerPasswordController.addListener(_recomputeRegisterFormValidity);

    _bootstrap();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPhoneController.dispose();
    _registerYearController.dispose();
    _registerAvatarController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    // Initialize global session
    await UserSession.initFromPrefs();

    // Check if user is already logged in
    final currentUser = UserSession.currentUser;
    if (currentUser != null) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      if (AppConfig.showPolicyScreen) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PolicyView()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainAppView()),
        );
      }
      return;
    }

    // Check guest mode
    final isGuest = prefs.getBool(_kGuestMode) ?? false;
    final accepted = prefs.getBool(_kGuestPolicyAccepted) ?? false;

    setState(() {
      _isGuest = isGuest;
      _guestPolicyAccepted = accepted;
      _isLoading = false;
    });
  }

  void _recomputeLoginFormValidity() {
    final valid =
        _loginEmailController.text.trim().isNotEmpty &&
        _loginEmailController.text.trim().contains('@') &&
        _loginPasswordController.text.isNotEmpty;
    if (valid != _isLoginFormValid) {
      setState(() {
        _isLoginFormValid = valid;
      });
    }
  }

  void _recomputeRegisterFormValidity() {
    final currentYear = DateTime.now().year;
    final year = int.tryParse(_registerYearController.text.trim()) ?? 0;

    final nameValid = _registerNameController.text.trim().isNotEmpty;
    final emailValid =
        _registerEmailController.text.trim().contains('@') &&
        _registerEmailController.text.trim().isNotEmpty;
    final passwordValid = _registerPasswordController.text.length >= 6;
    final phoneValid = _registerPhoneController.text.trim().isNotEmpty;
    final yearValid = year >= 1900 && year <= currentYear;

    final valid =
        nameValid && emailValid && passwordValid && phoneValid && yearValid;

    if (valid != _isRegisterFormValid) {
      setState(() {
        _isRegisterFormValid = valid;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_isLoginFormValid) return;
    setState(() => _isSubmitting = true);

    try {
      final api = ApiService();
      final response = await api.login(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = response.body;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', token);
        if (token.isNotEmpty) {
          await UserSession.updateFromLoginToken(token);
        }
        await prefs.setString('user_email', _loginEmailController.text.trim());

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đăng nhập thành công!'),
            backgroundColor: AppColors.primary,
          ),
        );

        if (AppConfig.showPolicyScreen) {
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
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Đăng nhập thất bại: Email hoặc mật khẩu không đúng',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kết nối máy chủ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_isRegisterFormValid) return;
    setState(() => _isSubmitting = true);

    try {
      final nowIso = DateTime.now().toIso8601String();
      final user = User(
        customerId: 'CUS-${DateTime.now().millisecondsSinceEpoch}',
        name: _registerNameController.text.trim(),
        email: _registerEmailController.text.trim(),
        phone: _registerPhoneController.text.trim(),
        sex: _registerSex,
        yearOfBirth: int.tryParse(_registerYearController.text.trim()) ?? 0,
        avatar: _registerAvatarController.text.trim(),
        addresses: const [],
        cardDetails: const [],
        interactive: 0,
        bought: 0,
        viewed: 0,
        password: _registerPasswordController.text,
        token: '',
        roles: [const Role('CUSTOMER'), Role(_registerSecondaryRole)],
        metadata: Metadata(
          createdAtIso: nowIso,
          updatedAtIso: nowIso,
          extra: const {},
        ),
      );

      final api = ApiService();
      final resp = await api.createUser(user);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Đăng ký thành công! Vui lòng đăng nhập để tiếp tục.',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
        // Switch to login tab
        _tabController.animateTo(0);
        // Clear register form
        _registerNameController.clear();
        _registerEmailController.clear();
        _registerPhoneController.clear();
        _registerYearController.clear();
        _registerAvatarController.clear();
        _registerPasswordController.clear();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đăng ký thất bại (${resp.statusCode}). Vui lòng thử lại.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kết nối máy chủ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _setGuestMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kGuestMode, enabled);
    setState(() {
      _isGuest = enabled;
    });
  }

  void _navigateToMainApp() {
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

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email field
        TextField(
          controller: _loginEmailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Nhập email của bạn',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(
                  context,
                  baseRadius: 8,
                ),
              ),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            baseSpacing: 16,
          ),
        ),

        // Password field
        TextField(
          controller: _loginPasswordController,
          decoration: InputDecoration(
            labelText: 'Mật khẩu',
            hintText: 'Nhập mật khẩu',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(
                  context,
                  baseRadius: 8,
                ),
              ),
            ),
          ),
          obscureText: true,
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            baseSpacing: 24,
          ),
        ),

        // Login button
        ResponsiveButton(
          text: 'Đăng nhập',
          icon: Icons.login,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          onPressed: _isSubmitting || !_isLoginFormValid ? null : _handleLogin,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name field
        TextField(
          controller: _registerNameController,
          decoration: InputDecoration(
            labelText: 'Họ và tên',
            hintText: 'Nhập họ và tên của bạn',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(
                  context,
                  baseRadius: 8,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            baseSpacing: 16,
          ),
        ),

        // Email field
        TextField(
          controller: _registerEmailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Nhập email của bạn',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(
                  context,
                  baseRadius: 8,
                ),
              ),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            baseSpacing: 16,
          ),
        ),

        // Phone field
        TextField(
          controller: _registerPhoneController,
          decoration: InputDecoration(
            labelText: 'Số điện thoại',
            hintText: 'Nhập số điện thoại',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(
                  context,
                  baseRadius: 8,
                ),
              ),
            ),
          ),
          keyboardType: TextInputType.phone,
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            baseSpacing: 16,
          ),
        ),

        // Sex dropdown
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Giới tính',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(
                  context,
                  baseRadius: 8,
                ),
              ),
            ),
          ),
          value: _registerSex,
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Nam')),
            DropdownMenuItem(value: 'female', child: Text('Nữ')),
            DropdownMenuItem(value: 'other', child: Text('Khác')),
          ],
          onChanged: (v) {
            setState(() => _registerSex = v ?? 'other');
            _recomputeRegisterFormValidity();
          },
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            baseSpacing: 16,
          ),
        ),

        // Year of birth field
        TextField(
          controller: _registerYearController,
          decoration: InputDecoration(
            labelText: 'Năm sinh',
            hintText: 'Nhập năm sinh',
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(
                  context,
                  baseRadius: 8,
                ),
              ),
            ),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            baseSpacing: 16,
          ),
        ),

        // Role dropdown
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Bạn là',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(
                  context,
                  baseRadius: 8,
                ),
              ),
            ),
          ),
          value: _registerSecondaryRole,
          items: const [
            DropdownMenuItem(value: 'PARENT', child: Text('Phụ huynh')),
            DropdownMenuItem(value: 'TEACHER', child: Text('Giáo viên')),
          ],
          onChanged: (v) {
            setState(() => _registerSecondaryRole = v ?? 'PARENT');
            _recomputeRegisterFormValidity();
          },
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            baseSpacing: 16,
          ),
        ),

        // Password field
        TextField(
          controller: _registerPasswordController,
          decoration: InputDecoration(
            labelText: 'Mật khẩu',
            hintText: 'Nhập mật khẩu (tối thiểu 6 ký tự)',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(
                  context,
                  baseRadius: 8,
                ),
              ),
            ),
          ),
          obscureText: true,
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            baseSpacing: 24,
          ),
        ),

        // Register button
        ResponsiveButton(
          text: 'Đăng ký',
          icon: Icons.person_add_alt_1,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          onPressed: _isSubmitting || !_isRegisterFormValid
              ? null
              : _handleRegister,
        ),
      ],
    );
  }

  // Abstract methods to be implemented by subclasses
  @override
  Widget build(BuildContext context);
}

